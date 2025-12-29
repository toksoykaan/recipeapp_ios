import Foundation

struct NutritionInfo: Codable, Hashable {
    var protein: Double?
    var carbohydrates: Double?
    var fat: Double?
    var fiber: Double?
    var sodium: Double?
    var saturatedFat: Double?
    var cholesterol: Double?
    var sugar: Double?

    init(
        protein: Double? = nil,
        carbohydrates: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sodium: Double? = nil,
        saturatedFat: Double? = nil,
        cholesterol: Double? = nil,
        sugar: Double? = nil
    ) {
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.saturatedFat = saturatedFat
        self.cholesterol = cholesterol
        self.sugar = sugar
    }
}
