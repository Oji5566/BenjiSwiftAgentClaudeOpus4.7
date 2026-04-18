import Foundation

enum BenjiFormatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter
    }()

    static func money(_ value: Double) -> String {
        currency.string(from: value as NSNumber) ?? "$\(value)"
    }

    static func relative(_ date: Date) -> String {
        RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .now)
    }

    static func sectionDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
