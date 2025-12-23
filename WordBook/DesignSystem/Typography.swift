import SwiftUI

struct Typography {
    // Flashcard styles
    static let flashcardFront = Font.system(size: 48, weight: .bold)
    static let flashcardBack = Font.system(size: 32, weight: .medium)

    // Headings
    static let title = Font.system(size: 28, weight: .bold)
    static let heading = Font.system(size: 22, weight: .bold)
    static let subheading = Font.system(size: 18, weight: .semibold)

    // Body text
    static let body = Font.system(size: 15)
    static let bodyBold = Font.system(size: 15, weight: .semibold)
    static let caption = Font.system(size: 13)
    static let footnote = Font.system(size: 11)
}
