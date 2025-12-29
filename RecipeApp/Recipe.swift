import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var imageUrl: String
    @Attribute(.externalStorage) var imageData: Data?
    var ingredientsList: [String]
    var instructionsList: [String]
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    @Relationship(deleteRule: .cascade) var instructions: [Instruction]
    var prepTimeMinutes: Int
    var cookTimeMinutes: Int
    var servings: Int
    var difficulty: Difficulty
    var category: String
    var categories: [String]
    var cuisineTypes: [String]
    var dietaryInfo: [String]
    var rating: Double?
    var calories: Int?
    var sourceUrl: String?
    var sourceAttribution: String?
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var author: String?
    var tags: [String]
    var nutritionInfo: NutritionInfo?
    var reviewCount: Int?

    init(
        id: UUID = UUID(),
        title: String,
        summary: String = "",
        imageUrl: String = "",
        imageData: Data? = nil,
        ingredientsList: [String] = [],
        instructionsList: [String] = [],
        ingredients: [Ingredient] = [],
        instructions: [Instruction] = [],
        prepTimeMinutes: Int = 15,
        cookTimeMinutes: Int = 30,
        servings: Int = 4,
        difficulty: Difficulty = .medium,
        category: String = "Main Dish",
        categories: [String] = [],
        cuisineTypes: [String] = [],
        dietaryInfo: [String] = [],
        rating: Double? = nil,
        calories: Int? = nil,
        sourceUrl: String? = nil,
        sourceAttribution: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isFavorite: Bool = false,
        author: String? = nil,
        tags: [String] = [],
        nutritionInfo: NutritionInfo? = nil,
        reviewCount: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.imageUrl = imageUrl
        self.imageData = imageData
        self.ingredientsList = ingredientsList
        self.instructionsList = instructionsList
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.servings = servings
        self.difficulty = difficulty
        self.category = category
        self.categories = categories
        self.cuisineTypes = cuisineTypes
        self.dietaryInfo = dietaryInfo
        self.rating = rating
        self.calories = calories
        self.sourceUrl = sourceUrl
        self.sourceAttribution = sourceAttribution
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.author = author
        self.tags = tags
        self.nutritionInfo = nutritionInfo
        self.reviewCount = reviewCount
    }

    var totalTimeMinutes: Int {
        prepTimeMinutes + cookTimeMinutes
    }

    var formattedTotalTime: String {
        let hours = totalTimeMinutes / 60
        let minutes = totalTimeMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }

    var formattedPrepTime: String {
        let hours = prepTimeMinutes / 60
        let minutes = prepTimeMinutes % 60
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(minutes) min"
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case advanced = "Advanced"
}

// MARK: - Recipe Category
enum RecipeCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case breakfast = "Breakfast"
    case mainDish = "Main Dish"
    case dessert = "Dessert"
    case snack = "Snack"
    case salad = "Salad"
    case soup = "Soup"
    case beverage = "Beverage"

    var id: String { rawValue }
}
