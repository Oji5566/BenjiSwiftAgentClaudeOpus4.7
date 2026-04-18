import SwiftUI

struct TabShellView: View {
    @Bindable var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CalculatorView(appState: appState)
                .tabItem { Label("Calculator", systemImage: "plus.forwardslash.minus") }
                .tag(AppState.TabItem.calculator)

            HistoryView(appState: appState)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(AppState.TabItem.history)

            WatchlistView(appState: appState)
                .tabItem { Label("Watchlist", systemImage: "bookmark") }
                .tag(AppState.TabItem.watchlist)

            SettingsView(appState: appState)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppState.TabItem.settings)
        }
        .tint(.accentColor)
    }
}
