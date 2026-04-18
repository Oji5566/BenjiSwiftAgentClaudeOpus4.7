import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appState: AppState

    var body: some View {
        Group {
            if appState.currentUser == nil {
                AuthView(appState: appState)
            } else if appState.currentUser?.onboardingComplete == false || appState.settings == nil {
                OnboardingView(appState: appState)
            } else {
                TabShellView(appState: appState)
            }
        }
        .onAppear {
            if appState.modelContext == nil {
                appState.configure(context: modelContext)
            }
        }
        .alert("Benji", isPresented: Binding(
            get: { appState.alertMessage != nil },
            set: { _ in appState.dismissAlert() }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appState.alertMessage ?? "")
        }
    }
}
