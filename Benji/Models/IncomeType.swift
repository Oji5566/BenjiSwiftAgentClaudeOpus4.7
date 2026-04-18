import Foundation

enum IncomeType: String, Codable, CaseIterable, Identifiable {
    case hourly
    case monthly
    case annual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hourly: "Hourly"
        case .monthly: "Monthly"
        case .annual: "Annual"
        }
    }

    var amountLabel: String {
        switch self {
        case .hourly: "Hourly rate"
        case .monthly: "Monthly income"
        case .annual: "Annual income"
        }
    }
}
