import Foundation
import SwiftData

@Model
final class UserAccount {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var username: String
    var passwordHash: String
    var salt: String
    var createdAt: Date
    var onboardingComplete: Bool

    init(id: UUID = UUID(), username: String, passwordHash: String, salt: String, createdAt: Date = .now, onboardingComplete: Bool = false) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.salt = salt
        self.createdAt = createdAt
        self.onboardingComplete = onboardingComplete
    }
}
