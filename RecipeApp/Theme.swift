import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Primary Colors
    static let primaryOrange = Color(hex: "FF6B35")
    static let secondaryGreen = Color(hex: "8BC34A")
    static let accentPurple = Color(hex: "9C27B0")

    // Semantic Colors
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FF9800")
    static let error = Color(hex: "E53935")
    static let info = Color(hex: "2196F3")
    static let rating = Color(hex: "FFC107")
    static let cookingTime = Color(hex: "607D8B")

    // Light Theme
    struct Light {
        static let surface = Color(hex: "FFFBFE")
        static let background = Color(hex: "FCFCFC")
        static let card = Color.white
        static let textPrimary = Color(hex: "1C1B1F")
        static let textSecondary = Color(hex: "49454F")
        static let border = Color(hex: "E0E0E0")
        static let shadow = Color.black.opacity(0.08)
    }

    // Dark Theme
    struct Dark {
        static let surface = Color.black
        static let background = Color.black
        static let card = Color(hex: "1E1E1E")
        static let container = Color(hex: "2A2A2A")
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "E0E0E0")
        static let border = Color(hex: "404040")
        static let shadow = Color.white.opacity(0.05)
    }

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Environment
struct ThemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme? = nil
}

extension EnvironmentValues {
    var theme: ColorScheme? {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Corner Radius
extension CGFloat {
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24
}

// MARK: - Spacing
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
}

// MARK: - Card Style Modifier
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? Color.Dark.card : Color.Light.card
    }

    var shadowColor: Color {
        colorScheme == .dark ? Color.Dark.shadow : Color.Light.shadow
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(.cornerRadiusMedium)
            .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
