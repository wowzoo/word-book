import Foundation
import SwiftData
import Observation

@Observable
final class CardManagementViewModel {
    private let modelContext: ModelContext
    var deck: Deck

    var searchText: String = ""
    var filterOption: FilterOption = .all

    init(modelContext: ModelContext, deck: Deck) {
        self.modelContext = modelContext
        self.deck = deck
    }

    // MARK: - Card Operations

    func createCard(
        front: String,
        back: String,
        example: String? = nil,
        pronunciation: String? = nil,
        notes: String? = nil
    ) {
        let card = Card(
            front: front,
            back: back,
            example: example,
            pronunciation: pronunciation,
            notes: notes
        )
        card.deck = deck
        deck.cards.append(card)
        modelContext.insert(card)
        try? modelContext.save()
    }

    func updateCard(
        _ card: Card,
        front: String,
        back: String,
        example: String?,
        pronunciation: String?,
        notes: String?
    ) {
        card.front = front
        card.back = back
        card.example = example
        card.pronunciation = pronunciation
        card.notes = notes
        card.updatedAt = Date()
        try? modelContext.save()
    }

    func deleteCard(_ card: Card) {
        modelContext.delete(card)
        try? modelContext.save()
    }

    // MARK: - Filtering & Sorting

    var filteredCards: [Card] {
        var cards = deck.cards

        // Apply filter
        switch filterOption {
        case .all:
            break
        case .new:
            cards = cards.filter { $0.learningState == .new }
        case .learning:
            cards = cards.filter { $0.learningState == .learning }
        case .mastered:
            cards = cards.filter { $0.learningState == .mastered }
        case .due:
            cards = cards.filter { $0.nextReviewDate <= Date() }
        }

        // Apply search
        if !searchText.isEmpty {
            cards = cards.filter {
                $0.front.localizedCaseInsensitiveContains(searchText) ||
                $0.back.localizedCaseInsensitiveContains(searchText)
            }
        }

        return cards.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Filter Options

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case new = "New"
        case learning = "Learning"
        case mastered = "Mastered"
        case due = "Due"

        var icon: String {
            switch self {
            case .all: return "square.stack.3d.up"
            case .new: return "sparkles"
            case .learning: return "book"
            case .mastered: return "checkmark.seal"
            case .due: return "clock"
            }
        }
    }
}
