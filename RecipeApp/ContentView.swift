//
//  ContentView.swift
//  RecipeApp - RecipeVault
//
//  Created by Kaan TOKSOY on 23.12.2025.
//

import SwiftUI
import SwiftData

// MARK: - Main Content View (iOS 26 Liquid Glass Ready)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int = 0
    @State private var showProfile = false
    @State private var showAddRecipe = false
    @State private var searchText = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Recipes Tab
            NavigationStack {
                HomeView()
                    .navigationTitle("Recipes")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showProfile = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Color.appTint)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Recipes", systemImage: "book.fill")
            }
            .tag(0)

            // MARK: - Meal Plan Tab
            NavigationStack {
                MealPlanView()
                    .navigationTitle("Meal Plan")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showProfile = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Color.appTint)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Meal Plan", systemImage: "calendar")
            }
            .tag(1)

            // MARK: - Grocery Tab
            NavigationStack {
                GroceryListView()
                    .navigationTitle("Grocery")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showProfile = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Color.appTint)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Grocery", systemImage: "cart.fill")
            }
            .tag(2)
        }
        .tint(Color.appTint)
        .sheet(isPresented: $showAddRecipe) {
            AddRecipeOptionsSheet()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .overlay(alignment: .bottomTrailing) {
            // Floating Add Button (right side, aligned with tab bar)
            addButton
                .padding(.trailing, 16)
                .padding(.bottom, 90)
        }
    }

    // MARK: - Floating Add Button
    private var addButton: some View {
        Button {
            HapticFeedback.medium.generate()
            showAddRecipe = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.appTint)
                .clipShape(Circle())
                .shadow(color: Color.appTint.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, GroceryItem.self, MealPlan.self])
}
