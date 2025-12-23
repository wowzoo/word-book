import Foundation
import SwiftData

// MARK: - SRS Engine (SM-2 Algorithm)

final class SRSEngine {

    /// SM-2 알고리즘을 사용하여 다음 복습 일정 계산
    /// - Parameters:
    ///   - card: 복습할 카드
    ///   - rating: 사용자 평가 (Again, Hard, Good, Easy)
    /// - Returns: (interval: 다음 복습 간격(일), easeFactor: 새 ease factor, state: 새 학습 상태)
    static func calculateNextReview(
        for card: Card,
        rating: ReviewRating
    ) -> (interval: Int, easeFactor: Double, state: LearningState) {

        var newInterval: Int
        var newEaseFactor = card.easeFactor
        var newState = card.learningState
        var repetitions = card.repetitions

        // SM-2 ease factor 조정
        if rating != .again {
            // quality를 2-5 범위로 변환 (Again=2, Hard=3, Good=4, Easy=5)
            let qualityScore = Double(rating.rawValue + 2)
            // SM-2 공식: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
            newEaseFactor = max(
                1.3,
                card.easeFactor + (0.1 - (5 - qualityScore) * (0.08 + (5 - qualityScore) * 0.02))
            )
        }

        switch rating {
        case .again:
            // 틀림: 처음부터 다시 시작
            newInterval = 1 // 1일 후
            repetitions = 0
            newState = .relearning

        case .hard:
            // 어려움: 간격 증가를 작게
            if repetitions == 0 {
                newInterval = 1
            } else if repetitions == 1 {
                newInterval = 3
            } else {
                newInterval = max(1, Int(Double(card.interval) * 1.2))
            }
            repetitions += 1

        case .good:
            // 보통: SM-2 기본 간격
            if repetitions == 0 {
                newInterval = 1
            } else if repetitions == 1 {
                newInterval = 6
            } else {
                newInterval = Int(Double(card.interval) * newEaseFactor)
            }
            repetitions += 1

        case .easy:
            // 쉬움: 간격 증가를 크게
            if repetitions == 0 {
                newInterval = 4
            } else if repetitions == 1 {
                newInterval = 10
            } else {
                newInterval = Int(Double(card.interval) * newEaseFactor * 1.3)
            }
            repetitions += 1
        }

        // 상태 업데이트
        if newInterval >= 21 {
            newState = .mastered
        } else if newInterval > 1 && newState == .new {
            newState = .learning
        }

        return (newInterval, newEaseFactor, newState)
    }

    /// 오늘 복습해야 할 카드 필터링
    /// - Parameters:
    ///   - deck: 덱
    ///   - limit: 최대 카드 수 (nil이면 전체)
    /// - Returns: 복습 대기 카드 목록
    static func getDueCards(from deck: Deck, limit: Int? = nil) -> [Card] {
        let now = Date()
        var dueCards = deck.cards
            .filter { $0.nextReviewDate <= now }
            .sorted { $0.nextReviewDate < $1.nextReviewDate }

        if let limit = limit {
            dueCards = Array(dueCards.prefix(limit))
        }

        return dueCards
    }

    /// 신규 카드 가져오기
    /// - Parameters:
    ///   - deck: 덱
    ///   - limit: 최대 카드 수
    /// - Returns: 신규 카드 목록
    static func getNewCards(from deck: Deck, limit: Int) -> [Card] {
        deck.cards
            .filter { $0.learningState == .new }
            .sorted { $0.createdAt < $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    /// 카드의 다음 복습 일자 계산
    /// - Parameters:
    ///   - interval: 복습 간격 (일)
    ///   - from: 기준일 (기본값: 오늘)
    /// - Returns: 다음 복습 일자
    static func calculateNextReviewDate(interval: Int, from date: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: interval, to: date) ?? date
    }
}
