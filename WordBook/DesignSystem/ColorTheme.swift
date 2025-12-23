import SwiftUI

struct ColorTheme {
    // Primary colors
    static let primary = Color.blue
    static let secondary = Color.gray

    // Semantic colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // State colors for learning
    static let newCard = Color.blue
    static let learning = Color.orange
    static let mastered = Color.green
    static let due = Color.red

    // Neutral colors
    static let background = Color(nsColor: .controlBackgroundColor)
    static let cardBackground = Color(nsColor: .textBackgroundColor)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    // Hover states
    static let hoverOverlay = Color.black.opacity(0.03)
}
