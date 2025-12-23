import Foundation
import SwiftData
import Observation

@Observable
final class DeckListViewModel {
    private let modelContext: ModelContext

    var decks: [Deck] = []
    var searchText: String = ""
    var sortOption: SortOption = .name

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchDecks()
    }

    // MARK: - Deck Operations

    func fetchDecks() {
        let descriptor = FetchDescriptor<Deck>(
            sortBy: [SortDescriptor(\.name)]
        )
        decks = (try? modelContext.fetch(descriptor)) ?? []
    }

    func createDeck(name: String, description: String, color: String) {
        let deck = Deck(
            name: name,
            descriptionText: description,
            color: color
        )
        modelContext.insert(deck)
        try? modelContext.save()
        fetchDecks()
    }

    func deleteDeck(_ deck: Deck) {
        modelContext.delete(deck)
        try? modelContext.save()
        fetchDecks()
    }

    func updateDeck(_ deck: Deck, name: String, description: String, color: String) {
        deck.name = name
        deck.descriptionText = description
        deck.color = color
        deck.updatedAt = Date()
        try? modelContext.save()
        fetchDecks()
    }

    // MARK: - Filtering & Sorting

    var filteredDecks: [Deck] {
        guard !searchText.isEmpty else { return sortedDecks }
        return sortedDecks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sortedDecks: [Deck] {
        switch sortOption {
        case .name:
            return decks.sorted { $0.name < $1.name }
        case .dateCreated:
            return decks.sorted { $0.createdAt > $1.createdAt }
        case .dueCards:
            return decks.sorted { $0.dueCards > $1.dueCards }
        }
    }

    // MARK: - Sort Options

    enum SortOption: String, CaseIterable {
        case name = "Name"
        case dateCreated = "Date Created"
        case dueCards = "Due Cards"
    }

    // MARK: - Export/Import Operations

    /// Export a deck to file
    func exportDeck(_ deck: Deck) -> Result<Data, Error> {
        let service = DeckExportImportService(modelContext: modelContext)
        do {
            let data = try service.exportDeck(deck)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }

    /// Get suggested filename for export
    func suggestedFilename(for deck: Deck) -> String {
        let service = DeckExportImportService(modelContext: modelContext)
        return service.suggestedFilename(for: deck)
    }

    /// Import a deck from file data
    func importDeck(from data: Data) -> Result<Deck, Error> {
        let service = DeckExportImportService(modelContext: modelContext)
        do {
            let deck = try service.importDeck(from: data)
            fetchDecks()  // Refresh deck list
            return .success(deck)
        } catch {
            return .failure(error)
        }
    }

    /// Validate import file
    func validateImportFile(_ data: Data) -> Bool {
        let service = DeckExportImportService(modelContext: modelContext)
        return service.validateFile(data)
    }
}
