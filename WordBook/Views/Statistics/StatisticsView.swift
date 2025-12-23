import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [StudySession]
    @Query private var decks: [Deck]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Statistics")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                // Today's Progress
                todaySection

                // Overall Stats
                overallSection

                // Recent Sessions
                recentSessionsSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Statistics")
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)
                .padding(.horizontal)

            let todaySessions = sessions.filter { session in
                Calendar.current.isDateInToday(session.startedAt)
            }

            let cardsReviewed = todaySessions.reduce(0) { $0 + $1.cardsReviewed }
            let correctAnswers = todaySessions.reduce(0) { $0 + $1.correctAnswers }
            let totalTime = todaySessions.reduce(0.0) { $0 + $1.totalTimeSpent }
            let accuracy = cardsReviewed > 0 ? Double(correctAnswers) / Double(cardsReviewed) : 0

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    icon: "rectangle.on.rectangle",
                    label: "Cards Reviewed",
                    value: "\(cardsReviewed)",
                    color: .blue
                )

                StatCard(
                    icon: "checkmark.circle",
                    label: "Accuracy",
                    value: "\(Int(accuracy * 100))%",
                    color: .green
                )

                StatCard(
                    icon: "clock",
                    label: "Study Time",
                    value: formatTime(totalTime),
                    color: .orange
                )

                StatCard(
                    icon: "flame",
                    label: "Sessions",
                    value: "\(todaySessions.count)",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Overall Section

    private var overallSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall")
                .font(.headline)
                .padding(.horizontal)

            let totalCards = decks.reduce(0) { $0 + $1.totalCards }
            let newCards = decks.reduce(0) { $0 + $1.newCards }
            let learningCards = decks.reduce(0) { $0 + $1.learningCards }
            let masteredCards = decks.reduce(0) { $0 + $1.masteredCards }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    icon: "square.stack.3d.up",
                    label: "Total Cards",
                    value: "\(totalCards)",
                    color: .purple
                )

                StatCard(
                    icon: "sparkles",
                    label: "New",
                    value: "\(newCards)",
                    color: .blue
                )

                StatCard(
                    icon: "book",
                    label: "Learning",
                    value: "\(learningCards)",
                    color: .orange
                )

                StatCard(
                    icon: "checkmark.seal.fill",
                    label: "Mastered",
                    value: "\(masteredCards)",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Recent Sessions

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
                .padding(.horizontal)

            let recentSessions = sessions
                .sorted { $0.startedAt > $1.startedAt }
                .prefix(10)

            if recentSessions.isEmpty {
                Text("No study sessions yet")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(recentSessions)) { session in
                        SessionRow(session: session, decks: decks)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Helper

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        return "\(minutes)m"
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: StudySession
    let decks: [Deck]

    var body: some View {
        HStack {
            Circle()
                .fill(session.accuracy >= 0.8 ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            if let deck = decks.first(where: { $0.id == session.deckId }) {
                Text(deck.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else {
                Text("Unknown Deck")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                Text("\(session.cardsReviewed) cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(Int(session.accuracy * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(session.accuracy >= 0.8 ? .green : .orange)

                Text(session.startedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [StudySession.self, Deck.self], inMemory: true)
}
