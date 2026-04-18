import Foundation
import SwiftData

@Model
final class Entry {
    @Attribute(.unique) var id: UUID
    var userID: UUID
    var name: String
    var amount: Double
    var categoryName: String
    var categorySymbol: String
    var timestamp: Date
    var computedMinutes: Double
    var decisionRaw: String
    var notes: String

    var decision: DecisionStatus {
        get { DecisionStatus(rawValue: decisionRaw) ?? .noTrack }
        set { decisionRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        userID: UUID,
        name: String,
        amount: Double,
        categoryName: String,
        categorySymbol: String,
        timestamp: Date = .now,
        computedMinutes: Double,
        decision: DecisionStatus,
        notes: String = ""
    ) {
        self.id = id
        self.userID = userID
        self.name = name
        self.amount = amount
        self.categoryName = categoryName
        self.categorySymbol = categorySymbol
        self.timestamp = timestamp
        self.computedMinutes = computedMinutes
        self.decisionRaw = decision.rawValue
        self.notes = notes
    }
}
