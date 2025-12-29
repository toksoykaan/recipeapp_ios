import SwiftUI
import SwiftData

struct CreateRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var prepTime = 15
    @State private var cookTime = 30
    @State private var servings = 4
    @State private var difficulty: Difficulty = .medium
    @State private var ingredients: [IngredientInput] = []
    @State private var instructions = ""
    @State private var categories: [String] = []
    @State private var cuisineTypes: [String] = []

    @State private var showingIngredientSheet = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Details") {
                    TextField("Recipe Name", text: $title)
                        .font(.headline)

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Cooking Information") {
                    HStack {
                        Text("Prep Time")
                        Spacer()
                        Stepper("\(prepTime) min", value: $prepTime, in: 5...180, step: 5)
                    }

                    HStack {
                        Text("Cook Time")
                        Spacer()
                        Stepper("\(cookTime) min", value: $cookTime, in: 5...300, step: 5)
                    }

                    HStack {
                        Text("Servings")
                        Spacer()
                        Stepper("\(servings)", value: $servings, in: 1...20)
                    }

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }

                Section {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ingredients[index].name)
                                    .font(.body)
                                Text("\(String(format: "%.1f", ingredients[index].quantity)) \(ingredients[index].unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                ingredients.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button {
                        showingIngredientSheet = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    if ingredients.isEmpty {
                        Text("Add at least one ingredient")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Instructions") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 150)
                        .overlay(alignment: .topLeading) {
                            if instructions.isEmpty {
                                Text("Enter cooking instructions here...\n\nEach new line will be a separate step.")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle("Create Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .sheet(isPresented: $showingIngredientSheet) {
                IngredientInputSheet { ingredient in
                    ingredients.append(ingredient)
                }
            }
        }
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !ingredients.isEmpty &&
        !instructions.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func saveRecipe() {
        isSaving = true

        // Create ingredients
        let recipeIngredients = ingredients.enumerated().map { index, input in
            Ingredient(
                name: input.name,
                quantity: input.quantity,
                unit: input.unit
            )
        }

        // Create instructions from text
        let instructionLines = instructions
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let recipeInstructions = instructionLines.enumerated().map { index, text in
            Instruction(
                stepNumber: index + 1,
                text: text
            )
        }

        // Create recipe
        let recipe = Recipe(
            title: title.trimmingCharacters(in: .whitespaces),
            descriptionText: description.trimmingCharacters(in: .whitespaces),
            ingredients: recipeIngredients,
            instructions: recipeInstructions,
            prepTimeMinutes: prepTime,
            cookTimeMinutes: cookTime,
            servings: servings,
            difficulty: difficulty,
            categories: categories,
            cuisineTypes: cuisineTypes
        )

        modelContext.insert(recipe)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving recipe: \(error)")
        }

        isSaving = false
    }
}

// MARK: - Supporting Views

struct IngredientInput {
    var name: String
    var quantity: Double
    var unit: String
}

struct IngredientInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (IngredientInput) -> Void

    @State private var name = ""
    @State private var quantity = 1.0
    @State private var unit = "cup"

    let commonUnits = ["cup", "tbsp", "tsp", "oz", "lb", "g", "kg", "ml", "l", "piece", "clove"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Ingredient Name", text: $name)

                HStack {
                    Text("Quantity")
                    Spacer()
                    TextField("Amount", value: $quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                Picker("Unit", selection: $unit) {
                    ForEach(commonUnits, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(IngredientInput(name: name, quantity: quantity, unit: unit))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateRecipeView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
