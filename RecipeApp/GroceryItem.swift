import Foundation
import SwiftData

@Model
final class GroceryItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var isChecked: Bool
    var quantity: String?
    var recipeId: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: String = "Other",
        isChecked: Bool = false,
        quantity: String? = nil,
        recipeId: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.isChecked = isChecked
        self.quantity = quantity
        self.recipeId = recipeId
        self.createdAt = createdAt
    }
}
