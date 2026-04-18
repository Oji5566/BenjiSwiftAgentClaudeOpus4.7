import SwiftUI
import SwiftData

@main
struct BenjiApp: App {
    @State private var appState = AppState()
    private let container = BenjiModelContainer.make()

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
        }
        .modelContainer(container)
    }
}
