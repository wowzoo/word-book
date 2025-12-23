import Foundation

// MARK: - Deck Export DTO

struct DeckExportDTO: Codable {
    let version: String
    let exportedAt: Date
    let deck: DeckDTO

    init(from deck: Deck) {
        self.version = "1.0"
        self.exportedAt = Date()
        self.deck = DeckDTO(from: deck)
    }
}

// MARK: - Deck DTO

struct DeckDTO: Codable {
    let id: UUID
    let name: String
    let descriptionText: String
    let color: String
    let createdAt: Date
    let updatedAt: Date
    let cards: [CardDTO]

    init(from deck: Deck) {
        self.id = deck.id
        self.name = deck.name
        self.descriptionText = deck.descriptionText
        self.color = deck.color
        self.createdAt = deck.createdAt
        self.updatedAt = deck.updatedAt
        self.cards = deck.cards.map { CardDTO(from: $0) }
    }
}

// MARK: - Card DTO

struct CardDTO: Codable {
    // Identity
    let id: UUID

    // Content
    let front: String
    let back: String
    let example: String?
    let pronunciation: String?
    let notes: String?

    // SRS Data
    let learningState: String
    let easeFactor: Double
    let interval: Int
    let repetitions: Int
    let nextReviewDate: Date
    let lastReviewedAt: Date?

    // Statistics
    let totalReviews: Int
    let correctReviews: Int
    let createdAt: Date
    let updatedAt: Date

    init(from card: Card) {
        self.id = card.id
        self.front = card.front
        self.back = card.back
        self.example = card.example
        self.pronunciation = card.pronunciation
        self.notes = card.notes
        self.learningState = card.learningState.rawValue
        self.easeFactor = card.easeFactor
        self.interval = card.interval
        self.repetitions = card.repetitions
        self.nextReviewDate = card.nextReviewDate
        self.lastReviewedAt = card.lastReviewedAt
        self.totalReviews = card.totalReviews
        self.correctReviews = card.correctReviews
        self.createdAt = card.createdAt
        self.updatedAt = card.updatedAt
    }
}
