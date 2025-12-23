import Foundation
import SwiftData

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var newCardsPerDay: Int
    var maxReviewsPerDay: Int
    var showPronunciation: Bool
    var autoPlayAudio: Bool
    var darkModeEnabled: Bool
    var studyReminderEnabled: Bool
    var studyReminderTime: Date?

    init(
        id: UUID = UUID(),
        newCardsPerDay: Int = 20,
        maxReviewsPerDay: Int = 200,
        showPronunciation: Bool = true,
        autoPlayAudio: Bool = false,
        darkModeEnabled: Bool = false,
        studyReminderEnabled: Bool = false,
        studyReminderTime: Date? = nil
    ) {
        self.id = id
        self.newCardsPerDay = newCardsPerDay
        self.maxReviewsPerDay = maxReviewsPerDay
        self.showPronunciation = showPronunciation
        self.autoPlayAudio = autoPlayAudio
        self.darkModeEnabled = darkModeEnabled
        self.studyReminderEnabled = studyReminderEnabled
        self.studyReminderTime = studyReminderTime
    }
}
