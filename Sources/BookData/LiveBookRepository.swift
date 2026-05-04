import AppCore
import BookDomain
import Foundation

public struct LiveBookRepository: BookRepository {
    private let client: OpenLibraryClient
    private let cache: BookCache

    public init(client: OpenLibraryClient = OpenLibraryClient()) {
        self.client = client
        self.cache = BookCache()
    }

    public func search(query: String, subject: String?, page: Int, pageSize: Int) async throws -> BookPage {
        do {
            let response = try await client.search(query: query, subject: subject, page: page, pageSize: pageSize)
            let books = response.docs.map { $0.toBook() }
            if page == 1 {
                await cache.save(books)
            }
            guard !books.isEmpty else { throw AppError.empty }
            return BookPage(
                books: books,
                page: page,
                hasMore: response.numFound > page * pageSize
            )
        } catch AppError.offline where page == 1 {
            let cached = await cache.load()
            guard !cached.isEmpty else { throw AppError.offline }
            return BookPage(books: cached, page: page, hasMore: false, isCacheFallback: true)
        }
    }
}
