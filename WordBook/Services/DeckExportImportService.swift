import Foundation
import SwiftData

// MARK: - Errors

enum DeckExportImportError: LocalizedError {
    case exportFailed(String)
    case importFailed(String)
    case invalidFormat
    case duplicateDeck(String)
    case fileAccessError

    var errorDescription: String? {
        switch self {
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .importFailed(let reason):
            return "Import failed: \(reason)"
        case .invalidFormat:
            return "Invalid file format. Please select a valid JSON file."
        case .duplicateDeck(let name):
            return "A deck named '\(name)' already exists."
        case .fileAccessError:
            return "Unable to access the file. Please check permissions."
        }
    }
}

// MARK: - Service

final class DeckExportImportService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Export

    /// Export a deck to JSON data
    func exportDeck(_ deck: Deck) throws -> Data {
        let dto = DeckExportDTO(from: deck)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

        do {
            let data = try encoder.encode(dto)
            return data
        } catch {
            throw DeckExportImportError.exportFailed(error.localizedDescription)
        }
    }

    /// Generate suggested filename for export
    func suggestedFilename(for deck: Deck) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        // Sanitize deck name for filename
        let sanitizedName = deck.name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return "\(sanitizedName)_\(dateString).json"
    }

    // MARK: - Import

    /// Import a deck from JSON data
    func importDeck(from data: Data) throws -> Deck {
        // Decode DTO
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportDTO: DeckExportDTO
        do {
            exportDTO = try decoder.decode(DeckExportDTO.self, from: data)
        } catch {
            throw DeckExportImportError.invalidFormat
        }

        let deckDTO = exportDTO.deck

        // Check for duplicate deck name
        let existingDecks = try? modelContext.fetch(FetchDescriptor<Deck>())
        let duplicateExists = existingDecks?.contains(where: { $0.name == deckDTO.name }) ?? false

        let finalName = duplicateExists ? "\(deckDTO.name) (Imported)" : deckDTO.name

        // Create new deck
        let newDeck = Deck(
            name: finalName,
            descriptionText: deckDTO.descriptionText,
            color: deckDTO.color
        )

        // Insert deck first
        modelContext.insert(newDeck)

        // Create cards
        for cardDTO in deckDTO.cards {
            let card = createCard(from: cardDTO, deck: newDeck)
            modelContext.insert(card)
            newDeck.cards.append(card)
        }

        // Save context
        do {
            try modelContext.save()
        } catch {
            throw DeckExportImportError.importFailed("Failed to save to database: \(error.localizedDescription)")
        }

        return newDeck
    }

    /// Validate a .wordbook file before import
    func validateFile(_ data: Data) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            _ = try decoder.decode(DeckExportDTO.self, from: data)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Private Helpers

    private func createCard(from dto: CardDTO, deck: Deck) -> Card {
        // Parse learning state
        let learningState = LearningState(rawValue: dto.learningState) ?? .new

        let card = Card(
            front: dto.front,
            back: dto.back,
            example: dto.example,
            pronunciation: dto.pronunciation,
            notes: dto.notes,
            learningState: learningState,
            easeFactor: dto.easeFactor,
            interval: dto.interval,
            repetitions: dto.repetitions,
            nextReviewDate: dto.nextReviewDate,
            lastReviewedAt: dto.lastReviewedAt,
            totalReviews: dto.totalReviews,
            correctReviews: dto.correctReviews
        )

        card.deck = deck

        return card
    }
}
