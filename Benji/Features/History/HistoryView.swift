import SwiftUI

struct HistoryView: View {
    @Bindable var appState: AppState
    @State private var period: HistoryPeriod = .daily
    @State private var editingEntry: Entry?

    private var entries: [Entry] {
        appState.historyEntries(period: period)
    }

    private var groupedEntries: [(String, [Entry])] {
        Dictionary(grouping: entries) { BenjiFormatters.sectionDate($0.timestamp) }
            .sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Period", selection: $period) {
                        ForEach(HistoryPeriod.allCases) { period in
                            Text(period.title).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                let stats = appState.historyStats(for: period)
                Section {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            StatCard(title: "Tracked", value: "\(stats.totalTracked)")
                            StatCard(title: "Total", value: BenjiFormatters.money(stats.totalAmount))
                        }

                        HStack(spacing: 12) {
                            StatCard(title: "Bought", value: BenjiFormatters.money(stats.boughtTotal))
                            StatCard(title: "Skipped", value: BenjiFormatters.money(stats.skippedTotal))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bought vs skipped")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            GeometryReader { proxy in
                                let width = max(proxy.size.width, 1)
                                let buyWidth = width * stats.boughtRatio
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.2))
                                    RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.35)).frame(width: buyWidth)
                                }
                            }
                            .frame(height: 10)
                            Text("\(Int(stats.boughtRatio * 100))% bought")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                if entries.isEmpty {
                    ContentUnavailableView("No history", systemImage: "tray")
                } else {
                    ForEach(groupedEntries, id: \.0) { date, group in
                        Section(date) {
                            ForEach(group) { entry in
                                Button {
                                    editingEntry = entry
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
                                        VStack(alignment: .trailing) {
                                            Text(BenjiFormatters.money(entry.amount))
                                            Text(EarningsCalculator.timeString(minutes: entry.computedMinutes))
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        appState.deleteEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(appState: appState, entry: entry)
            }
        }
    }
}

private struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var appState: AppState
    let entry: Entry

    @State private var name: String
    @State private var amount: Double
    @State private var categoryID: UUID?
    @State private var decision: DecisionStatus
    @State private var timestamp: Date
    @State private var notes: String

    init(appState: AppState, entry: Entry) {
        self.appState = appState
        self.entry = entry
        _name = State(initialValue: entry.name)
        _amount = State(initialValue: entry.amount)
        _decision = State(initialValue: entry.decision)
        _timestamp = State(initialValue: entry.timestamp)
        _notes = State(initialValue: entry.notes)
        _categoryID = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                Picker("Category", selection: Binding(get: {
                    categoryID ?? appState.categories.first(where: { $0.name == entry.categoryName })?.id ?? appState.categories.first?.id ?? UUID()
                }, set: { categoryID = $0 })) {
                    ForEach(appState.categories) { category in
                        Label(category.name, systemImage: category.sfSymbol).tag(category.id)
                    }
                }
                Picker("Status", selection: $decision) {
                    Text("Buy").tag(DecisionStatus.bought)
                    Text("Skip").tag(DecisionStatus.skipped)
                    Text("Watchlist").tag(DecisionStatus.watchlist)
                }
                DatePicker("Timestamp", selection: $timestamp)
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let category = appState.categories.first(where: { $0.id == categoryID })
                        appState.updateEntry(entry, name: name, amount: amount, category: category, timestamp: timestamp, decision: decision, notes: notes)
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
