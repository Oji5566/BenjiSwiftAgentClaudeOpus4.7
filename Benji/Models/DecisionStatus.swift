import Foundation

enum DecisionStatus: String, Codable, CaseIterable, Identifiable {
    case bought
    case skipped
    case watchlist
    case noTrack

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bought: "Buy"
        case .skipped: "Skip"
        case .watchlist: "Watchlist"
        case .noTrack: "No Track"
        }
    }
}
