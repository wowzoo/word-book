import Foundation
import SwiftData
import Observation

// MARK: - Study Session Manager

@Observable
final class StudySessionManager {
    private(set) var currentSession: StudySession?
    private(set) var currentDeck: Deck?
    private(set) var cards: [Card] = []
    private(set) var currentIndex: Int = 0
    private var startTime: Date?

    var currentCard: Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var remainingCards: Int {
        cards.count - currentIndex
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }

    var isSessionActive: Bool {
        currentSession != nil && currentCard != nil
    }

    // MARK: - Session Management

    /// 학습 세션 시작
    /// - Parameters:
    ///   - deck: 학습할 덱
    ///   - newCardsLimit: 신규 카드 제한
    ///   - reviewLimit: 복습 카드 제한
    func startSession(deck: Deck, newCardsLimit: Int, reviewLimit: Int) {
        self.currentDeck = deck

        // 복습 카드 + 신규 카드 조합
        var sessionCards: [Card] = []
        sessionCards.append(contentsOf: SRSEngine.getDueCards(from: deck, limit: reviewLimit))
        sessionCards.append(contentsOf: SRSEngine.getNewCards(from: deck, limit: newCardsLimit))

        // 섞기 (선택사항 - 더 나은 학습 효과)
        sessionCards.shuffle()

        self.cards = sessionCards
        self.currentIndex = 0
        self.startTime = Date()

        // 세션 기록
        currentSession = StudySession(
            startedAt: Date(),
            deckId: deck.id,
            cardsReviewed: 0,
            correctAnswers: 0,
            totalTimeSpent: 0
        )
    }

    /// 답변 제출 및 카드 업데이트
    /// - Parameters:
    ///   - rating: 사용자 평가
    ///   - modelContext: SwiftData 컨텍스트
    func submitAnswer(rating: ReviewRating, modelContext: ModelContext) {
        guard let card = currentCard else { return }

        let cardStartTime = startTime ?? Date()
        let timeSpent = Date().timeIntervalSince(cardStartTime)

        // SRS 계산
        let (newInterval, newEaseFactor, newState) = SRSEngine.calculateNextReview(
            for: card,
            rating: rating
        )

        // 카드 업데이트
        let previousInterval = card.interval
        let previousEF = card.easeFactor

        card.interval = newInterval
        card.easeFactor = newEaseFactor
        card.learningState = newState
        card.repetitions = rating == .again ? 0 : card.repetitions + 1
        card.nextReviewDate = SRSEngine.calculateNextReviewDate(interval: newInterval)
        card.lastReviewedAt = Date()
        card.totalReviews += 1
        card.updatedAt = Date()

        if rating != .again {
            card.correctReviews += 1
        }

        // 리뷰 기록 저장
        let record = ReviewRecord(
            reviewedAt: Date(),
            rating: rating,
            previousInterval: previousInterval,
            newInterval: newInterval,
            previousEaseFactor: previousEF,
            newEaseFactor: newEaseFactor,
            timeSpent: timeSpent,
            card: card
        )
        modelContext.insert(record)

        // 세션 통계 업데이트
        currentSession?.cardsReviewed += 1
        if rating != .again {
            currentSession?.correctAnswers += 1
        }

        // 다음 카드로
        currentIndex += 1
        startTime = Date()

        // 세션 종료 확인
        if currentIndex >= cards.count {
            endSession()
        }
    }

    /// 학습 세션 종료
    func endSession() {
        currentSession?.endedAt = Date()
        if let start = currentSession?.startedAt {
            currentSession?.totalTimeSpent = Date().timeIntervalSince(start)
        }

        // 초기화
        currentSession = nil
        currentDeck = nil
        cards = []
        currentIndex = 0
        startTime = nil
    }

    /// 세션 중단 (카드를 끝까지 하지 않고 종료)
    func cancelSession() {
        endSession()
    }
}
