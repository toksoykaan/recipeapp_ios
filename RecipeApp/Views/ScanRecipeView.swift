import SwiftUI
import PhotosUI
import SwiftData

struct ScanRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var extractedRecipe: ParsedRecipe?
    @State private var errorMessage: String?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let selectedImage = selectedImage {
                        // Image preview
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primaryOrange, lineWidth: 2)
                            )
                            .padding(.horizontal)

                        if !isProcessing && extractedRecipe == nil {
                            // Action buttons
                            VStack(spacing: 12) {
                                Button {
                                    processImage()
                                } label: {
                                    Label("Extract Recipe", systemImage: "text.viewfinder")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.primaryOrange)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                Button {
                                    self.selectedImage = nil
                                } label: {
                                    Label("Choose Different Image", systemImage: "photo")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primaryOrange)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal)
                        }

                        if isProcessing {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Processing image...")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }

                        if let recipe = extractedRecipe {
                            RecipePreviewCard(recipe: recipe)
                                .padding(.horizontal)
                        }

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
                    } else {
                        // Initial state - no image selected
                        VStack(spacing: 20) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 80))
                                .foregroundColor(.primaryOrange)

                            Text("Scan a Recipe")
                                .font(.title.bold())

                            Text("Take a photo or select an image of a recipe from your cookbook, recipe card, or any printed material.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                Button {
                                    sourceType = .camera
                                    showingImagePicker = true
                                } label: {
                                    Label("Take Photo", systemImage: "camera.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.primaryOrange)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                Button {
                                    sourceType = .photoLibrary
                                    showingImagePicker = true
                                } label: {
                                    Label("From Gallery", systemImage: "photo.on.rectangle")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.secondaryGreen)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Scan Recipe")
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
                        .disabled(isProcessing)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
        }
    }

    private func processImage() {
        guard let image = selectedImage else { return }

        isProcessing = true
        errorMessage = nil
        extractedRecipe = nil

        Task {
            do {
                // Preprocess the image
                let processedImage = VisionOCRService.shared.preprocessImage(image)

                // Extract text using Vision
                let extractedText = try await VisionOCRService.shared.extractText(from: processedImage)

                if extractedText.isEmpty {
                    throw RecipeError.parsingError
                }

                // Parse with AI
                let recipe = try await RecipeParserService.shared.parseRecipeWithAI(extractedText: extractedText)

                await MainActor.run {
                    extractedRecipe = recipe
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to extract recipe: \(error.localizedDescription)"
                    isProcessing = false
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

// MARK: - Supporting Views

struct RecipePreviewCard: View {
    let recipe: ParsedRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Recipe Extracted Successfully!")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(recipe.title)
                    .font(.title2.bold())

                if !recipe.description.isEmpty {
                    Text(recipe.description)
                        .foregroundColor(.secondary)
                }

                // Recipe metadata
                HStack(spacing: 12) {
                    MetadataChip(icon: "clock", text: "\(recipe.prepTimeMinutes + recipe.cookTimeMinutes) min", color: .orange)
                    MetadataChip(icon: "fork.knife", text: "\(recipe.servings) servings", color: .blue)
                    MetadataChip(icon: "chart.bar", text: recipe.difficulty.rawValue, color: .purple)
                }

                Divider()

                // Ingredients
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients (\(recipe.ingredients.count))")
                        .font(.headline)

                    ForEach(recipe.ingredients.prefix(5), id: \.name) { ingredient in
                        HStack {
                            Circle()
                                .fill(Color.primaryOrange)
                                .frame(width: 6, height: 6)
                            Text("\(String(format: "%.1f", ingredient.quantity)) \(ingredient.unit) \(ingredient.name)")
                                .font(.body)
                        }
                    }

                    if recipe.ingredients.count > 5 {
                        Text("... and \(recipe.ingredients.count - 5) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions (\(recipe.instructions.count) steps)")
                        .font(.headline)

                    ForEach(recipe.instructions.prefix(3), id: \.stepNumber) { instruction in
                        HStack(alignment: .top) {
                            Text("\(instruction.stepNumber).")
                                .font(.headline)
                                .foregroundColor(.primaryOrange)
                                .frame(width: 30, alignment: .leading)
                            Text(instruction.text)
                                .font(.body)
                        }
                    }

                    if recipe.instructions.count > 3 {
                        Text("... and \(recipe.instructions.count - 3) more steps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}

struct MetadataChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ScanRecipeView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
