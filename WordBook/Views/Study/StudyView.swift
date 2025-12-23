import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let deck: Deck

    @State private var sessionManager = StudySessionManager()
    @State private var viewModel: StudyViewModel?

    var body: some View {
        VStack(spacing: 0) {
            if let viewModel = viewModel {
                if viewModel.isSessionActive {
                    studyContent(viewModel: viewModel)
                } else {
                    // Session ended - dismiss immediately
                    Color.clear
                        .onAppear {
                            dismiss()
                        }
                }
            }
        }
        .frame(minWidth: 700, minHeight: 600)
        .onAppear {
            if viewModel == nil {
                viewModel = StudyViewModel(
                    modelContext: modelContext,
                    sessionManager: sessionManager
                )
                viewModel?.startStudy(deck: deck)
            }
        }
    }

    // MARK: - Study Content

    @ViewBuilder
    private func studyContent(viewModel: StudyViewModel) -> some View {
        VStack(spacing: 0) {
            // Header
            header(viewModel: viewModel)

            Spacer()

            // Flashcard
            if let card = viewModel.currentCard {
                FlashcardView(
                    card: card,
                    isShowingAnswer: viewModel.isShowingAnswer
                )
            }

            Spacer()

            // Controls
            controls(viewModel: viewModel)
        }
        .padding()
    }

    // MARK: - Header

    private func header(viewModel: StudyViewModel) -> some View {
        HStack {
            Button(action: {
                viewModel.endStudy()
                dismiss()
            }) {
                Label("Close", systemImage: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 4) {
                Text(deck.name)
                    .font(.headline)

                Text("\(viewModel.remainingCards) cards remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Progress
            Text("\(Int(viewModel.progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Controls

    @ViewBuilder
    private func controls(viewModel: StudyViewModel) -> some View {
        if viewModel.isShowingAnswer {
            RatingButtons(onRate: { rating in
                viewModel.submitRating(rating)
            })
            .padding(.top, 20)
        } else {
            Button(action: { viewModel.showAnswer() }) {
                Text("Show Answer")
                    .font(.headline)
                    .frame(width: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.space, modifiers: [])
            .padding(.top, 20)
        }
    }
}

#Preview {
    let deck = Deck(name: "Preview Deck")
    StudyView(deck: deck)
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
