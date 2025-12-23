import SwiftUI

struct CardRow: View {
    let card: Card

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Status Indicator
            Circle()
                .fill(stateColor)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            // Card Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Front (Word)
                Text(card.front)
                    .font(Typography.bodyBold)

                // Back (Definition)
                Text(card.back)
                    .font(Typography.body)
                    .foregroundStyle(ColorTheme.textPrimary)

                // Example (if exists)
                if let example = card.example, !example.isEmpty {
                    Text("\"\(example)\"")
                        .font(Typography.caption)
                        .italic()
                        .foregroundStyle(ColorTheme.textSecondary)
                }

                // Metadata
                HStack(spacing: Spacing.sm) {
                    Label(card.learningState.displayName, systemImage: stateIcon)
                        .font(Typography.caption)
                        .foregroundStyle(ColorTheme.textSecondary)

                    if card.totalReviews > 0 {
                        Label("\(Int(card.accuracy * 100))% accuracy", systemImage: "chart.line.uptrend.xyaxis")
                            .font(Typography.caption)
                            .foregroundStyle(ColorTheme.textSecondary)
                    }

                    if card.nextReviewDate > Date() {
                        Label(nextReviewText, systemImage: "clock")
                            .font(Typography.caption)
                            .foregroundStyle(ColorTheme.textSecondary)
                    } else if card.learningState != .new {
                        Label("Due now", systemImage: "exclamationmark.circle")
                            .font(Typography.caption)
                            .foregroundStyle(ColorTheme.due)
                    }
                }
            }

            Spacer()
        }
        .padding(Spacing.cardPadding)
        .background(ColorTheme.cardBackground)
        .cornerRadius(VisualEffects.CornerRadius.small)
        .cardShadow(isHovered: isHovered)
        .scaleEffect(isHovered ? 1.005 : 1.0)
        .animation(VisualEffects.Animation.quick, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    // MARK: - Computed Properties

    private var stateColor: Color {
        switch card.learningState {
        case .new: return .blue
        case .learning: return .orange
        case .mastered: return .green
        case .relearning: return .red
        }
    }

    private var stateIcon: String {
        switch card.learningState {
        case .new: return "sparkles"
        case .learning: return "book"
        case .mastered: return "checkmark.seal.fill"
        case .relearning: return "arrow.clockwise"
        }
    }

    private var nextReviewText: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(card.nextReviewDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(card.nextReviewDate) {
            return "Tomorrow"
        } else {
            let days = calendar.dateComponents([.day], from: now, to: card.nextReviewDate).day ?? 0
            return "in \(days) days"
        }
    }
}

#Preview {
    VStack {
        CardRow(card: Card(
            front: "abandon",
            back: "to give up completely",
            example: "He abandoned his car in the snow.",
            learningState: .learning,
            totalReviews: 5,
            correctReviews: 4
        ))

        CardRow(card: Card(
            front: "ability",
            back: "the power or skill to do something",
            learningState: .mastered,
            totalReviews: 10,
            correctReviews: 9
        ))

        CardRow(card: Card(
            front: "accept",
            back: "to receive something willingly",
            learningState: .new
        ))
    }
    .padding()
    .frame(width: 600)
}
