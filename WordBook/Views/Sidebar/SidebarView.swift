import SwiftUI

struct SidebarView: View {
    @Binding var selectedSection: SidebarSection?

    var body: some View {
        List(selection: $selectedSection) {
            ForEach(SidebarSection.allCases) { section in
                NavigationLink(value: section) {
                    Label(section.rawValue, systemImage: section.icon)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("WordBook")
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selectedSection: .constant(.decks))
    } detail: {
        Text("Detail")
    }
}
