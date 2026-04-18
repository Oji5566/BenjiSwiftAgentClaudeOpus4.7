import XCTest
@testable import BenjiCore

final class BenjiCoreTests: XCTestCase {
    func testHourlyMonthlyAnnualPerMinuteMath() {
        let hourly = AppSettingsData(incomeType: .hourly, incomeAmount: 60, hoursPerWeek: 40, realWageEnabled: false, monthlyFixedExpenses: 0)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: hourly), 1, accuracy: 0.0001)

        let monthly = AppSettingsData(incomeType: .monthly, incomeAmount: 4333.3333, hoursPerWeek: 40, realWageEnabled: false, monthlyFixedExpenses: 0)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: monthly), 0.4167, accuracy: 0.0002)

        let annual = AppSettingsData(incomeType: .annual, incomeAmount: 52_000, hoursPerWeek: 40, realWageEnabled: false, monthlyFixedExpenses: 0)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: annual), 0.4167, accuracy: 0.0002)
    }

    func testRealWageAdjustmentAndFlooring() {
        let adjusted = AppSettingsData(incomeType: .monthly, incomeAmount: 5000, hoursPerWeek: 40, realWageEnabled: true, monthlyFixedExpenses: 2000)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: adjusted), 0.2885, accuracy: 0.0002)

        let floored = AppSettingsData(incomeType: .monthly, incomeAmount: 1000, hoursPerWeek: 40, realWageEnabled: true, monthlyFixedExpenses: 5000)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: floored), 0, accuracy: 0.0001)
    }

    func testHistoryFilteringByPeriod() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let now = ISO8601DateFormatter().date(from: "2026-04-18T12:00:00Z")!
        let sameDay = EntryData(name: "Coffee", amount: 5, category: "Coffee", timestamp: now, computedMinutes: 10, decision: .bought)
        let thisWeek = EntryData(name: "Lunch", amount: 15, category: "Dining", timestamp: ISO8601DateFormatter().date(from: "2026-04-16T12:00:00Z")!, computedMinutes: 30, decision: .skipped)
        let thisMonth = EntryData(name: "Book", amount: 25, category: "Education", timestamp: ISO8601DateFormatter().date(from: "2026-04-02T12:00:00Z")!, computedMinutes: 50, decision: .bought)
        let thisYear = EntryData(name: "Headphones", amount: 100, category: "Tech", timestamp: ISO8601DateFormatter().date(from: "2026-01-08T12:00:00Z")!, computedMinutes: 200, decision: .watchlist)
        let lastYear = EntryData(name: "Trip", amount: 300, category: "Travel", timestamp: ISO8601DateFormatter().date(from: "2025-12-31T12:00:00Z")!, computedMinutes: 600, decision: .bought)

        let entries = [sameDay, thisWeek, thisMonth, thisYear, lastYear]
        XCTAssertEqual(HistoryFilter.filtered(entries, period: .daily, now: now, calendar: calendar).count, 1)
        XCTAssertEqual(HistoryFilter.filtered(entries, period: .weekly, now: now, calendar: calendar).count, 2)
        XCTAssertEqual(HistoryFilter.filtered(entries, period: .monthly, now: now, calendar: calendar).count, 3)
        XCTAssertEqual(HistoryFilter.filtered(entries, period: .yearly, now: now, calendar: calendar).count, 4)
    }

    func testStatsAggregation() {
        let entries: [EntryData] = [
            .init(name: "A", amount: 10, category: "x", timestamp: .now, computedMinutes: 10, decision: .bought),
            .init(name: "B", amount: 20, category: "x", timestamp: .now, computedMinutes: 20, decision: .skipped),
            .init(name: "C", amount: 30, category: "x", timestamp: .now, computedMinutes: 30, decision: .bought)
        ]

        let stats = StatsAggregator.makeStats(entries: entries)
        XCTAssertEqual(stats.totalTracked, 3)
        XCTAssertEqual(stats.totalAmount, 60, accuracy: 0.0001)
        XCTAssertEqual(stats.boughtTotal, 40, accuracy: 0.0001)
        XCTAssertEqual(stats.skippedTotal, 20, accuracy: 0.0001)
        XCTAssertEqual(stats.boughtRatio, 2.0 / 3.0, accuracy: 0.0001)
    }

    func testExportJSONShapeStability() throws {
        let payload = ExportPayload(
            exportedAt: ISO8601DateFormatter().date(from: "2026-04-18T00:00:00Z")!,
            user: .init(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!, username: "benji"),
            settings: .init(incomeType: .hourly, incomeAmount: 30, hoursPerWeek: 40, realWageEnabled: true, monthlyFixedExpenses: 1000),
            categories: ["Coffee", "Tech"],
            entries: [
                .init(id: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!, name: "Latte", amount: 5.5, category: "Coffee", timestamp: ISO8601DateFormatter().date(from: "2026-04-17T10:00:00Z")!, computedMinutes: 15, decision: .bought, notes: "")
            ]
        )

        let jsonData = try ExportJSONBuilder.data(from: payload)
        let json = String(decoding: jsonData, as: UTF8.self)

        XCTAssertTrue(json.contains("\"exportedAt\""))
        XCTAssertTrue(json.contains("\"user\""))
        XCTAssertTrue(json.contains("\"settings\""))
        XCTAssertTrue(json.contains("\"categories\""))
        XCTAssertTrue(json.contains("\"entries\""))
        XCTAssertTrue(json.contains("\"decision\" : \"bought\""))
    }
}
