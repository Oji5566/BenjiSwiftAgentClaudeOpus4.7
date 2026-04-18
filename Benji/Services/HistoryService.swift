import Foundation

struct HistoryStats {
    var totalTracked: Int
    var totalAmount: Double
    var boughtTotal: Double
    var skippedTotal: Double
    var boughtRatio: Double
}

enum HistoryService {
    static func filtered(entries: [Entry], period: HistoryPeriod, now: Date = .now, calendar: Calendar = .current) -> [Entry] {
        entries.filter { entry in
            switch period {
            case .daily:
                return calendar.isDate(entry.timestamp, inSameDayAs: now)
            case .weekly:
                guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return false }
                return interval.contains(entry.timestamp)
            case .monthly:
                return calendar.isDate(entry.timestamp, equalTo: now, toGranularity: .month)
            case .yearly:
                return calendar.isDate(entry.timestamp, equalTo: now, toGranularity: .year)
            }
        }
    }

    static func stats(entries: [Entry]) -> HistoryStats {
        let bought = entries.filter { $0.decision == .bought }
        let skipped = entries.filter { $0.decision == .skipped }

        return HistoryStats(
            totalTracked: entries.count,
            totalAmount: entries.reduce(0) { $0 + $1.amount },
            boughtTotal: bought.reduce(0) { $0 + $1.amount },
            skippedTotal: skipped.reduce(0) { $0 + $1.amount },
            boughtRatio: entries.isEmpty ? 0 : Double(bought.count) / Double(entries.count)
        )
    }
}
