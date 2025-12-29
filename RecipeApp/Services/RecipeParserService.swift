import Foundation

/// Service for parsing recipe text using AI
class RecipeParserService {
    static let shared = RecipeParserService()

    private let cloudflareURL = "https://recipeappphotoparser.green-snow-173b.workers.dev/"

    private init() {}

    /// Parse extracted text into a structured recipe using AI
    func parseRecipeWithAI(extractedText: String) async throws -> ParsedRecipe {
        let prompt = buildPrompt(extractedText: extractedText)

        let requestBody: [String: Any] = [
            "prompt": prompt,
            "max_tokens": 1500
        ]

        guard let url = URL(string: cloudflareURL) else {
            throw RecipeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RecipeError.serverError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let coverLetter = json["coverLetter"] as? [String: Any] else {
            throw RecipeError.invalidResponse
        }

        return try parseRecipeJSON(coverLetter)
    }

    private func buildPrompt(extractedText: String) -> String {
        return """
        Parse the following text into a structured recipe format. IMPORTANT: Keep everything in the ORIGINAL LANGUAGE of the handwritten text!

        LANGUAGE PRESERVATION RULES:
        1. Detect the primary language used in the recipe
        2. Keep ALL text in that original language - DO NOT TRANSLATE
        3. Only clean up OCR errors and standardize formatting
        4. For mixed text (e.g., "1 tbsp şeker"), keep it as is
        5. Standardize common unit abbreviations within the same language:
           - If Turkish: "yemek kaşığı" or "yk" → "yemek kaşığı"
           - If English: "tablespoon" → "tbsp"
           - Keep metric units as written (g, kg, ml, l)
        6. Fix obvious OCR mistakes but preserve the original language

        Text to parse:
        \(extractedText)

        Return a JSON object with this exact structure (keep all text in original language):
        {
          "title": "Recipe Title",
          "description": "Brief description of the recipe",
          "servings": 4,
          "prepTimeMinutes": 15,
          "cookTimeMinutes": 30,
          "difficulty": "Easy|Medium|Hard",
          "categories": ["Breakfast", "Lunch", "Dinner", "Snack", "Dessert"],
          "cuisineTypes": ["Italian", "Mexican", "Asian", etc.],
          "dietaryInfo": ["Vegetarian", "Vegan", "Gluten-Free", etc.],
          "ingredients": [
            {
              "name": "ingredient name",
              "quantity": 1.5,
              "unit": "cup|tsp|tbsp|oz|lb|g|kg|ml|l|piece|clove|adet|su bardağı|yemek kaşığı|tatlı kaşığı|etc"
            }
          ],
          "instructions": [
            {
              "text": "Step description",
              "timerMinutes": null or number
            }
          ],
          "nutritionPerServing": {
            "calories": 250,
            "protein": 10,
            "carbs": 30,
            "fat": 12,
            "fiber": 5,
            "sugar": 8,
            "sodium": 300
          }
        }

        Important Instructions:
        - Extract quantities and units accurately from ingredient lines
        - Keep ALL text in the original language - NO TRANSLATION
        - Preserve units as written (yemek kaşığı, tbsp, cup, ml, g, etc.)
        - Number the instructions in order if not already numbered
        - Identify timer information in instructions
        - Always provide nutritional estimates based on ingredients
        """
    }

    private func parseRecipeJSON(_ json: [String: Any]) throws -> ParsedRecipe {
        let title = json["title"] as? String ?? "Untitled Recipe"
        let description = json["description"] as? String ?? ""
        let servings = json["servings"] as? Int ?? 4
        let prepTimeMinutes = json["prepTimeMinutes"] as? Int ?? 15
        let cookTimeMinutes = json["cookTimeMinutes"] as? Int ?? 30
        let difficultyStr = json["difficulty"] as? String ?? "Medium"
        let difficulty = Difficulty(rawValue: difficultyStr) ?? .medium

        let categories = json["categories"] as? [String] ?? []
        let cuisineTypes = json["cuisineTypes"] as? [String] ?? []
        let dietaryInfo = json["dietaryInfo"] as? [String] ?? []

        var ingredients: [ParsedIngredient] = []
        if let ingredientsArray = json["ingredients"] as? [[String: Any]] {
            for ing in ingredientsArray {
                let ingredient = ParsedIngredient(
                    name: ing["name"] as? String ?? "",
                    quantity: ing["quantity"] as? Double ?? 1.0,
                    unit: ing["unit"] as? String ?? "piece"
                )
                ingredients.append(ingredient)
            }
        }

        var instructions: [ParsedInstruction] = []
        if let instructionsArray = json["instructions"] as? [[String: Any]] {
            for (index, inst) in instructionsArray.enumerated() {
                let instruction = ParsedInstruction(
                    stepNumber: index + 1,
                    text: inst["text"] as? String ?? "",
                    timerMinutes: inst["timerMinutes"] as? Int
                )
                instructions.append(instruction)
            }
        }

        var nutritionInfo: NutritionInfo?
        if let nutritionData = json["nutritionPerServing"] as? [String: Any] {
            nutritionInfo = NutritionInfo(
                protein: nutritionData["protein"] as? Double,
                carbohydrates: nutritionData["carbs"] as? Double,
                fat: nutritionData["fat"] as? Double,
                fiber: nutritionData["fiber"] as? Double,
                sodium: nutritionData["sodium"] as? Double,
                saturatedFat: nutritionData["saturatedFat"] as? Double,
                cholesterol: nutritionData["cholesterol"] as? Double,
                sugar: nutritionData["sugar"] as? Double
            )
        }

        let calories = (json["nutritionPerServing"] as? [String: Any])?["calories"] as? Int

        return ParsedRecipe(
            title: title,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            servings: servings,
            difficulty: difficulty,
            categories: categories,
            cuisineTypes: cuisineTypes,
            dietaryInfo: dietaryInfo,
            nutritionInfo: nutritionInfo,
            calories: calories
        )
    }
}

// MARK: - Supporting Types

struct ParsedRecipe {
    let title: String
    let description: String
    let ingredients: [ParsedIngredient]
    let instructions: [ParsedInstruction]
    let prepTimeMinutes: Int
    let cookTimeMinutes: Int
    let servings: Int
    let difficulty: Difficulty
    let categories: [String]
    let cuisineTypes: [String]
    let dietaryInfo: [String]
    let nutritionInfo: NutritionInfo?
    let calories: Int?
}

struct ParsedIngredient {
    let name: String
    let quantity: Double
    let unit: String
}

struct ParsedInstruction {
    let stepNumber: Int
    let text: String
    let timerMinutes: Int?
}

enum RecipeError: LocalizedError {
    case invalidURL
    case serverError
    case invalidResponse
    case parsingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error occurred"
        case .invalidResponse:
            return "Invalid response from server"
        case .parsingError:
            return "Failed to parse recipe data"
        }
    }
}
