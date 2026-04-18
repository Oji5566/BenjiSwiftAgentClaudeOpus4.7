import Foundation
import Observation
import SwiftData

@Observable
final class AppState {
    var currentUser: UserAccount?
    var settings: AppSettings?
    var categories: [Category] = []
    var entries: [Entry] = []
    var selectedTab: TabItem = .calculator

    var alertMessage: String?

    private let authService = AuthService()
    private let sessionService = SessionService()
    private let exportService = ExportService()

    private(set) var modelContext: ModelContext?

    enum TabItem: Hashable {
        case calculator, history, watchlist, settings
    }

    func configure(context: ModelContext) {
        modelContext = context
        bootstrapSession()
    }

    func bootstrapSession() {
        guard let context = modelContext,
              let userID = sessionService.currentUserID() else { return }

        let descriptor = FetchDescriptor<UserAccount>(predicate: #Predicate { $0.id == userID })
        if let user = try? context.fetch(descriptor).first {
            currentUser = user
            reloadAll()
        }
    }

    func signUp(username: String, password: String) {
        guard let context = modelContext else { return }
        do {
            let user = try authService.signUp(username: username, password: password, context: context)
            currentUser = user
            sessionService.storeCurrentUserID(user.id)
            reloadAll()
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func login(username: String, password: String) {
        guard let context = modelContext else { return }
        do {
            let user = try authService.login(username: username, password: password, context: context)
            currentUser = user
            sessionService.storeCurrentUserID(user.id)
            reloadAll()
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func signOut() {
        sessionService.clear()
        currentUser = nil
        settings = nil
        categories = []
        entries = []
        selectedTab = .calculator
    }

    func completeOnboarding(incomeType: IncomeType, incomeAmount: Double, hoursPerWeek: Double, realWageEnabled: Bool, monthlyFixedExpenses: Double) {
        guard let context = modelContext, let user = currentUser else { return }

        let descriptor = FetchDescriptor<AppSettings>(predicate: #Predicate { $0.userID == user.id })
        let existing = (try? context.fetch(descriptor).first)
        let target = existing ?? AppSettings(userID: user.id)
        target.incomeType = incomeType
        target.incomeAmount = incomeAmount
        target.hoursPerWeek = hoursPerWeek
        target.realWageEnabled = realWageEnabled
        target.monthlyFixedExpenses = monthlyFixedExpenses

        if existing == nil { context.insert(target) }

        user.onboardingComplete = true
        try? context.save()
        reloadAll()
    }

    func saveEntry(name: String, amount: Double, category: Category?, timestamp: Date, decision: DecisionStatus, notes: String = "") {
        guard let context = modelContext, let user = currentUser, let settings else { return }
        let selectedCategory = category ?? categories.first

        let entry = Entry(
            userID: user.id,
            name: name.isEmpty ? "Unnamed" : name,
            amount: amount,
            categoryName: selectedCategory?.name ?? "Other",
            categorySymbol: selectedCategory?.sfSymbol ?? "questionmark.circle.fill",
            timestamp: timestamp,
            computedMinutes: EarningsCalculator.minutes(for: amount, settings: settings),
            decision: decision,
            notes: notes
        )

        context.insert(entry)
        try? context.save()
        reloadEntries()
    }

    func updateEntry(_ entry: Entry, name: String, amount: Double, category: Category?, timestamp: Date, decision: DecisionStatus, notes: String) {
        guard let settings else { return }
        entry.name = name.isEmpty ? "Unnamed" : name
        entry.amount = amount
        entry.timestamp = timestamp
        entry.decision = decision
        entry.notes = notes
        if let category {
            entry.categoryName = category.name
            entry.categorySymbol = category.sfSymbol
        }
        entry.computedMinutes = EarningsCalculator.minutes(for: amount, settings: settings)
        try? modelContext?.save()
        reloadEntries()
    }

    func deleteEntries(at offsets: IndexSet, from source: [Entry]) {
        guard let context = modelContext else { return }
        for offset in offsets {
            context.delete(source[offset])
        }
        try? context.save()
        reloadEntries()
    }

    func deleteEntry(_ entry: Entry) {
        modelContext?.delete(entry)
        try? modelContext?.save()
        reloadEntries()
    }

    func clearHistory() {
        guard let context = modelContext else { return }
        entries.forEach(context.delete)
        try? context.save()
        reloadEntries()
    }

    func addCategory(name: String, symbol: String) {
        guard let user = currentUser, let context = modelContext else { return }
        let nextOrder = (categories.map(\.sortOrder).max() ?? -1) + 1
        let category = Category(userID: user.id, name: name, sfSymbol: symbol, sortOrder: nextOrder)
        context.insert(category)
        try? context.save()
        reloadCategories()
    }

    func updateCategory(_ category: Category, name: String, symbol: String) {
        let oldName = category.name
        category.name = name
        category.sfSymbol = symbol

        entries.filter { $0.categoryName == oldName }.forEach {
            $0.categoryName = name
            $0.categorySymbol = symbol
        }

        try? modelContext?.save()
        reloadAll()
    }

    func deleteCategory(at offsets: IndexSet) {
        guard let context = modelContext else { return }
        for offset in offsets {
            context.delete(categories[offset])
        }
        try? context.save()
        reloadCategories()
    }

    func moveCategory(from source: IndexSet, to destination: Int) {
        var reordered = categories
        reordered.move(fromOffsets: source, toOffset: destination)
        for (idx, category) in reordered.enumerated() {
            category.sortOrder = idx
        }
        try? modelContext?.save()
        reloadCategories()
    }

    func exportURL() -> URL? {
        guard let user = currentUser, let settings else { return nil }
        return try? exportService.exportJSON(user: user, settings: settings, categories: categories, entries: entries)
    }

    var watchlistEntries: [Entry] {
        entries.filter { $0.decision == .watchlist }
    }

    func historyEntries(period: HistoryPeriod) -> [Entry] {
        HistoryService.filtered(entries: entries.filter { $0.decision != .watchlist && $0.decision != .noTrack }, period: period)
            .sorted(by: { $0.timestamp > $1.timestamp })
    }

    func historyStats(for period: HistoryPeriod) -> HistoryStats {
        HistoryService.stats(entries: historyEntries(period: period))
    }

    func dismissAlert() {
        alertMessage = nil
    }

    private func reloadAll() {
        reloadSettings()
        reloadCategories()
        reloadEntries()
    }

    private func reloadSettings() {
        guard let context = modelContext, let user = currentUser else { return }
        let descriptor = FetchDescriptor<AppSettings>(predicate: #Predicate { $0.userID == user.id })
        settings = try? context.fetch(descriptor).first
    }

    private func reloadCategories() {
        guard let context = modelContext, let user = currentUser else { return }
        var descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.userID == user.id })
        descriptor.sortBy = [SortDescriptor(\.sortOrder, order: .forward)]
        categories = (try? context.fetch(descriptor)) ?? []
    }

    private func reloadEntries() {
        guard let context = modelContext, let user = currentUser else { return }
        var descriptor = FetchDescriptor<Entry>(predicate: #Predicate { $0.userID == user.id })
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        entries = (try? context.fetch(descriptor)) ?? []
    }
}
