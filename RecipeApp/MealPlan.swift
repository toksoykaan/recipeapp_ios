import Foundation
import SwiftData

@Model
final class MealPlan {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mealType: MealType
    var recipeId: UUID
    var servings: Int
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipeId: UUID,
        servings: Int = 4,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipeId = recipeId
        self.servings = servings
        self.notes = notes
        self.createdAt = createdAt
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}
