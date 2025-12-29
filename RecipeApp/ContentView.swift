//
//  ContentView.swift
//  RecipeApp - RecipeVault
//
//  Created by Kaan TOKSOY on 23.12.2025.
//

import SwiftUI
import SwiftData

// MARK: - Tab Enum
enum AppTab: String, CaseIterable {
    case recipes = "Recipes"
    case mealPlan = "Meal Plan"
    case grocery = "Grocery"

    var icon: String {
        switch self {
        case .recipes: return "book"
        case .mealPlan: return "calendar"
        case .grocery: return "cart"
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var activeTab: AppTab = .recipes
    @State private var showProfile = false
    @State private var showAddRecipe = false
    @Namespace private var tabAnimation

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content with NavigationStack
            TabContentView(activeTab: activeTab, showProfile: $showProfile)
                .padding(.bottom, 80)

            // Custom Tab Bar with FAB
            CustomTabBar(
                activeTab: $activeTab,
                showAddRecipe: $showAddRecipe,
                namespace: tabAnimation
            )
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
}

// MARK: - Tab Content View with Transitions
struct TabContentView: View {
    let activeTab: AppTab
    @Binding var showProfile: Bool

    var body: some View {
        ZStack {
            switch activeTab {
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
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

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
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

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
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeTab)
    }

    private var profileButton: some View {
        Button {
            showProfile = true
        } label: {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 17))
                .foregroundStyle(Color.appTint)
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var activeTab: AppTab
    @Binding var showAddRecipe: Bool
    var namespace: Namespace.ID
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            // Tab buttons with glass effect
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
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
                    Capsule()
                        .fill(.ultraThinMaterial)

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

            // Add Button (FAB)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showAddRecipe = true
                }
                HapticFeedback.medium.generate()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.appTint)
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
                        .shadow(color: Color.appTint.opacity(0.25), radius: 15, x: 0, y: 8)
                    }
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: AppTab
    let isActive: Bool
    var namespace: Namespace.ID
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolVariant(isActive ? .fill : .none)
                    .symbolEffect(.bounce, value: isActive)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isActive ? .semibold : .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isActive ? Color.appTint : .secondary)
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
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, GroceryItem.self, MealPlan.self])
}
