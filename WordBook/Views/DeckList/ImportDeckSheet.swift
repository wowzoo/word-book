import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportDeckSheet: View {
    let viewModel: DeckListViewModel
    @Binding var isPresented: Bool

    @State private var showingFilePicker = false
    @State private var importedDeck: Deck?
    @State private var alertMessage: String?
    @State private var showingAlert = false
    @State private var alertType: AlertType = .error

    enum AlertType {
        case success, error, info
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            Text("Import Deck")
                .font(Typography.heading)

            // Icon
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 48))
                .foregroundStyle(ColorTheme.textSecondary)

            // Description
            VStack(spacing: Spacing.xs) {
                Text("Import a deck from a JSON file")
                    .font(Typography.body)

                Text("All cards and learning progress will be preserved")
                    .font(Typography.caption)
                    .foregroundStyle(ColorTheme.textSecondary)
            }

            Divider()

            // Info Box
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(ColorTheme.textSecondary)
                    Text("What will be imported:")
                        .font(Typography.caption)
                        .foregroundStyle(ColorTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("• All card content and examples")
                    Text("• SRS progress and intervals")
                    Text("• Learning states and statistics")
                    Text("• New UUIDs will be generated to avoid conflicts")
                }
                .font(Typography.footnote)
                .foregroundStyle(ColorTheme.textSecondary)
                .padding(.leading, Spacing.lg)
            }

            Spacer()

            // Buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Choose File...") {
                    showingFilePicker = true
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom, Spacing.md)
        }
        .padding(Spacing.lg)
        .frame(width: 450, height: 420)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if alertType == .success {
                    isPresented = false
                }
            }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var alertTitle: String {
        switch alertType {
        case .success: return "Import Successful"
        case .error: return "Import Failed"
        case .info: return "Import Info"
        }
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importFile(from: url)

        case .failure(let error):
            alertType = .error
            alertMessage = "Failed to select file: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func importFile(from url: URL) {
        // Read file data
        guard url.startAccessingSecurityScopedResource() else {
            alertType = .error
            alertMessage = "Unable to access file. Please check permissions."
            showingAlert = true
            return
        }

        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)

            // Validate first
            guard viewModel.validateImportFile(data) else {
                alertType = .error
                alertMessage = "Invalid file format. Please select a valid JSON file."
                showingAlert = true
                return
            }

            // Import
            let result = viewModel.importDeck(from: data)
            switch result {
            case .success(let deck):
                alertType = .success
                alertMessage = "Successfully imported deck '\(deck.name)' with \(deck.totalCards) cards."
                importedDeck = deck
                showingAlert = true

            case .failure(let error):
                alertType = .error
                alertMessage = error.localizedDescription
                showingAlert = true
            }

        } catch {
            alertType = .error
            alertMessage = "Failed to read file: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    ImportDeckSheet(
        viewModel: DeckListViewModel(modelContext: container.mainContext),
        isPresented: $isPresented
    )
}
