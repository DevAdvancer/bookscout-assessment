import Foundation

public enum AppError: Error, Equatable, Sendable {
    case offline
    case server(String)
    case decoding
    case empty
    case unknown(String)

    public var title: String {
        switch self {
        case .offline: "You appear to be offline"
        case .server: "Open Library is unavailable"
        case .decoding: "The response could not be read"
        case .empty: "No books found"
        case .unknown: "Something went wrong"
        }
    }

    public var message: String {
        switch self {
        case .offline:
            "Check your connection and try again. Cached results may still be available."
        case .server(let detail), .unknown(let detail):
            detail
        case .decoding:
            "The app received data in an unexpected format."
        case .empty:
            "Try another title, author, or subject."
        }
    }
}
