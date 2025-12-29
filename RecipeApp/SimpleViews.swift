import SwiftUI
import SwiftData
import Combine

// MARK: - Placeholder Views (Replace with full versions later)

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🍳")
                .font(.system(size: 100))

            Text("RecipeVault")
                .font(.largeTitle.bold())

            Text("Your recipes will appear here")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MealPlanView: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar")
                .font(.system(size: 80))
                .foregroundColor(.primaryOrange)

            Text("Meal Planning")
                .font(.title.bold())
                .padding()

            Text("Plan your weekly meals here")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GroceryListView: View {
    var body: some View {
        VStack {
            Image(systemName: "cart.fill")
                .font(.system(size: 80))
                .foregroundColor(.secondaryGreen)

            Text("Grocery List")
                .font(.title.bold())
                .padding()

            Text("Your shopping list will appear here")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProfileView: View {
    @AppStorage("userName") private var userName = "Recipe Chef"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.primaryOrange, .secondaryGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text(String(userName.prefix(1)))
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading) {
                            Text(userName)
                                .font(.title3.bold())
                            Text("recipe.chef@recipevault.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("App") {
                    Label("Settings", systemImage: "gear")
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct AddRecipeOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOption: RecipeCreationOption?

    enum RecipeCreationOption: Identifiable {
        case createFromScratch
        case scanRecipe
        case importURL
        case generateAI

        var id: Self { self }
    }

    var body: some View {
        NavigationStack {
            List {
                Button {
                    selectedOption = .createFromScratch
                } label: {
                    Label("Create from Scratch", systemImage: "square.and.pencil")
                }

                Button {
                    selectedOption = .scanRecipe
                } label: {
                    Label("Scan Recipe", systemImage: "camera")
                }

                Button {
                    selectedOption = .importURL
                } label: {
                    Label("Import from URL", systemImage: "link")
                }

                Button {
                    selectedOption = .generateAI
                } label: {
                    Label("Generate with AI", systemImage: "sparkles")
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(item: $selectedOption) { option in
                switch option {
                case .createFromScratch:
                    CreateRecipeView()
                case .scanRecipe:
                    ScanRecipeView()
                case .importURL:
                    ImportURLView()
                case .generateAI:
                    AIGenerateView()
                }
            }
        }
    }
}

// MARK: - Placeholder ViewModels

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []

    init(repository: RecipeRepository) {
        // Placeholder
    }
}

class GroceryListViewModel: ObservableObject {
    @Published var items: [GroceryItem] = []

    init(repository: RecipeRepository) {
        // Placeholder
    }
}

// MARK: - Placeholder Repository

class RecipeRepository: ObservableObject {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}
