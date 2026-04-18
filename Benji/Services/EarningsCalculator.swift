import Foundation

enum EarningsCalculator {
    static let weeksPerMonth = 52.0 / 12.0

    static func earningPerMinute(settings: AppSettings) -> Double {
        guard settings.hoursPerWeek > 0 else { return 0 }

        let base: Double
        switch settings.incomeType {
        case .hourly:
            base = settings.incomeAmount / 60
        case .monthly:
            base = settings.incomeAmount / (settings.hoursPerWeek * weeksPerMonth) / 60
        case .annual:
            base = settings.incomeAmount / (settings.hoursPerWeek * 52) / 60
        }

        guard settings.realWageEnabled else { return max(base, 0) }
        let expensePerMinute = settings.monthlyFixedExpenses / (settings.hoursPerWeek * weeksPerMonth) / 60
        return max(base - expensePerMinute, 0)
    }

    static func minutes(for amount: Double, settings: AppSettings) -> Double {
        let rate = earningPerMinute(settings: settings)
        guard rate > 0, amount > 0 else { return 0 }
        return amount / rate
    }

    static func timeString(minutes: Double) -> String {
        if minutes <= 0 { return "0m" }
        if minutes < 1 { return "\(Int((minutes * 60).rounded()))s" }
        if minutes < 60 { return "\(Int(minutes.rounded()))m" }

        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60).rounded())
        return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
    }
}
