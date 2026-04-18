import Foundation

struct ExportService {
    struct Payload: Encodable {
        struct User: Encodable {
            var id: UUID
            var username: String
        }

        struct Settings: Encodable {
            var incomeType: String
            var incomeAmount: Double
            var hoursPerWeek: Double
            var realWageEnabled: Bool
            var monthlyFixedExpenses: Double
        }

        struct EntryData: Encodable {
            var id: UUID
            var name: String
            var amount: Double
            var category: String
            var timestamp: Date
            var computedMinutes: Double
            var decision: String
            var notes: String
        }

        var exportedAt: Date
        var user: User
        var settings: Settings
        var categories: [String]
        var entries: [EntryData]
    }

    func exportJSON(user: UserAccount, settings: AppSettings, categories: [Category], entries: [Entry]) throws -> URL {
        let payload = Payload(
            exportedAt: .now,
            user: .init(id: user.id, username: user.username),
            settings: .init(
                incomeType: settings.incomeType.rawValue,
                incomeAmount: settings.incomeAmount,
                hoursPerWeek: settings.hoursPerWeek,
                realWageEnabled: settings.realWageEnabled,
                monthlyFixedExpenses: settings.monthlyFixedExpenses
            ),
            categories: categories.sorted(by: { $0.sortOrder < $1.sortOrder }).map(\.name),
            entries: entries.map {
                .init(
                    id: $0.id,
                    name: $0.name,
                    amount: $0.amount,
                    category: $0.categoryName,
                    timestamp: $0.timestamp,
                    computedMinutes: $0.computedMinutes,
                    decision: $0.decision.rawValue,
                    notes: $0.notes
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)

        let filename = "benji-export-\(user.username)-\(Int(Date().timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }
}
