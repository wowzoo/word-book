import SwiftUI

struct RatingButtons: View {
    let onRate: (ReviewRating) -> Void

    var body: some View {
        HStack(spacing: Spacing.buttonSpacing) {
            ForEach(ReviewRating.allCases, id: \.self) { rating in
                RatingButton(rating: rating) {
                    onRate(rating)
                }
            }
        }
    }
}

// MARK: - Rating Button

private struct RatingButton: View {
    let rating: ReviewRating
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: rating.icon)
                    .font(.system(size: 24))
                    .foregroundColor(rating.color)

                Text(rating.title)
                    .font(Typography.bodyBold)

                Text(rating.subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(ColorTheme.textSecondary)
            }
            .frame(width: 130, height: 90)
            .background(rating.color.opacity(isHovered ? 0.15 : 0.08))
            .overlay(
                RoundedRectangle(cornerRadius: VisualEffects.CornerRadius.medium)
                    .stroke(rating.color, lineWidth: isHovered ? 2.5 : 2)
            )
            .cornerRadius(VisualEffects.CornerRadius.medium)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(VisualEffects.Animation.quick, value: isHovered)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(rating.keyboardShortcut, modifiers: [])
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Rating Extensions

extension ReviewRating {
    var color: Color {
        switch self {
        case .again: return ColorTheme.error
        case .hard: return ColorTheme.warning
        case .good: return ColorTheme.success
        case .easy: return ColorTheme.info
        }
    }

    var icon: String {
        switch self {
        case .again: return "xmark.circle.fill"
        case .hard: return "exclamationmark.triangle.fill"
        case .good: return "checkmark.circle.fill"
        case .easy: return "hand.thumbsup.fill"
        }
    }

    var keyboardShortcut: KeyEquivalent {
        switch self {
        case .again: return "1"
        case .hard: return "2"
        case .good: return "3"
        case .easy: return "4"
        }
    }
}

#Preview {
    VStack {
        RatingButtons { rating in
            print("Selected: \(rating.title)")
        }
    }
    .padding()
    .frame(width: 600)
}
