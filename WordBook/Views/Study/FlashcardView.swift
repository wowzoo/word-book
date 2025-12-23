import SwiftUI

struct FlashcardView: View {
    let card: Card
    let isShowingAnswer: Bool

    @State private var isFlipped = false

    var naverDictURL: String {
        let encoded = card.front.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? card.front
        return "https://dict.naver.com/enkodict/#/search?query=\(encoded)"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: VisualEffects.CornerRadius.xlarge)
                .fill(ColorTheme.cardBackground)
                .flashcardShadow()

            if !isShowingAnswer {
                frontView
            } else {
                backView
            }
        }
        .frame(width: 600, height: 400)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(VisualEffects.Animation.spring, value: isFlipped)
        .onChange(of: isShowingAnswer) { _, newValue in
            withAnimation(VisualEffects.Animation.spring) {
                isFlipped = newValue
            }
        }
    }

    // MARK: - Front View (Word)

    private var frontView: some View {
        VStack(spacing: Spacing.md) {
            Spacer()

            VStack(spacing: Spacing.sm) {
                Text(card.front)
                    .font(.system(size: 56, weight: .bold))
                    .multilineTextAlignment(.center)

                if let pronunciation = card.pronunciation {
                    Text("[\(pronunciation)]")
                        .font(.title3)
                        .foregroundStyle(ColorTheme.textSecondary)
                }
            }

            Spacer()

            // Hint
            HStack(spacing: Spacing.xs) {
                Image(systemName: "hand.tap.fill")
                    .foregroundStyle(ColorTheme.textSecondary)
                Text("Press Space or click 'Show Answer'")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTheme.textSecondary)
            }
            .padding(.bottom, Spacing.lg)
        }
        .padding(Spacing.xl)
    }

    // MARK: - Back View (Definition + Details)

    private var backView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Word
                Text(card.front)
                    .font(.system(size: 40, weight: .bold))

                if let pronunciation = card.pronunciation {
                    Text("[\(pronunciation)]")
                        .font(.title3)
                        .foregroundStyle(ColorTheme.textSecondary)
                }

                // Naver Dictionary Link
                Button(action: {
                    if let url = URL(string: naverDictURL) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.circle.fill")
                        Text("Search in Naver Dictionary")
                        Image(systemName: "arrow.up.forward.square")
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)

                Divider()

                // Definition
                Text(card.back)
                    .font(.title2)

                // Example
                if let example = card.example, !example.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Example:")
                            .font(Typography.bodyBold)
                            .foregroundStyle(ColorTheme.textSecondary)
                        Text(example)
                            .font(Typography.body)
                            .italic()
                    }
                    .padding(.top, Spacing.xs)
                }

                // Notes
                if let notes = card.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Notes:")
                            .font(Typography.bodyBold)
                            .foregroundStyle(ColorTheme.textSecondary)
                        Text(notes)
                            .font(Typography.body)
                    }
                    .padding(.top, Spacing.xs)
                }
            }
            .padding(.bottom, 12)

            // Card Stats
            HStack(spacing: Spacing.lg) {
                statLabel(
                    icon: "calendar",
                    text: "Interval: \(card.interval) days"
                )
                statLabel(
                    icon: "arrow.clockwise",
                    text: "Reviews: \(card.totalReviews)"
                )
                if card.totalReviews > 0 {
                    statLabel(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "Accuracy: \(Int(card.accuracy * 100))%"
                    )
                }
            }
            .font(Typography.caption)
            .foregroundStyle(ColorTheme.textSecondary)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .rotation3DEffect(
            .degrees(180),
            axis: (x: 0, y: 1, z: 0)
        )
    }

    // MARK: - Stat Label

    private func statLabel(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        FlashcardView(
            card: Card(
                front: "abandon",
                back: "to give up completely; to desert",
                example: "He abandoned his car in the snow and walked to the nearest town.",
                pronunciation: "/əˈbændən/"
            ),
            isShowingAnswer: false
        )

        FlashcardView(
            card: Card(
                front: "ability",
                back: "the power or skill to do something",
                example: "She has the ability to speak five languages.",
                pronunciation: "/əˈbɪləti/",
                totalReviews: 8,
                correctReviews: 7
            ),
            isShowingAnswer: true
        )
    }
    .padding()
    .frame(width: 800)
}
