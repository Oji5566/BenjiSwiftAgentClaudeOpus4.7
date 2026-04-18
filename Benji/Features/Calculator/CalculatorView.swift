import SwiftUI

struct CalculatorView: View {
    @Bindable var appState: AppState
    @State private var input = "0"
    @State private var showSheet = false
    @State private var selectedDecision: DecisionStatus?
    @State private var entryName = ""
    @State private var selectedCategoryID: UUID?
    @State private var timestamp: Date = .now

    private var amount: Double { Double(input) ?? 0 }

    private var minutes: Double {
        guard let settings = appState.settings else { return 0 }
        return EarningsCalculator.minutes(for: amount, settings: settings)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(BenjiFormatters.money(amount))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    Text(amount > 0 ? "≈ \(EarningsCalculator.timeString(minutes: minutes)) of work" : "Enter an amount")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(["1","2","3","4","5","6","7","8","9",".","0","⌫"], id: \.self) { key in
                        Button(key) {
                            keyTapped(key)
                        }
                        .buttonStyle(.bordered)
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .accessibilityIdentifier("calculator.key.\(key)")
                    }
                }

                Button("Enter") {
                    guard amount > 0 else { return }
                    selectedDecision = nil
                    entryName = ""
                    selectedCategoryID = appState.categories.first?.id
                    timestamp = .now
                    showSheet = true
                    Haptics.tap()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationTitle("Calculator")
            .sheet(isPresented: $showSheet) {
                decisionSheet
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var decisionSheet: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Amount", value: BenjiFormatters.money(amount))
                    LabeledContent("Equivalent", value: EarningsCalculator.timeString(minutes: minutes))
                }

                if selectedDecision == nil {
                    Section("Decision") {
                        Button("Buy") { selectedDecision = .bought }
                        Button("Watchlist") { selectedDecision = .watchlist }
                        Button("Skip") { selectedDecision = .skipped }
                        Button("No track") {
                            showSheet = false
                            resetInput()
                        }
                    }
                } else {
                    Section("Save") {
                        TextField("Name", text: $entryName)
                        Picker("Category", selection: Binding(get: {
                            selectedCategoryID ?? appState.categories.first?.id ?? UUID()
                        }, set: { selectedCategoryID = $0 })) {
                            ForEach(appState.categories) { category in
                                Label(category.name, systemImage: category.sfSymbol).tag(category.id)
                            }
                        }
                        DatePicker("Timestamp", selection: $timestamp)
                    }

                    Button("Save") {
                        let category = appState.categories.first(where: { $0.id == selectedCategoryID })
                        appState.saveEntry(name: entryName, amount: amount, category: category, timestamp: timestamp, decision: selectedDecision ?? .bought)
                        showSheet = false
                        resetInput()
                        Haptics.success()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Track purchase")
        }
    }

    private func keyTapped(_ key: String) {
        Haptics.tap()

        switch key {
        case "⌫":
            input = input.count > 1 ? String(input.dropLast()) : "0"
        case ".":
            if !input.contains(".") { input += "." }
        default:
            if input == "0" {
                input = key
            } else if input.contains("."), let decimal = input.split(separator: ".").last, decimal.count >= 2 {
                return
            } else {
                input += key
            }
        }
    }

    private func resetInput() {
        input = "0"
    }
}
