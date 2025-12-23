import Foundation
import SwiftData

// MARK: - Review Rating

enum ReviewRating: Int, Codable, CaseIterable {
    case again = 0  // 전혀 기억 안남 (< 60%)
    case hard = 1   // 어렵게 기억 (60-80%)
    case good = 2   // 잘 기억 (80-95%)
    case easy = 3   // 쉽게 기억 (95%+)

    var title: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }

    var subtitle: String {
        switch self {
        case .again: return "< 1 day"
        case .hard: return "< 1.2x"
        case .good: return "Normal"
        case .easy: return "> 1.3x"
        }
    }
}

// MARK: - Review Record

@Model
final class ReviewRecord {
    @Attribute(.unique) var id: UUID
    var reviewedAt: Date
    var rating: ReviewRating
    var previousInterval: Int
    var newInterval: Int
    var previousEaseFactor: Double
    var newEaseFactor: Double
    var timeSpent: TimeInterval

    @Relationship var card: Card?

    init(
        id: UUID = UUID(),
        reviewedAt: Date = Date(),
        rating: ReviewRating,
        previousInterval: Int,
        newInterval: Int,
        previousEaseFactor: Double,
        newEaseFactor: Double,
        timeSpent: TimeInterval = 0,
        card: Card? = nil
    ) {
        self.id = id
        self.reviewedAt = reviewedAt
        self.rating = rating
        self.previousInterval = previousInterval
        self.newInterval = newInterval
        self.previousEaseFactor = previousEaseFactor
        self.newEaseFactor = newEaseFactor
        self.timeSpent = timeSpent
        self.card = card
    }
}
