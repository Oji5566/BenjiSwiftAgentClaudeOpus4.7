import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: UUID
    var userID: UUID
    var incomeTypeRaw: String
    var incomeAmount: Double
    var hoursPerWeek: Double
    var realWageEnabled: Bool
    var monthlyFixedExpenses: Double

    var incomeType: IncomeType {
        get { IncomeType(rawValue: incomeTypeRaw) ?? .hourly }
        set { incomeTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        userID: UUID,
        incomeType: IncomeType = .hourly,
        incomeAmount: Double = 10,
        hoursPerWeek: Double = 40,
        realWageEnabled: Bool = false,
        monthlyFixedExpenses: Double = 0
    ) {
        self.id = id
        self.userID = userID
        self.incomeTypeRaw = incomeType.rawValue
        self.incomeAmount = incomeAmount
        self.hoursPerWeek = hoursPerWeek
        self.realWageEnabled = realWageEnabled
        self.monthlyFixedExpenses = monthlyFixedExpenses
    }
}
