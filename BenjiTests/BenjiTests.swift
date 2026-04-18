import XCTest
@testable import Benji

final class BenjiTests: XCTestCase {
    func testEarningMath() {
        let settings = AppSettings(userID: UUID(), incomeType: .hourly, incomeAmount: 60, hoursPerWeek: 40, realWageEnabled: false, monthlyFixedExpenses: 0)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: settings), 1, accuracy: 0.0001)
    }

    func testRealWageMath() {
        let settings = AppSettings(userID: UUID(), incomeType: .monthly, incomeAmount: 5000, hoursPerWeek: 40, realWageEnabled: true, monthlyFixedExpenses: 2000)
        XCTAssertEqual(EarningsCalculator.earningPerMinute(settings: settings), 0.2885, accuracy: 0.0002)
    }
}
