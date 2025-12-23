import SwiftUI
import SwiftData

struct CardManagementView: View {
    @Environment(\.modelContext) private var modelContext
    let deck: Deck

    @State private var viewModel: CardManagementViewModel?
    @State private var showingAddCard = false
    @State private var showingStudy = false
    @State private var cardToEdit: Card?

    var body: some View {
        VStack(spacing: 0) {
            if let viewModel = viewModel {
                // Header
                header(viewModel: viewModel)

                // Content
                if viewModel.filteredCards.isEmpty {
                    emptyState
                } else {
                    cardList(viewModel: viewModel)
                }
            }
        }
        .navigationTitle(deck.name)
        .onAppear {
            viewModel = CardManagementViewModel(modelContext: modelContext, deck: deck)
        }
        .onChange(of: deck.id) { _, _ in
            viewModel = CardManagementViewModel(modelContext: modelContext, deck: deck)
        }
        .sheet(isPresented: $showingAddCard) {
            if let viewModel = viewModel {
                AddEditCardSheet(
                    viewModel: viewModel,
                    isPresented: $showingAddCard,
                    card: nil
                )
            }
        }
        .sheet(isPresented: $showingStudy) {
            StudyView(deck: deck)
        }
        .sheet(item: $cardToEdit) { card in
            if let viewModel = viewModel {
                AddEditCardSheet(
                    viewModel: viewModel,
                    isPresented: Binding(
                        get: { cardToEdit != nil },
                        set: { if !$0 { cardToEdit = nil } }
                    ),
                    card: card
                )
            }
        }
    }

    // MARK: - Header

    private func header(viewModel: CardManagementViewModel) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(deck.totalCards) cards · \(deck.dueCards) due")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if deck.dueCards > 0 || deck.newCards > 0 {
                    Button(action: { showingStudy = true }) {
                        Label("Study Now", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                Button(action: { showingAddCard = true }) {
                    Label("Add Card", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            // Filter & Search
            FilterSearchView(viewModel: viewModel)
        }
        .padding()
    }

    // MARK: - Card List

    private func cardList(viewModel: CardManagementViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredCards) { card in
                    CardRow(card: card)
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                cardToEdit = card
                            }
                            Divider()
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewModel.deleteCard(card)
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
            Label("No Cards", systemImage: "rectangle.on.rectangle.slash")
        } description: {
            Text(viewModel?.filterOption == .all ?
                "Add your first card to start learning" :
                "No cards match the current filter")
        } actions: {
            if viewModel?.filterOption == .all {
                Button("Add Card") {
                    showingAddCard = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
}

// MARK: - Filter Search View

private struct FilterSearchView: View {
    let viewModel: CardManagementViewModel?

    var body: some View {
        if let viewModel = viewModel {
            @Bindable var vm = viewModel

            HStack {
                // Filter
                Picker("Filter", selection: $vm.filterOption) {
                    ForEach(CardManagementViewModel.FilterOption.allCases, id: \.self) { option in
                        Label(option.rawValue, systemImage: option.icon)
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 400)

                Spacer()

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search cards...", text: $vm.searchText)
                        .textFieldStyle(.plain)
                        .frame(width: 200)

                    if !vm.searchText.isEmpty {
                        Button(action: { vm.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
            }
        }
    }
}

#Preview {
    let deck = Deck(name: "Test Deck", descriptionText: "Preview deck")
    CardManagementView(deck: deck)
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
