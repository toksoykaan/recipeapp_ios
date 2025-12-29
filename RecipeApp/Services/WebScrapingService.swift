import Foundation

/// Service for scraping recipe data from websites
class WebScrapingService {
    static let shared = WebScrapingService()

    private init() {}

    /// Extract recipe from URL by parsing structured data and HTML content
    func extractRecipe(from urlString: String) async throws -> ParsedRecipe {
        guard let url = URL(string: urlString) else {
            throw RecipeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RecipeError.serverError
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw RecipeError.invalidResponse
        }

        // Try JSON-LD first (most reliable)
        if let recipe = extractFromJsonLD(html) {
            return recipe
        }

        // Fallback to basic HTML parsing
        if let recipe = extractFromBasicHTML(html, url: urlString) {
            return recipe
        }

        throw RecipeError.parsingError
    }

    // MARK: - JSON-LD Extraction

    private func extractFromJsonLD(_ html: String) -> ParsedRecipe? {
        // Find all JSON-LD script tags
        let pattern = #"<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return nil
        }

        let nsString = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsString.length))

        for match in matches {
            guard match.numberOfRanges > 1 else { continue }
            let jsonRange = match.range(at: 1)
            let jsonText = nsString.substring(with: jsonRange)

            guard let jsonData = jsonText.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) else {
                continue
            }

            // Handle both single objects and arrays
            let recipes: [[String: Any]]
            if let array = json as? [[String: Any]] {
                recipes = array
            } else if let dict = json as? [String: Any] {
                recipes = [dict]
            } else {
                continue
            }

            for data in recipes {
                if let type = data["@type"] as? String, type == "Recipe" {
                    return parseJsonLDRecipe(data)
                } else if let types = data["@type"] as? [String], types.contains("Recipe") {
                    return parseJsonLDRecipe(data)
                }
            }
        }

        return nil
    }

    private func parseJsonLDRecipe(_ data: [String: Any]) -> ParsedRecipe {
        let title = extractString(from: data["name"]) ?? "Extracted Recipe"
        let description = extractString(from: data["description"]) ?? ""

        let ingredientStrings = extractArray(from: data["recipeIngredient"])
        let ingredients = ingredientStrings.map { ParsedIngredient(name: $0, quantity: 1.0, unit: "item") }

        let instructionStrings = extractInstructions(from: data["recipeInstructions"])
        let instructions = instructionStrings.enumerated().map {
            ParsedInstruction(stepNumber: $0.offset + 1, text: $0.element, timerMinutes: nil)
        }

        let prepTime = extractDuration(from: data["prepTime"])
        let cookTime = extractDuration(from: data["cookTime"])
        let servings = extractInt(from: data["recipeYield"]) ?? 4
        let difficulty = determineDifficulty(totalMinutes: prepTime + cookTime)

        let categories = extractArray(from: data["recipeCategory"])
        let cuisineTypes = extractArray(from: data["recipeCuisine"])
        let dietaryInfo = extractArray(from: data["suitableForDiet"])

        return ParsedRecipe(
            title: title,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            prepTimeMinutes: prepTime,
            cookTimeMinutes: cookTime,
            servings: servings,
            difficulty: difficulty,
            categories: categories,
            cuisineTypes: cuisineTypes,
            dietaryInfo: dietaryInfo,
            nutritionInfo: nil,
            calories: nil
        )
    }

    // MARK: - Basic HTML Extraction

    private func extractFromBasicHTML(_ html: String, url: String) -> ParsedRecipe? {
        // Extract title from h1 or title tag
        var title = extractTextBetweenTags(html, tag: "h1").first ?? ""
        if title.isEmpty {
            title = extractTextBetweenTags(html, tag: "title").first ?? "Extracted Recipe"
        }
        title = title.components(separatedBy: "|").first?.trimmingCharacters(in: .whitespaces) ?? title

        // Extract meta description
        let descriptionPattern = #"<meta[^>]*name="description"[^>]*content="([^"]*)"[^>]*>"#
        let description = extractWithRegex(html, pattern: descriptionPattern).first ?? ""

        // Try to extract ingredients - look for common patterns
        let ingredientPatterns = [
            #"<li[^>]*class="[^"]*ingredient[^"]*"[^>]*>(.*?)</li>"#,
            #"<div[^>]*class="[^"]*ingredient[^"]*"[^>]*>(.*?)</div>"#
        ]

        var ingredients: [ParsedIngredient] = []
        for pattern in ingredientPatterns {
            let matches = extractWithRegex(html, pattern: pattern)
            if !matches.isEmpty {
                ingredients = matches.map { text in
                    let cleanText = cleanHTMLTags(text)
                    return ParsedIngredient(name: cleanText, quantity: 1.0, unit: "item")
                }
                break
            }
        }

        // Try to extract instructions
        let instructionPatterns = [
            #"<li[^>]*class="[^"]*instruction[^"]*"[^>]*>(.*?)</li>"#,
            #"<li[^>]*class="[^"]*step[^"]*"[^>]*>(.*?)</li>"#,
            #"<div[^>]*class="[^"]*instruction[^"]*"[^>]*>(.*?)</div>"#
        ]

        var instructions: [ParsedInstruction] = []
        for pattern in instructionPatterns {
            let matches = extractWithRegex(html, pattern: pattern)
            if !matches.isEmpty {
                instructions = matches.enumerated().map { index, text in
                    let cleanText = cleanHTMLTags(text)
                    return ParsedInstruction(stepNumber: index + 1, text: cleanText, timerMinutes: nil)
                }
                break
            }
        }

        // If we found data, return it
        if !ingredients.isEmpty && !instructions.isEmpty {
            return ParsedRecipe(
                title: title,
                description: description,
                ingredients: ingredients,
                instructions: instructions,
                prepTimeMinutes: 15,
                cookTimeMinutes: 30,
                servings: 4,
                difficulty: .medium,
                categories: ["Extracted"],
                cuisineTypes: [],
                dietaryInfo: [],
                nutritionInfo: nil,
                calories: nil
            )
        }

        return nil
    }

    // MARK: - HTML Parsing Helpers

    private func extractTextBetweenTags(_ html: String, tag: String) -> [String] {
        let pattern = "<\(tag)[^>]*>(.*?)</\(tag)>"
        return extractWithRegex(html, pattern: pattern)
    }

    private func extractWithRegex(_ text: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return []
        }

        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))

        return matches.compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            let range = match.range(at: 1)
            return nsString.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func cleanHTMLTags(_ text: String) -> String {
        var cleaned = text
        // Remove HTML tags
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // Decode HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Helper Methods

    private func extractString(from value: Any?) -> String? {
        if let str = value as? String {
            return str.trimmingCharacters(in: .whitespaces)
        }
        if let array = value as? [Any], let first = array.first {
            return String(describing: first).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    private func extractArray(from value: Any?) -> [String] {
        if let str = value as? String {
            return [str.trimmingCharacters(in: .whitespaces)]
        }
        if let array = value as? [Any] {
            return array.map { String(describing: $0).trimmingCharacters(in: .whitespaces) }
        }
        return []
    }

    private func extractInstructions(from value: Any?) -> [String] {
        if let array = value as? [[String: Any]] {
            return array.compactMap { dict in
                if let text = dict["text"] as? String {
                    return text.trimmingCharacters(in: .whitespaces)
                }
                return nil
            }
        }
        if let array = value as? [String] {
            return array.map { $0.trimmingCharacters(in: .whitespaces) }
        }
        return []
    }

    private func extractDuration(from value: Any?) -> Int {
        let str = String(describing: value ?? "")

        // Parse ISO 8601 duration (PT15M, PT1H30M, etc.)
        let pattern = #"PT(?:(\d+)H)?(?:(\d+)M)?"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: str, range: NSRange(str.startIndex..., in: str)) {
            var minutes = 0
            if let hoursRange = Range(match.range(at: 1), in: str),
               let hours = Int(str[hoursRange]) {
                minutes += hours * 60
            }
            if let minutesRange = Range(match.range(at: 2), in: str),
               let mins = Int(str[minutesRange]) {
                minutes += mins
            }
            return minutes
        }

        return 0
    }


    private func extractInt(from value: Any?) -> Int? {
        if let int = value as? Int {
            return int
        }
        if let str = value as? String {
            return Int(str)
        }
        if let array = value as? [Any], let first = array.first {
            return extractInt(from: first)
        }
        return nil
    }

    private func determineDifficulty(totalMinutes: Int) -> Difficulty {
        if totalMinutes <= 20 {
            return .easy
        } else if totalMinutes <= 45 {
            return .medium
        } else {
            return .advanced
        }
    }
}
