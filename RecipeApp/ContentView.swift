//
//  ContentView.swift
//  RecipeApp - RecipeVault
//
//  Created by Kaan TOKSOY on 23.12.2025.
//

import SwiftUI
import SwiftData

// MARK: - Tab Enum
enum TabItem: String, CaseIterable {
    case recipes = "Recipes"
    case mealPlan = "Meal Plan"
    case grocery = "Grocery"

    var symbol: String {
        switch self {
        case .recipes: return AppIcon.recipes
        case .mealPlan: return AppIcon.calendar
        case .grocery: return AppIcon.groceryList
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var activeTab: TabItem = .recipes
    @State private var showProfile = false
    @State private var showAddRecipe = false
    @StateObject private var recipeViewModel: RecipeViewModel
    @StateObject private var groceryViewModel: GroceryListViewModel
    @Namespace private var tabAnimation

    init() {
        let placeholder = RecipeRepository(modelContext: ModelContext(try! ModelContainer(for: Schema([]))))
        _recipeViewModel = StateObject(wrappedValue: RecipeViewModel(repository: placeholder))
        _groceryViewModel = StateObject(wrappedValue: GroceryListViewModel(repository: placeholder))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Text(activeTab.rawValue)
                        .font(.title.bold())

                    Spacer()

                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: AppIcon.profile)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color.primaryOrange)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, geometry.safeAreaInsets.top)
                .padding(.bottom, 12)
                .background(colorScheme == .dark ? Color.Dark.background : Color.Light.background)

                // Content
                ZStack(alignment: .bottom) {
                    TabContentView(activeTab: activeTab, recipeViewModel: recipeViewModel, groceryViewModel: groceryViewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, 68)

                    CustomTabBar(activeTab: $activeTab, showAddRecipe: $showAddRecipe, namespace: tabAnimation)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
            }
            .ignoresSafeArea(edges: [.top, .bottom])
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddRecipe) {
            AddRecipeOptionsSheet()
                .environmentObject(recipeViewModel)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .onAppear {
            _ = RecipeRepository(modelContext: modelContext)
        }
    }
}

// MARK: - Tab Content View with Transitions
struct TabContentView: View {
    let activeTab: TabItem
    @ObservedObject var recipeViewModel: RecipeViewModel
    @ObservedObject var groceryViewModel: GroceryListViewModel

    var body: some View {
        ZStack {
            switch activeTab {
            case .recipes:
                HomeView()
                    .environmentObject(recipeViewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .mealPlan:
                MealPlanView()
                    .environmentObject(recipeViewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .grocery:
                GroceryListView()
                    .environmentObject(groceryViewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeTab)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var activeTab: TabItem
    @Binding var showAddRecipe: Bool
    var namespace: Namespace.ID
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            // Tab buttons with glass effect
            HStack(spacing: 0) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    TabBarButton(tab: tab, isActive: activeTab == tab, namespace: namespace) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            activeTab = tab
                        }
                        HapticFeedback.light.generate()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background {
                ZStack {
                    // Glass blur background
                    Capsule()
                        .fill(.ultraThinMaterial)

                    // Subtle border
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 20, x: 0, y: 10)
            }

            // Add Button with glass effect
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showAddRecipe = true
                }
                HapticFeedback.medium.generate()
            } label: {
                Image(systemName: AppIcon.add)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primaryOrange, .secondaryGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .background {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)

                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5),
                                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.5
                                )
                        }
                        .shadow(color: .primaryOrange.opacity(0.25), radius: 15, x: 0, y: 8)
                    }
            }
            .buttonStyle(AddButtonStyle())
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabItem
    let isActive: Bool
    var namespace: Namespace.ID
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var foregroundColor: Color {
        if isActive {
            return .primaryOrange
        }
        return colorScheme == .dark ? Color.gray.opacity(0.8) : Color.gray
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 20, weight: .medium))
                    .symbolVariant(isActive ? .fill : .none)
                    .symbolEffect(.bounce, value: isActive)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isActive ? .semibold : .medium))
                    .lineLimit(1)
            }
            .foregroundColor(foregroundColor)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background {
                if isActive {
                    Capsule()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06))
                        .matchedGeometryEffect(id: "activeTab", in: namespace)
                }
            }
        }
        .buttonStyle(TabButtonStyle())
    }
}

// MARK: - Button Styles
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, GroceryItem.self, MealPlan.self])
}
