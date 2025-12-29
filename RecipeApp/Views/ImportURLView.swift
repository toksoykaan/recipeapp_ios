import SwiftUI
import SwiftData

struct ImportURLView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var urlString = ""
    @State private var isLoading = false
    @State private var extractedRecipe: ParsedRecipe?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if extractedRecipe == nil {
                        // URL input section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Enter Recipe URL")
                                .font(.headline)

                            Text("Paste a URL from popular recipe websites like AllRecipes, Food Network, BBC Good Food, or any site with structured recipe data.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.secondary)
                                TextField("https://example.com/recipe", text: $urlString)
                                    .keyboardType(.URL)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()

                                if !urlString.isEmpty {
                                    Button {
                                        urlString = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            Button {
                                extractRecipe()
                            } label: {
                                if isLoading {
                                    HStack {
                                        ProgressView()
                                            .tint(.white)
                                        Text("Extracting...")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primaryOrange.opacity(0.7))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Label("Extract Recipe", systemImage: "arrow.down.circle.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(isValidURL ? Color.primaryOrange : Color.gray)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .disabled(!isValidURL || isLoading)
                        }
                        .padding()

                        if let error = errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                Text(error)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }

                        // Example websites
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Supported Websites")
                                .font(.headline)

                            VStack(spacing: 8) {
                                ExampleWebsiteRow(name: "AllRecipes", icon: "🥘")
                                ExampleWebsiteRow(name: "Food Network", icon: "📺")
                                ExampleWebsiteRow(name: "BBC Good Food", icon: "🇬🇧")
                                ExampleWebsiteRow(name: "Serious Eats", icon: "📖")
                                ExampleWebsiteRow(name: "Bon Appétit", icon: "👨‍🍳")
                            }
                        }
                        .padding()
                    } else if let recipe = extractedRecipe {
                        RecipePreviewCard(recipe: recipe)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Import from URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if extractedRecipe != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveRecipe()
                        }
                        .disabled(isLoading)
                    }
                }
            }
        }
    }

    private var isValidURL: Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme?.hasPrefix("http") == true
    }

    private func extractRecipe() {
        guard isValidURL else { return }

        isLoading = true
        errorMessage = nil
        extractedRecipe = nil

        Task {
            do {
                let recipe = try await WebScrapingService.shared.extractRecipe(from: urlString)

                await MainActor.run {
                    extractedRecipe = recipe
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to extract recipe: \(error.localizedDescription)\n\nPlease make sure the URL points to a valid recipe page."
                    isLoading = false
                }
            }
        }
    }

    private func saveRecipe() {
        guard let parsedRecipe = extractedRecipe else { return }

        let ingredients = parsedRecipe.ingredients.map { input in
            Ingredient(
                name: input.name,
                quantity: input.quantity,
                unit: input.unit
            )
        }

        let instructions = parsedRecipe.instructions.map { input in
            Instruction(
                stepNumber: input.stepNumber,
                text: input.text,
                timerMinutes: input.timerMinutes
            )
        }

        let recipe = Recipe(
            title: parsedRecipe.title,
            summary: parsedRecipe.description,
            ingredients: ingredients,
            instructions: instructions,
            prepTimeMinutes: parsedRecipe.prepTimeMinutes,
            cookTimeMinutes: parsedRecipe.cookTimeMinutes,
            servings: parsedRecipe.servings,
            difficulty: parsedRecipe.difficulty,
            category: parsedRecipe.categories.first ?? "Main Dish",
            categories: parsedRecipe.categories,
            cuisineTypes: parsedRecipe.cuisineTypes,
            dietaryInfo: parsedRecipe.dietaryInfo,
            calories: parsedRecipe.calories,
            sourceUrl: urlString,
            nutritionInfo: parsedRecipe.nutritionInfo
        )

        modelContext.insert(recipe)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save recipe: \(error.localizedDescription)"
        }
    }
}

struct ExampleWebsiteRow: View {
    let name: String
    let icon: String

    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            Text(name)
                .font(.body)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ImportURLView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
