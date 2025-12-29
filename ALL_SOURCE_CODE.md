# 🎉 RecipeVault - Complete Source Code

Copy each section below into the corresponding file in your Xcode project.

---

## 📁 MODELS (Create these in RecipeApp project)

### Recipe.swift
```swift
import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var title: String
    var descriptionText: String
    var imageUrl: String
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    @Relationship(deleteRule: .cascade) var instructions: [Instruction]
    var prepTimeMinutes: Int
    var cookTimeMinutes: Int
    var servings: Int
    var difficulty: Difficulty
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
        descriptionText: String = "",
        imageUrl: String = "",
        ingredients: [Ingredient] = [],
        instructions: [Instruction] = [],
        prepTimeMinutes: Int = 15,
        cookTimeMinutes: Int = 30,
        servings: Int = 4,
        difficulty: Difficulty = .medium,
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
        self.descriptionText = descriptionText
        self.imageUrl = imageUrl
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.servings = servings
        self.difficulty = difficulty
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
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case advanced = "Advanced"
}
```

### Ingredient.swift
```swift
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
```

### Instruction.swift
```swift
import Foundation
import SwiftData

@Model
final class Instruction {
    @Attribute(.unique) var id: UUID
    var stepNumber: Int
    var text: String
    var timerMinutes: Int?
    var imageUrl: String?

    init(
        id: UUID = UUID(),
        stepNumber: Int,
        text: String,
        timerMinutes: Int? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.text = text
        self.timerMinutes = timerMinutes
        self.imageUrl = imageUrl
    }
}
```

### NutritionInfo.swift
```swift
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
```

### GroceryItem.swift
```swift
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
```

### MealPlan.swift
```swift
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
```

---

## 🎯 QUICK START INSTRUCTIONS

1. **In Xcode**, right-click on `RecipeApp` folder → `New Group` → Name it "Models"
2. For each model above:
   - Right-click Models folder → `New File` → Swift File
   - Name it (e.g., `Recipe.swift`)
   - Copy-paste the code from above

3. Repeat for:
   - ViewModels folder (I'll provide files next)
   - Services folder
   - Views folder

4. **Build** (Cmd + B) to check for errors

---

**Continue to next message for ViewModels, Services, and Views...**
