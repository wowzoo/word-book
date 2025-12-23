import Foundation
import SwiftData

@Model
final class StudySession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var deckId: UUID
    var cardsReviewed: Int
    var correctAnswers: Int
    var totalTimeSpent: TimeInterval

    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        deckId: UUID,
        cardsReviewed: Int = 0,
        correctAnswers: Int = 0,
        totalTimeSpent: TimeInterval = 0
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.deckId = deckId
        self.cardsReviewed = cardsReviewed
        self.correctAnswers = correctAnswers
        self.totalTimeSpent = totalTimeSpent
    }

    // MARK: - Computed Properties

    var accuracy: Double {
        guard cardsReviewed > 0 else { return 0 }
        return Double(correctAnswers) / Double(cardsReviewed)
    }

    var isActive: Bool {
        endedAt == nil
    }
}
