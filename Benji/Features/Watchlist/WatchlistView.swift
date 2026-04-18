import SwiftUI

struct WatchlistView: View {
    @Bindable var appState: AppState
    @State private var selected: Entry?

    var body: some View {
        NavigationStack {
            List {
                if appState.watchlistEntries.isEmpty {
                    ContentUnavailableView("Nothing on watchlist", systemImage: "bookmark")
                } else {
                    ForEach(appState.watchlistEntries) { entry in
                        Button {
                            selected = entry
                        } label: {
                            HStack {
                                Image(systemName: entry.categorySymbol)
                                    .foregroundStyle(.secondary)
                                VStack(alignment: .leading) {
                                    Text(entry.name)
                                    Text(BenjiFormatters.relative(entry.timestamp))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(BenjiFormatters.money(entry.amount))
                            }
                        }
                        .swipeActions {
                            Button("Buy") {
                                appState.updateEntry(entry, name: entry.name, amount: entry.amount, category: appState.categories.first(where: { $0.name == entry.categoryName }), timestamp: entry.timestamp, decision: .bought, notes: entry.notes)
                            }
                            .tint(.green)

                            Button("Skip") {
                                appState.updateEntry(entry, name: entry.name, amount: entry.amount, category: appState.categories.first(where: { $0.name == entry.categoryName }), timestamp: entry.timestamp, decision: .skipped, notes: entry.notes)
                            }
                            .tint(.orange)

                            Button(role: .destructive) {
                                appState.deleteEntry(entry)
                            } label: {
                                Label("Forget", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button("Move to Buy") {
                                appState.updateEntry(entry, name: entry.name, amount: entry.amount, category: appState.categories.first(where: { $0.name == entry.categoryName }), timestamp: entry.timestamp, decision: .bought, notes: entry.notes)
                            }
                            Button("Move to Skip") {
                                appState.updateEntry(entry, name: entry.name, amount: entry.amount, category: appState.categories.first(where: { $0.name == entry.categoryName }), timestamp: entry.timestamp, decision: .skipped, notes: entry.notes)
                            }
                            Button("Delete", role: .destructive) {
                                appState.deleteEntry(entry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .sheet(item: $selected) { entry in
                EntryEditorView(appState: appState, entry: entry)
            }
        }
    }
}
