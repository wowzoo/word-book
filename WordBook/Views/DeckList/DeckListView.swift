import SwiftUI
import SwiftData

struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDeck: Deck?

    @State private var viewModel: DeckListViewModel?
    @State private var showingAddDeck = false
    @State private var showingImportSheet = false
    @State private var deckToExport: Deck?

    var body: some View {
        VStack(spacing: 0) {
            if let viewModel = viewModel {
                // Header
                header(viewModel: viewModel)

                // Content
                if viewModel.filteredDecks.isEmpty {
                    emptyState
                } else {
                    deckList(viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Decks")
        .onAppear {
            if viewModel == nil {
                viewModel = DeckListViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showingAddDeck) {
            if let viewModel = viewModel {
                AddDeckSheet(viewModel: viewModel, isPresented: $showingAddDeck)
            }
        }
        .sheet(isPresented: $showingImportSheet) {
            if let viewModel = viewModel {
                ImportDeckSheet(viewModel: viewModel, isPresented: $showingImportSheet)
            } else {
                Text("Loading...")
            }
        }
        .sheet(item: $deckToExport) { deck in
            if let viewModel = viewModel {
                ExportDeckSheet(
                    deck: deck,
                    viewModel: viewModel,
                    isPresented: Binding(
                        get: { deckToExport != nil },
                        set: { if !$0 { deckToExport = nil } }
                    )
                )
            } else {
                VStack {
                    Text("Error: Unable to load export data")
                    Button("Close") {
                        deckToExport = nil
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Header

    private func header(viewModel: DeckListViewModel) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("My Decks")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: { showingImportSheet = true }) {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: { showingAddDeck = true }) {
                    Label("New Deck", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            // Search Bar
            SearchBarView(viewModel: viewModel)
        }
        .padding()
    }

    // MARK: - Deck List

    private func deckList(viewModel: DeckListViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredDecks) { deck in
                    DeckCard(deck: deck, isSelected: selectedDeck?.id == deck.id)
                        .onTapGesture {
                            selectedDeck = deck
                        }
                        .contextMenu {
                            Button("Study Now", systemImage: "play.fill") {
                                // TODO: Start study session
                            }

                            Button("Export...", systemImage: "square.and.arrow.up") {
                                deckToExport = deck
                            }

                            Divider()

                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.deleteDeck(deck)
                                if selectedDeck?.id == deck.id {
                                    selectedDeck = nil
                                }
                            }
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Decks", systemImage: "books.vertical")
        } description: {
            Text("Create your first deck to start learning vocabulary")
        } actions: {
            Button("Create Deck") {
                showingAddDeck = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - Search Bar View

private struct SearchBarView: View {
    let viewModel: DeckListViewModel?

    var body: some View {
        if let viewModel = viewModel {
            @Bindable var vm = viewModel

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search decks...", text: $vm.searchText)
                    .textFieldStyle(.plain)

                if !vm.searchText.isEmpty {
                    Button(action: { vm.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationSplitView {
        Text("Sidebar")
    } content: {
        DeckListView(selectedDeck: .constant(nil))
    } detail: {
        Text("Detail")
    }
    .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
