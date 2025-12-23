import SwiftUI

struct DeckCard: View {
    let deck: Deck
    var isSelected: Bool = false

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(Color(hex: deck.color) ?? .blue)
                    .frame(width: 24, height: 24)

                Text(deck.name)
                    .font(Typography.subheading)

                Spacer()

                if deck.dueCards > 0 {
                    Text("\(deck.dueCards)")
                        .font(Typography.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 4)
                        .background(ColorTheme.due.opacity(0.1))
                        .foregroundColor(ColorTheme.due)
                        .cornerRadius(VisualEffects.CornerRadius.medium)
                }
            }

            // Description
            if !deck.descriptionText.isEmpty {
                Text(deck.descriptionText)
                    .font(Typography.caption)
                    .foregroundStyle(ColorTheme.textSecondary)
                    .lineLimit(2)
            }

            // Stats
            HStack(spacing: Spacing.md) {
                StatLabel(icon: "square.stack.3d.up", value: "\(deck.totalCards)", label: "Total")
                StatLabel(icon: "sparkles", value: "\(deck.newCards)", label: "New")
                StatLabel(icon: "book", value: "\(deck.learningCards)", label: "Learning")
                StatLabel(icon: "checkmark.seal", value: "\(deck.masteredCards)", label: "Mastered")
            }
            .font(Typography.caption)
        }
        .padding(Spacing.cardPadding)
        .background(ColorTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: VisualEffects.CornerRadius.medium)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .cornerRadius(VisualEffects.CornerRadius.medium)
        .cardShadow(isHovered: isHovered)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(VisualEffects.Animation.quick, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Stat Label

private struct StatLabel: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.semibold)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    VStack {
        DeckCard(
            deck: Deck(
                name: "Basic English",
                descriptionText: "Essential vocabulary for beginners",
                color: "#007AFF"
            ),
            isSelected: false
        )

        DeckCard(
            deck: Deck(
                name: "TOEFL Vocabulary",
                descriptionText: "Advanced words for TOEFL exam preparation",
                color: "#FF9500"
            ),
            isSelected: true
        )
    }
    .padding()
    .frame(width: 400)
}
