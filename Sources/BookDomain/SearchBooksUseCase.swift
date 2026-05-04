import AppCore
import Foundation

public struct SearchBooksUseCase: Sendable {
    private let repository: any BookRepository

    public init(repository: any BookRepository) {
        self.repository = repository
    }

    public func execute(query: String, subject: String?, page: Int, pageSize: Int = 20) async throws -> BookPage {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await repository.search(
            query: cleanedQuery.isEmpty ? "swift programming" : cleanedQuery,
            subject: subject,
            page: page,
            pageSize: pageSize
        )
    }
}

public actor FavoritesUseCase {
    private let store: any FavoritesStore

    public init(store: any FavoritesStore) {
        self.store = store
    }

    public func favorites() async -> Set<String> {
        await store.favorites()
    }

    public func toggle(_ id: String) async -> Set<String> {
        var current = await store.favorites()
        let nextValue = !current.contains(id)
        await store.setFavorite(id, isFavorite: nextValue)
        if nextValue {
            current.insert(id)
        } else {
            current.remove(id)
        }
        return current
    }
}
