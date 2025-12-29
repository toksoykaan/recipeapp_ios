import SwiftUI
import SwiftData
import Combine

// MARK: - Recipe Card View
struct RecipeCardView: View {
    let recipe: Recipe
    @Environment(\.colorScheme) private var colorScheme

    private var cardBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section (4:3 Aspect Ratio)
            recipeImage
                .frame(height: 120)
                .clipped()

            // Content Section
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(recipe.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                // Metadata Row
                HStack(spacing: 12) {
                    // Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(recipe.formattedPrepTime)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    // Difficulty
                    Text(recipe.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    @ViewBuilder
    private var recipeImage: some View {
        if let imageData = recipe.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(4/3, contentMode: .fill)
        } else if !recipe.imageUrl.isEmpty {
            AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(4/3, contentMode: .fill)
                case .failure:
                    imagePlaceholder
                @unknown default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color(uiColor: .tertiarySystemGroupedBackground))
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
    }
}

// MARK: - Category Filter Pill
struct CategoryPill: View {
    let category: RecipeCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.appTint : Color(uiColor: .tertiarySystemGroupedBackground))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State View
struct RecipesEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🍳")
                .font(.system(size: 100))

            Text("No recipes yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Add your first recipe by tapping the + button")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

// MARK: - Recipes View (Main Screen)
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]

    @Binding var searchText: String
    @State private var selectedCategory: RecipeCategory = .all

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var filteredRecipes: [Recipe] {
        var result = recipes

        // Filter by category
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory.rawValue }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Category Filter Bar
                categoryFilterBar
                    .padding(.top, 8)

                // Content
                if recipes.isEmpty {
                    RecipesEmptyStateView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                } else if filteredRecipes.isEmpty {
                    // No results for filter/search
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No recipes found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    // Recipe Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredRecipes, id: \.id) { recipe in
                            RecipeCardView(recipe: recipe)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RecipeCategory.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MealPlanView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("📅")
                .font(.system(size: 100))

            Text("Meal Planning")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Plan your weekly meals here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GroceryListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🛒")
                .font(.system(size: 100))

            Text("Grocery List")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Your shopping list will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
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
