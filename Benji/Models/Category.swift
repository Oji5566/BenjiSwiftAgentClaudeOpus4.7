import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var userID: UUID
    var name: String
    var sfSymbol: String
    var sortOrder: Int

    init(id: UUID = UUID(), userID: UUID, name: String, sfSymbol: String, sortOrder: Int) {
        self.id = id
        self.userID = userID
        self.name = name
        self.sfSymbol = sfSymbol
        self.sortOrder = sortOrder
    }
}
