import SwiftUI
import SwiftData

struct AddDeckSheet: View {
    @Bindable var viewModel: DeckListViewModel
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedColor: String = "#007AFF"

    private let colorOptions = [
        "#007AFF", // Blue
        "#34C759", // Green
        "#FF9500", // Orange
        "#FF3B30", // Red
        "#AF52DE", // Purple
        "#5856D6", // Indigo
        "#FF2D55", // Pink
        "#5AC8FA", // Light Blue
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Create New Deck")
                .font(.title2)
                .fontWeight(.bold)

            // Form
            Form {
                // Name
                TextField("Deck Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                // Description
                TextField("Description (optional)", text: $description)
                    .textFieldStyle(.roundedBorder)

                // Color Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .blue)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
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

                Button("Create") {
                    createDeck()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
            }
            .padding()
        }
        .frame(width: 400)
        .padding()
    }

    private func createDeck() {
        viewModel.createDeck(name: name, description: description, color: selectedColor)
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var viewModel = DeckListViewModel(
        modelContext: ModelContext(
            try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        )
    )

    AddDeckSheet(viewModel: viewModel, isPresented: $isPresented)
}
