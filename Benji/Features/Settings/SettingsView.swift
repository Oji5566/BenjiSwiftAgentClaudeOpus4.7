import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState

    @State private var showingClearConfirmation = false
    @State private var exportURL: URL?
    @State private var categoryToEdit: Category?
    @State private var showingAddCategory = false

    var body: some View {
        NavigationStack {
            Form {
                if let user = appState.currentUser {
                    Section("Session") {
                        LabeledContent("Username", value: user.username)
                        Button("Sign out", role: .destructive) {
                            appState.signOut()
                        }
                    }
                }

                if let settings = appState.settings {
                    Section("Income") {
                        Picker("Income type", selection: Binding(get: {
                            settings.incomeType
                        }, set: {
                            settings.incomeType = $0
                            appState.completeOnboarding(incomeType: settings.incomeType, incomeAmount: settings.incomeAmount, hoursPerWeek: settings.hoursPerWeek, realWageEnabled: settings.realWageEnabled, monthlyFixedExpenses: settings.monthlyFixedExpenses)
                        })) {
                            ForEach(IncomeType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }

                        TextField("Income amount", value: Binding(get: {
                            settings.incomeAmount
                        }, set: {
                            settings.incomeAmount = $0
                            appState.completeOnboarding(incomeType: settings.incomeType, incomeAmount: settings.incomeAmount, hoursPerWeek: settings.hoursPerWeek, realWageEnabled: settings.realWageEnabled, monthlyFixedExpenses: settings.monthlyFixedExpenses)
                        }), format: .number)
                        .keyboardType(.decimalPad)

                        TextField("Hours per week", value: Binding(get: {
                            settings.hoursPerWeek
                        }, set: {
                            settings.hoursPerWeek = $0
                            appState.completeOnboarding(incomeType: settings.incomeType, incomeAmount: settings.incomeAmount, hoursPerWeek: settings.hoursPerWeek, realWageEnabled: settings.realWageEnabled, monthlyFixedExpenses: settings.monthlyFixedExpenses)
                        }), format: .number)
                        .keyboardType(.decimalPad)

                        Toggle("Real wage mode", isOn: Binding(get: {
                            settings.realWageEnabled
                        }, set: {
                            settings.realWageEnabled = $0
                            appState.completeOnboarding(incomeType: settings.incomeType, incomeAmount: settings.incomeAmount, hoursPerWeek: settings.hoursPerWeek, realWageEnabled: settings.realWageEnabled, monthlyFixedExpenses: settings.monthlyFixedExpenses)
                        }))

                        if settings.realWageEnabled {
                            TextField("Monthly fixed expenses", value: Binding(get: {
                                settings.monthlyFixedExpenses
                            }, set: {
                                settings.monthlyFixedExpenses = $0
                                appState.completeOnboarding(incomeType: settings.incomeType, incomeAmount: settings.incomeAmount, hoursPerWeek: settings.hoursPerWeek, realWageEnabled: settings.realWageEnabled, monthlyFixedExpenses: settings.monthlyFixedExpenses)
                            }), format: .number)
                            .keyboardType(.decimalPad)
                        }
                    }
                }

                Section("Categories") {
                    ForEach(appState.categories) { category in
                        HStack {
                            Label(category.name, systemImage: category.sfSymbol)
                            Spacer()
                            Button("Edit") { categoryToEdit = category }
                                .buttonStyle(.borderless)
                        }
                    }
                    .onDelete(perform: appState.deleteCategory)
                    .onMove(perform: appState.moveCategory)

                    Button("Add category") { showingAddCategory = true }
                }

                Section("Data") {
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label("Share export", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button("Export JSON") {
                        exportURL = appState.exportURL()
                    }

                    Button("Clear history", role: .destructive) {
                        showingClearConfirmation = true
                    }
                    .confirmationDialog("Clear all history?", isPresented: $showingClearConfirmation) {
                        Button("Clear", role: .destructive) {
                            appState.clearHistory()
                        }
                    }
                }

                Section("About") {
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                    LabeledContent("Version", value: version)
                }
            }
            .navigationTitle("Settings")
            .toolbar { EditButton() }
            .sheet(item: $categoryToEdit) { category in
                CategoryEditorView(title: "Edit Category", initialName: category.name, initialSymbol: category.sfSymbol) { name, symbol in
                    appState.updateCategory(category, name: name, symbol: symbol)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                CategoryEditorView(title: "Add Category", initialName: "", initialSymbol: "tag.fill") { name, symbol in
                    appState.addCategory(name: name, symbol: symbol)
                }
            }
        }
    }
}

private struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let initialName: String
    let initialSymbol: String
    let onSave: (String, String) -> Void

    @State private var name: String
    @State private var symbol: String

    init(title: String, initialName: String, initialSymbol: String, onSave: @escaping (String, String) -> Void) {
        self.title = title
        self.initialName = initialName
        self.initialSymbol = initialSymbol
        self.onSave = onSave
        _name = State(initialValue: initialName)
        _symbol = State(initialValue: initialSymbol)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("SF Symbol", text: $symbol)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Label(name.isEmpty ? "Preview" : name, systemImage: symbol.isEmpty ? "tag" : symbol)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), symbol.isEmpty ? "tag" : symbol)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}
