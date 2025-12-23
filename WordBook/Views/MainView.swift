import SwiftUI
import SwiftData

// MARK: - Sidebar Section

enum SidebarSection: String, Identifiable, CaseIterable {
    case decks = "Decks"
    case statistics = "Statistics"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .decks: return "books.vertical.fill"
        case .statistics: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Main View

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSection: SidebarSection? = .decks
    @State private var selectedDeck: Deck?

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 250)
        } content: {
            contentView
                .navigationSplitViewColumnWidth(min: 300, ideal: 350)
        } detail: {
            detailView
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedSection {
        case .decks:
            DeckListView(selectedDeck: $selectedDeck)
        case .statistics:
            StatisticsView()
        case .settings:
            SettingsView()
        case nil:
            ContentUnavailableView(
                "Select a section",
                systemImage: "sidebar.left",
                description: Text("Choose a section from the sidebar")
            )
        }
    }

    @ViewBuilder
    private var detailView: some View {
        if let deck = selectedDeck {
            CardManagementView(deck: deck)
        } else {
            ContentUnavailableView(
                "Select a deck",
                systemImage: "book.closed",
                description: Text("Choose a deck to view and manage cards")
            )
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
