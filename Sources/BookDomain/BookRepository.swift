import AppCore
import Foundation

public struct BookPage: Equatable, Sendable {
    public let books: [Book]
    public let page: Int
    public let hasMore: Bool
    public let isCacheFallback: Bool

    public init(books: [Book], page: Int, hasMore: Bool, isCacheFallback: Bool = false) {
        self.books = books
        self.page = page
        self.hasMore = hasMore
        self.isCacheFallback = isCacheFallback
    }
}

public protocol BookRepository: Sendable {
    func search(query: String, subject: String?, page: Int, pageSize: Int) async throws -> BookPage
}

public protocol FavoritesStore: Sendable {
    func favorites() async -> Set<String>
    func setFavorite(_ id: String, isFavorite: Bool) async
}
