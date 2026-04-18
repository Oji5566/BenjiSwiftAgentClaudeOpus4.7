import CryptoKit
import Foundation
import SwiftData

struct AuthService {
    enum AuthError: LocalizedError {
        case usernameTooShort
        case passwordTooShort
        case usernameTaken
        case accountNotFound
        case invalidPassword

        var errorDescription: String? {
            switch self {
            case .usernameTooShort: "Username must be at least 3 characters."
            case .passwordTooShort: "Password must be at least 6 characters."
            case .usernameTaken: "Username is already taken."
            case .accountNotFound: "Account not found."
            case .invalidPassword: "Incorrect password."
            }
        }
    }

    func signUp(username: String, password: String, context: ModelContext) throws -> UserAccount {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else { throw AuthError.usernameTooShort }
        guard password.count >= 6 else { throw AuthError.passwordTooShort }

        let existing = try context.fetch(FetchDescriptor<UserAccount>(predicate: #Predicate { $0.username == trimmed }))
        guard existing.isEmpty else { throw AuthError.usernameTaken }

        let salt = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let hash = hash(password: password, salt: salt)

        let user = UserAccount(username: trimmed, passwordHash: hash, salt: salt)
        context.insert(user)
        context.insert(AppSettings(userID: user.id))
        defaultCategories(for: user.id).forEach(context.insert)
        try context.save()
        return user
    }

    func login(username: String, password: String, context: ModelContext) throws -> UserAccount {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let user = try context.fetch(FetchDescriptor<UserAccount>(predicate: #Predicate { $0.username == trimmed })).first else {
            throw AuthError.accountNotFound
        }

        let computed = hash(password: password, salt: user.salt)
        guard computed == user.passwordHash else { throw AuthError.invalidPassword }
        return user
    }

    private func hash(password: String, salt: String) -> String {
        let digest = SHA256.hash(data: Data((salt + password).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func defaultCategories(for userID: UUID) -> [Category] {
        [
            ("Coffee", "cup.and.saucer.fill"),
            ("Dining", "fork.knife"),
            ("Shopping", "bag.fill"),
            ("Transport", "car.fill"),
            ("Tech", "desktopcomputer"),
            ("Health", "cross.case.fill"),
            ("Other", "questionmark.circle.fill")
        ].enumerated().map { index, item in
            Category(userID: userID, name: item.0, sfSymbol: item.1, sortOrder: index)
        }
    }
}
