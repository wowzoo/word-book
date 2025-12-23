import SwiftUI

struct StudyCompleteView: View {
    let session: StudySession?
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Celebration Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            // Title
            Text("Study Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Stats
            if let session = session {
                VStack(spacing: 16) {
                    statRow(
                        icon: "rectangle.on.rectangle",
                        label: "Cards Reviewed",
                        value: "\(session.cardsReviewed)"
                    )

                    statRow(
                        icon: "checkmark.circle",
                        label: "Correct Answers",
                        value: "\(session.correctAnswers)"
                    )

                    statRow(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Accuracy",
                        value: "\(Int(session.accuracy * 100))%",
                        valueColor: accuracyColor(session.accuracy)
                    )

                    statRow(
                        icon: "clock",
                        label: "Time Spent",
                        value: formattedTime(session.totalTimeSpent)
                    )
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
            }

            Spacer()

            // Close Button
            Button(action: onClose) {
                Text("Done")
                    .font(.headline)
                    .frame(width: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
        .padding(40)
    }

    // MARK: - Stat Row

    private func statRow(
        icon: String,
        label: String,
        value: String,
        valueColor: Color = .primary
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 30)

            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(valueColor)
        }
    }

    // MARK: - Helpers

    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 {
            return .green
        } else if accuracy >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(minutes)m \(secs)s"
    }
}

#Preview {
    StudyCompleteView(
        session: StudySession(
            deckId: UUID(),
            cardsReviewed: 25,
            correctAnswers: 22,
            totalTimeSpent: 450
        ),
        onClose: {}
    )
    .frame(width: 500, height: 600)
}
