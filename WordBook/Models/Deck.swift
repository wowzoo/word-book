import Foundation
import SwiftData

@Model
final class Deck {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String
    var color: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card]

    init(
        id: UUID = UUID(),
        name: String,
        descriptionText: String = "",
        color: String = "#007AFF",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        cards: [Card] = []
    ) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cards = cards
    }

    // MARK: - Computed Properties

    var totalCards: Int {
        cards.count
    }

    var dueCards: Int {
        cards.filter { $0.nextReviewDate <= Date() }.count
    }

    var newCards: Int {
        cards.filter { $0.learningState == .new }.count
    }

    var learningCards: Int {
        cards.filter { $0.learningState == .learning }.count
    }

    var masteredCards: Int {
        cards.filter { $0.learningState == .mastered }.count
    }
}
