import SwiftUI
import SwiftData

struct AIGenerateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var prompt = ""
    @State private var availableIngredients = ""
    @State private var selectedCuisine = "Any"
    @State private var selectedDifficulty = "Any"
    @State private var selectedMealType = "Any"
    @State private var servings = 4
    @State private var maxCookingTime = 30

    @State private var isGenerating = false
    @State private var generatedRecipe: ParsedRecipe?
    @State private var errorMessage: String?

    let cuisineOptions = ["Any", "Italian", "Mexican", "Asian", "American", "Indian", "Mediterranean", "French", "Turkish"]
    let difficultyOptions = ["Any", "Easy", "Medium", "Hard"]
    let mealTypeOptions = ["Any", "Breakfast", "Lunch", "Dinner", "Snack", "Dessert"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if generatedRecipe == nil {
                        // Input form
                        VStack(alignment: .leading, spacing: 16) {
                            // Prompt section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What would you like to cook?")
                                    .font(.headline)

                                Text("Describe what you're craving or let AI surprise you with creative recipe ideas.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                TextField("e.g., A spicy pasta dish or Healthy breakfast", text: $prompt, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(2...4)
                            }

                            Divider()

                            // Available ingredients section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Ingredients (Optional)")
                                    .font(.headline)

                                Text("List ingredients you have. AI will create a recipe using these.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                TextField("e.g., chicken, tomatoes, onions, garlic", text: $availableIngredients, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...5)
                            }

                            Divider()

                            // Preferences section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Preferences")
                                    .font(.headline)

                                // Cuisine and Difficulty
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading) {
                                        Text("Cuisine")
                                            .font(.subheadline)
                                        Picker("Cuisine", selection: $selectedCuisine) {
                                            ForEach(cuisineOptions, id: \.self) { cuisine in
                                                Text(cuisine).tag(cuisine)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }

                                    VStack(alignment: .leading) {
                                        Text("Difficulty")
                                            .font(.subheadline)
                                        Picker("Difficulty", selection: $selectedDifficulty) {
                                            ForEach(difficultyOptions, id: \.self) { difficulty in
                                                Text(difficulty).tag(difficulty)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }

                                // Meal Type
                                VStack(alignment: .leading) {
                                    Text("Meal Type")
                                        .font(.subheadline)
                                    Picker("Meal Type", selection: $selectedMealType) {
                                        ForEach(mealTypeOptions, id: \.self) { mealType in
                                            Text(mealType).tag(mealType)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }

                                // Servings and Cooking Time
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Servings: \(servings)")
                                        .font(.subheadline)
                                    Slider(value: Binding(
                                        get: { Double(servings) },
                                        set: { servings = Int($0) }
                                    ), in: 1...12, step: 1)
                                    .tint(.primaryOrange)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Max Cooking Time: \(maxCookingTime) min")
                                        .font(.subheadline)
                                    Slider(value: Binding(
                                        get: { Double(maxCookingTime) },
                                        set: { maxCookingTime = Int($0) }
                                    ), in: 10...120, step: 10)
                                    .tint(.primaryOrange)
                                }
                            }

                            // Generate button
                            Button {
                                generateRecipe()
                            } label: {
                                if isGenerating {
                                    HStack {
                                        ProgressView()
                                            .tint(.white)
                                        Text("Generating Recipe...")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primaryOrange.opacity(0.7))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Label("Generate Recipe", systemImage: "sparkles")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(isValid ? Color.primaryOrange : Color.gray)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .disabled(!isValid || isGenerating)
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
                    } else if let recipe = generatedRecipe {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.primaryOrange)
                                    .font(.title2)
                                Text("AI Generated Recipe")
                                    .font(.headline)
                                    .foregroundColor(.primaryOrange)
                            }
                            .padding(.top)

                            RecipePreviewCard(recipe: recipe)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Generate with AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if generatedRecipe != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveRecipe()
                        }
                        .disabled(isGenerating)
                    }
                }
            }
        }
    }

    private var isValid: Bool {
        !prompt.trimmingCharacters(in: .whitespaces).isEmpty ||
        !availableIngredients.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func generateRecipe() {
        isGenerating = true
        errorMessage = nil
        generatedRecipe = nil

        Task {
            do {
                // Build the AI prompt
                let aiPrompt = buildAIPrompt()

                // Call AI service (using the same parser service with a custom prompt)
                let recipe = try await RecipeParserService.shared.parseRecipeWithAI(extractedText: aiPrompt)

                await MainActor.run {
                    generatedRecipe = recipe
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate recipe: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }

    private func buildAIPrompt() -> String {
        var promptParts: [String] = []

        if !prompt.isEmpty {
            promptParts.append("Recipe idea: \(prompt)")
        }

        if !availableIngredients.isEmpty {
            promptParts.append("Available ingredients: \(availableIngredients)")
        }

        if selectedCuisine != "Any" {
            promptParts.append("Cuisine: \(selectedCuisine)")
        }

        if selectedDifficulty != "Any" {
            promptParts.append("Difficulty: \(selectedDifficulty)")
        }

        if selectedMealType != "Any" {
            promptParts.append("Meal type: \(selectedMealType)")
        }

        promptParts.append("Servings: \(servings)")
        promptParts.append("Maximum cooking time: \(maxCookingTime) minutes")

        let fullPrompt = """
        Generate a complete recipe based on the following requirements:

        \(promptParts.joined(separator: "\n"))

        Please create a detailed recipe with:
        - A creative and appealing title
        - A brief description
        - Complete list of ingredients with quantities
        - Step-by-step cooking instructions
        - Estimated prep and cook times
        - Nutritional information

        Make sure the recipe is practical and uses the available ingredients if specified.
        """

        return fullPrompt
    }

    private func saveRecipe() {
        guard let parsedRecipe = generatedRecipe else { return }

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

        var categories = parsedRecipe.categories
        if !categories.contains("AI Generated") {
            categories.append("AI Generated")
        }

        let recipe = Recipe(
            title: parsedRecipe.title,
            descriptionText: parsedRecipe.description,
            ingredients: ingredients,
            instructions: instructions,
            prepTimeMinutes: parsedRecipe.prepTimeMinutes,
            cookTimeMinutes: parsedRecipe.cookTimeMinutes,
            servings: parsedRecipe.servings,
            difficulty: parsedRecipe.difficulty,
            categories: categories,
            cuisineTypes: parsedRecipe.cuisineTypes,
            dietaryInfo: parsedRecipe.dietaryInfo,
            calories: parsedRecipe.calories,
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

#Preview {
    AIGenerateView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
