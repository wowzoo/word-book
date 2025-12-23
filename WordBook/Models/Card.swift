import Foundation
import SwiftData

// MARK: - Learning State

enum LearningState: String, Codable {
    case new        // 한 번도 학습하지 않음
    case learning   // 학습 중 (interval < 21일)
    case mastered   // 숙달됨 (interval >= 21일)
    case relearning // 재학습 (틀린 후 다시 학습)

    var displayName: String {
        switch self {
        case .new: return "New"
        case .learning: return "Learning"
        case .mastered: return "Mastered"
        case .relearning: return "Relearning"
        }
    }
}

// MARK: - Card Model

@Model
final class Card {
    @Attribute(.unique) var id: UUID
    var front: String
    var back: String
    var example: String?
    var pronunciation: String?
    var notes: String?

    // SRS Data
    var learningState: LearningState
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewedAt: Date?

    // Statistics
    var totalReviews: Int
    var correctReviews: Int
    var createdAt: Date
    var updatedAt: Date

    @Relationship var deck: Deck?
    @Relationship(deleteRule: .cascade, inverse: \ReviewRecord.card)
    var reviewHistory: [ReviewRecord]

    init(
        id: UUID = UUID(),
        front: String,
        back: String,
        example: String? = nil,
        pronunciation: String? = nil,
        notes: String? = nil,
        learningState: LearningState = .new,
        easeFactor: Double = 2.5,
        interval: Int = 0,
        repetitions: Int = 0,
        nextReviewDate: Date = Date(),
        lastReviewedAt: Date? = nil,
        totalReviews: Int = 0,
        correctReviews: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deck: Deck? = nil,
        reviewHistory: [ReviewRecord] = []
    ) {
        self.id = id
        self.front = front
        self.back = back
        self.example = example
        self.pronunciation = pronunciation
        self.notes = notes
        self.learningState = learningState
        self.easeFactor = easeFactor
        self.interval = interval
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
        self.lastReviewedAt = lastReviewedAt
        self.totalReviews = totalReviews
        self.correctReviews = correctReviews
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deck = deck
        self.reviewHistory = reviewHistory
    }

    // MARK: - Computed Properties

    var accuracy: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(correctReviews) / Double(totalReviews)
    }
}
