import SwiftUI
import SwiftData

struct AddEditCardSheet: View {
    @Bindable var viewModel: CardManagementViewModel
    @Binding var isPresented: Bool
    let card: Card?

    @State private var front: String = ""
    @State private var back: String = ""
    @State private var example: String = ""
    @State private var notes: String = ""

    var isEditing: Bool {
        card != nil
    }

    var naverDictURL: String {
        if front.isEmpty {
            return "https://dict.naver.com/enkodict/#/main"
        }
        let encoded = front.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? front
        return "https://dict.naver.com/enkodict/#/search?query=\(encoded)"
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text(isEditing ? "Edit Card" : "Add New Card")
                .font(.title2)
                .fontWeight(.bold)

            // Form
            Form {
                VStack(alignment: .leading, spacing: 16) {
                    // Front (Word)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Word / Front")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("", text: $front)
                            .textFieldStyle(.roundedBorder)

                        // Naver Dictionary Link
                        if !front.isEmpty {
                            Link(destination: URL(string: naverDictURL)!) {
                                HStack(spacing: 4) {
                                    Image(systemName: "book.circle.fill")
                                    Text("Search in Naver Dictionary")
                                    Image(systemName: "arrow.up.forward.square")
                                }
                                .font(.caption)
                                .foregroundStyle(.blue)
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Back (Definition)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Definition / Back")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $back)
                            .frame(height: 60)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(6)
                    }

                    // Example (optional)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Example Sentence (optional)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $example)
                            .frame(height: 60)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(6)
                    }

                    // Notes (optional)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes (optional)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $notes)
                            .frame(height: 60)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(6)
                    }
                }
            }
            .padding()

            // Buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(isEditing ? "Save" : "Add") {
                    saveCard()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(front.isEmpty || back.isEmpty)
            }
            .padding()
        }
        .frame(width: 500)
        .padding()
        .onAppear {
            if let card = card {
                front = card.front
                back = card.back
                example = card.example ?? ""
                notes = card.notes ?? ""
            }
        }
    }

    private func saveCard() {
        if let card = card {
            viewModel.updateCard(
                card,
                front: front,
                back: back,
                example: example.isEmpty ? nil : example,
                pronunciation: nil,
                notes: notes.isEmpty ? nil : notes
            )
        } else {
            viewModel.createCard(
                front: front,
                back: back,
                example: example.isEmpty ? nil : example,
                pronunciation: nil,
                notes: notes.isEmpty ? nil : notes
            )
        }
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var viewModel = CardManagementViewModel(
        modelContext: ModelContext(
            try! ModelContainer(for: Deck.self, Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        ),
        deck: Deck(name: "Test Deck")
    )

    AddEditCardSheet(viewModel: viewModel, isPresented: $isPresented, card: nil)
}
