import SwiftUI

struct AuthView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case login, signup
        var id: String { rawValue }
    }

    @Bindable var appState: AppState
    @State private var mode: Mode = .login
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Mode", selection: $mode) {
                    Text("Login").tag(Mode.login)
                    Text("Sign up").tag(Mode.signup)
                }
                .pickerStyle(.segmented)

                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("auth.username")

                SecureField("Password", text: $password)
                    .accessibilityIdentifier("auth.password")

                if mode == .signup {
                    SecureField("Confirm password", text: $confirmPassword)
                        .accessibilityIdentifier("auth.confirmPassword")
                }

                Button(mode == .login ? "Login" : "Create account") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Benji")
        }
    }

    private func submit() {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !password.isEmpty else {
            appState.alertMessage = "Please enter username and password."
            return
        }

        if mode == .signup {
            guard password == confirmPassword else {
                appState.alertMessage = "Passwords do not match."
                return
            }
            appState.signUp(username: trimmed, password: password)
        } else {
            appState.login(username: trimmed, password: password)
        }
    }
}
