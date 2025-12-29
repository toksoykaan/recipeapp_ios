//
//  ContentView.swift
//  RecipeApp - RecipeVault
//
//  Created by Kaan TOKSOY on 23.12.2025.
//

import SwiftUI
import SwiftData

// MARK: - Tab Enum
enum AppTab: Int, CaseIterable {
    case recipes = 0
    case mealPlan = 1
    case grocery = 2

    var title: String {
        switch self {
        case .recipes: return "Recipes"
        case .mealPlan: return "Meal Plan"
        case .grocery: return "Grocery"
        }
    }

    var icon: String {
        switch self {
        case .recipes: return "book"
        case .mealPlan: return "calendar"
        case .grocery: return "cart"
        }
    }

    var selectedIcon: String {
        switch self {
        case .recipes: return "book.fill"
        case .mealPlan: return "calendar"
        case .grocery: return "cart.fill"
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .recipes
    @State private var showProfile = false
    @State private var showAddRecipe = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .recipes:
                    NavigationStack {
                        HomeView()
                            .navigationTitle("Recipes")
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    profileButton
                                }
                            }
                    }
                case .mealPlan:
                    NavigationStack {
                        MealPlanView()
                            .navigationTitle("Meal Plan")
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    profileButton
                                }
                            }
                    }
                case .grocery:
                    NavigationStack {
                        GroceryListView()
                            .navigationTitle("Grocery")
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    profileButton
                                }
                            }
                    }
                }
            }
            .padding(.bottom, 80) // Space for custom tab bar

            // Custom Tab Bar with FAB
            customTabBar
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddRecipe) {
            AddRecipeOptionsSheet()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }

    // MARK: - Profile Button
    private var profileButton: some View {
        Button {
            showProfile = true
        } label: {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 17))
                .foregroundStyle(Color.appTint)
        }
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 8) {
            // Tab Items Container
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())

            // FAB - Same row, next to tab bar
            addButton
        }
    }

    // MARK: - Tab Button
    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
            HapticFeedback.light.generate()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20))
                    .fontWeight(selectedTab == tab ? .semibold : .regular)

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? Color.appTint : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background {
                if selectedTab == tab {
                    Capsule()
                        .fill(Color.appTint.opacity(0.12))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Button (FAB)
    private var addButton: some View {
        Button {
            HapticFeedback.medium.generate()
            showAddRecipe = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.appTint)
                .clipShape(Circle())
                .shadow(color: Color.appTint.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, GroceryItem.self, MealPlan.self])
}
