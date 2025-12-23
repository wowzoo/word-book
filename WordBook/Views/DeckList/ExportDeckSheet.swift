import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportDeckSheet: View {
    let deck: Deck
    let viewModel: DeckListViewModel
    @Binding var isPresented: Bool

    @State private var showingExportPicker = false
    @State private var alertMessage: String?
    @State private var showingAlert = false
    @State private var exportData: Data?

    var body: some View {
        VStack(spacing: 20) {
            Text("Export Deck")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: deck.color) ?? .blue)
                        .frame(width: 24, height: 24)
                    Text(deck.name)
                        .font(.headline)
                }

                Text("\(deck.totalCards) cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("Export includes:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("• All card content (front, back, examples, etc.)")
                    Text("• SRS progress (intervals, ease factors)")
                    Text("• Learning states and statistics")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Export...") {
                    prepareExport()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 450, height: 350)
        .background(Color(nsColor: .windowBackgroundColor))
        .fileExporter(
            isPresented: $showingExportPicker,
            document: ExportDocument(data: exportData, filename: viewModel.suggestedFilename(for: deck)),
            contentType: .json
        ) { result in
            handleExportResult(result)
        }
        .alert("Export Result", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage?.contains("successfully") ?? false {
                    isPresented = false
                }
            }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func prepareExport() {
        switch viewModel.exportDeck(deck) {
        case .success(let data):
            exportData = data
            showingExportPicker = true
        case .failure(let error):
            alertMessage = "Export preparation failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            alertMessage = "Deck '\(deck.name)' exported successfully to:\n\(url.path)"
            showingAlert = true
        case .failure(let error):
            alertMessage = "Export failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Export Document

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data
    var filename: String

    init(data: Data?, filename: String = "deck.json") {
        self.data = data ?? Data()
        self.filename = filename
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
        self.filename = configuration.file.filename ?? "deck.json"
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let deck = Deck(name: "Test Deck", descriptionText: "Preview deck")

    ExportDeckSheet(
        deck: deck,
        viewModel: DeckListViewModel(modelContext: container.mainContext),
        isPresented: $isPresented
    )
}
