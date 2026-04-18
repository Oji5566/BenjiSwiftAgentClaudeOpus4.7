import Foundation

struct SessionService {
    private let keychain = KeychainStore()
    private let sessionKey = "benji.current.user.id"

    func storeCurrentUserID(_ id: UUID) {
        keychain.set(Data(id.uuidString.utf8), for: sessionKey)
    }

    func currentUserID() -> UUID? {
        guard let data = keychain.get(sessionKey),
              let value = String(data: data, encoding: .utf8) else { return nil }
        return UUID(uuidString: value)
    }

    func clear() {
        keychain.remove(sessionKey)
    }
}
