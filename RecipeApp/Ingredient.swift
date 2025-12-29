import Foundation
import SwiftData

@Model
final class Ingredient {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.notes = notes
    }
}
