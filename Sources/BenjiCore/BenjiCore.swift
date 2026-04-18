import Foundation

public enum IncomeType: String, Codable, CaseIterable, Sendable {
    case hourly, monthly, annual
}

public enum DecisionStatus: String, Codable, CaseIterable, Sendable {
    case bought, skipped, watchlist, noTrack
}

public enum HistoryPeriod: String, Codable, CaseIterable, Sendable {
    case daily, weekly, monthly, yearly
}

public struct AppSettingsData: Codable, Sendable {
    public var incomeType: IncomeType
    public var incomeAmount: Double
    public var hoursPerWeek: Double
    public var realWageEnabled: Bool
    public var monthlyFixedExpenses: Double

    public init(incomeType: IncomeType, incomeAmount: Double, hoursPerWeek: Double, realWageEnabled: Bool, monthlyFixedExpenses: Double) {
        self.incomeType = incomeType
        self.incomeAmount = incomeAmount
        self.hoursPerWeek = hoursPerWeek
        self.realWageEnabled = realWageEnabled
        self.monthlyFixedExpenses = monthlyFixedExpenses
    }
}

public struct EntryData: Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Double
    public var category: String
    public var timestamp: Date
    public var computedMinutes: Double
    public var decision: DecisionStatus
    public var notes: String

    public init(id: UUID = UUID(), name: String, amount: Double, category: String, timestamp: Date, computedMinutes: Double, decision: DecisionStatus, notes: String = "") {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.timestamp = timestamp
        self.computedMinutes = computedMinutes
        self.decision = decision
        self.notes = notes
    }
}

public enum EarningsCalculator {
    public static let weeksPerMonth = 52.0 / 12.0

    public static func earningPerMinute(settings: AppSettingsData) -> Double {
        guard settings.hoursPerWeek > 0 else { return 0 }
        let basePerMinute: Double

        switch settings.incomeType {
        case .hourly:
            basePerMinute = settings.incomeAmount / 60
        case .monthly:
            basePerMinute = settings.incomeAmount / (settings.hoursPerWeek * weeksPerMonth) / 60
        case .annual:
            basePerMinute = settings.incomeAmount / (settings.hoursPerWeek * 52) / 60
        }

        guard settings.realWageEnabled else { return max(basePerMinute, 0) }

        let expensePerMinute = settings.monthlyFixedExpenses / (settings.hoursPerWeek * weeksPerMonth) / 60
        return max(basePerMinute - expensePerMinute, 0)
    }

    public static func minutesToEarn(amount: Double, settings: AppSettingsData) -> Double {
        let rate = earningPerMinute(settings: settings)
        guard rate > 0, amount > 0 else { return 0 }
        return amount / rate
    }
}

public enum HistoryFilter {
    public static func filtered(_ entries: [EntryData], period: HistoryPeriod, now: Date = .now, calendar: Calendar = .current) -> [EntryData] {
        entries.filter { entry in
            switch period {
            case .daily:
                return calendar.isDate(entry.timestamp, inSameDayAs: now)
            case .weekly:
                guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return false }
                return weekInterval.contains(entry.timestamp)
            case .monthly:
                return calendar.isDate(entry.timestamp, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(entry.timestamp, equalTo: now, toGranularity: .year)
            }
        }
    }
}

public struct HistoryStats: Equatable, Sendable {
    public var totalTracked: Int
    public var totalAmount: Double
    public var boughtTotal: Double
    public var skippedTotal: Double
    public var boughtRatio: Double
}

public enum StatsAggregator {
    public static func makeStats(entries: [EntryData]) -> HistoryStats {
        let bought = entries.filter { $0.decision == .bought }
        let skipped = entries.filter { $0.decision == .skipped }
        let totalCount = entries.count
        let boughtCount = bought.count

        return HistoryStats(
            totalTracked: totalCount,
            totalAmount: entries.reduce(0) { $0 + $1.amount },
            boughtTotal: bought.reduce(0) { $0 + $1.amount },
            skippedTotal: skipped.reduce(0) { $0 + $1.amount },
            boughtRatio: totalCount == 0 ? 0 : Double(boughtCount) / Double(totalCount)
        )
    }
}

public struct ExportPayload: Codable, Sendable {
    public struct UserData: Codable, Sendable {
        public var id: UUID
        public var username: String
        public init(id: UUID, username: String) {
            self.id = id
            self.username = username
        }
    }

    public var exportedAt: Date
    public var user: UserData
    public var settings: AppSettingsData
    public var categories: [String]
    public var entries: [EntryData]

    public init(exportedAt: Date, user: UserData, settings: AppSettingsData, categories: [String], entries: [EntryData]) {
        self.exportedAt = exportedAt
        self.user = user
        self.settings = settings
        self.categories = categories
        self.entries = entries
    }
}

public enum ExportJSONBuilder {
    public static func data(from payload: ExportPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }
}
