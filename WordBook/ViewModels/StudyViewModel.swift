import Foundation
import SwiftData
import Observation

@Observable
final class StudyViewModel {
    private let modelContext: ModelContext
    private let sessionManager: StudySessionManager

    var isShowingAnswer = false
    var currentCardStartTime: Date?

    init(modelContext: ModelContext, sessionManager: StudySessionManager) {
        self.modelContext = modelContext
        self.sessionManager = sessionManager
    }

    // MARK: - Session Management

    func startStudy(deck: Deck, newCardsLimit: Int = 20, reviewLimit: Int = 200) {
        sessionManager.startSession(
            deck: deck,
            newCardsLimit: newCardsLimit,
            reviewLimit: reviewLimit
        )
        currentCardStartTime = Date()
    }

    func endStudy() {
        sessionManager.endSession()
        isShowingAnswer = false
        currentCardStartTime = nil
    }

    // MARK: - Card Actions

    func showAnswer() {
        isShowingAnswer = true
    }

    func submitRating(_ rating: ReviewRating) {
        sessionManager.submitAnswer(rating: rating, modelContext: modelContext)
        isShowingAnswer = false
        currentCardStartTime = Date()

        try? modelContext.save()
    }

    // MARK: - Computed Properties

    var currentCard: Card? {
        sessionManager.currentCard
    }

    var progress: Double {
        sessionManager.progress
    }

    var remainingCards: Int {
        sessionManager.remainingCards
    }

    var isSessionActive: Bool {
        sessionManager.isSessionActive
    }

    var currentSession: StudySession? {
        sessionManager.currentSession
    }
}
