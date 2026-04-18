import SwiftUI

struct OnboardingView: View {
    @Bindable var appState: AppState

    @State private var incomeType: IncomeType = .hourly
    @State private var incomeAmount: Double = 0
    @State private var hoursPerWeek: Double = 40
    @State private var realWageEnabled = false
    @State private var monthlyFixedExpenses: Double = 0

    var previewRate: Double {
        let temp = AppSettings(
            userID: appState.currentUser?.id ?? UUID(),
            incomeType: incomeType,
            incomeAmount: incomeAmount,
            hoursPerWeek: hoursPerWeek,
            realWageEnabled: realWageEnabled,
            monthlyFixedExpenses: monthlyFixedExpenses
        )
        return EarningsCalculator.earningPerMinute(settings: temp)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Income") {
                    Picker("Income type", selection: $incomeType) {
                        ForEach(IncomeType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    TextField(incomeType.amountLabel, value: $incomeAmount, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Hours per week", value: $hoursPerWeek, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Real wage") {
                    Toggle("Enable real wage mode", isOn: $realWageEnabled)
                    if realWageEnabled {
                        TextField("Monthly fixed expenses", value: $monthlyFixedExpenses, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Preview") {
                    LabeledContent("Earning per minute") {
                        Text(BenjiFormatters.money(previewRate))
                            .fontWeight(.semibold)
                    }
                }

                Button("Get Started") {
                    guard incomeAmount > 0, hoursPerWeek > 0 else {
                        appState.alertMessage = "Income and hours must be greater than zero."
                        return
                    }
                    appState.completeOnboarding(
                        incomeType: incomeType,
                        incomeAmount: incomeAmount,
                        hoursPerWeek: hoursPerWeek,
                        realWageEnabled: realWageEnabled,
                        monthlyFixedExpenses: monthlyFixedExpenses
                    )
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Welcome")
            .onAppear {
                guard let settings = appState.settings else { return }
                incomeType = settings.incomeType
                incomeAmount = settings.incomeAmount
                hoursPerWeek = settings.hoursPerWeek
                realWageEnabled = settings.realWageEnabled
                monthlyFixedExpenses = settings.monthlyFixedExpenses
            }
        }
    }
}
