import SwiftUI

// MARK: - App Constants
enum AppConstants {
    static let appName = "RecipeVault"
    static let splashDuration: TimeInterval = 2.5

    // CloudFlare Worker URL
    static let cloudflareWorkerURL = "https://recipeappphotoparser.green-snow-173b.workers.dev/"
}

// MARK: - Meal Categories
enum MealCategory: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"
    case desserts = "Desserts"
    case beverages = "Beverages"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snacks: return "carrot.fill"
        case .desserts: return "birthday.cake.fill"
        case .beverages: return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Cuisine Types
enum CuisineType: String, CaseIterable, Identifiable {
    case italian = "Italian"
    case mexican = "Mexican"
    case asian = "Asian"
    case american = "American"
    case mediterranean = "Mediterranean"
    case indian = "Indian"
    case french = "French"
    case chinese = "Chinese"
    case thai = "Thai"
    case japanese = "Japanese"
    case korean = "Korean"
    case greek = "Greek"
    case spanish = "Spanish"
    case turkish = "Turkish"

    var id: String { rawValue }
}

// MARK: - Dietary Info
enum DietaryInfo: String, CaseIterable, Identifiable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-free"
    case keto = "Keto"
    case paleo = "Paleo"
    case dairyFree = "Dairy-free"
    case nutFree = "Nut-free"
    case lowCarb = "Low-carb"
    case highProtein = "High-protein"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vegetarian: return "leaf.fill"
        case .vegan: return "leaf.circle.fill"
        case .glutenFree: return "g.circle.fill"
        case .keto: return "k.circle.fill"
        case .paleo: return "p.circle.fill"
        case .dairyFree: return "d.circle.fill"
        case .nutFree: return "n.circle.fill"
        case .lowCarb: return "arrow.down.circle.fill"
        case .highProtein: return "arrow.up.circle.fill"
        }
    }
}

// MARK: - Units
enum MeasurementUnit: String, CaseIterable {
    case tsp = "tsp"
    case tbsp = "tbsp"
    case cup = "cup"
    case ml = "ml"
    case l = "l"
    case g = "g"
    case kg = "kg"
    case oz = "oz"
    case lb = "lb"
    case piece = "piece"
    case pinch = "pinch"
    case handful = "handful"
}

// MARK: - App Icons
enum AppIcon {
    static let home = "house.fill"
    static let recipes = "book.fill"
    static let favorites = "heart.fill"
    static let favoriteBorder = "heart"
    static let calendar = "calendar"
    static let groceryList = "cart.fill"
    static let timer = "timer"
    static let microphone = "mic.fill"
    static let camera = "camera.fill"
    static let link = "link"
    static let sparkles = "sparkles"
    static let edit = "pencil"
    static let delete = "trash"
    static let share = "square.and.arrow.up"
    static let add = "plus"
    static let addCircle = "plus.circle.fill"
    static let menu = "ellipsis.circle"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease.circle"
    static let settings = "gear"
    static let profile = "person.fill"
    static let clock = "clock.fill"
    static let difficulty = "chart.bar.fill"
    static let servings = "person.2.fill"
    static let nutrition = "leaf.fill"
    static let checkmark = "checkmark.circle.fill"
    static let close = "xmark"
    static let photo = "photo.on.rectangle"
    static let arrowRight = "arrow.right"
    static let chevronRight = "chevron.right"
    static let star = "star.fill"
    static let starOutline = "star"
}
