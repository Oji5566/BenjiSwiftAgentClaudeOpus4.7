import SwiftData

enum BenjiModelContainer {
    static func make() -> ModelContainer {
        let schema = Schema([
            UserAccount.self,
            AppSettings.self,
            Category.self,
            Entry.self
        ])

        let config = ModelConfiguration("BenjiData")
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }
}
