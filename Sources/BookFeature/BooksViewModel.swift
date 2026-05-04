import AppCore
import BookDomain
import Foundation
import Observation

@MainActor
@Observable
public final class BooksViewModel {
    public private(set) var books: [Book] = []
    public private(set) var favoriteIDs: Set<String> = []
    public private(set) var error: AppError?
    public private(set) var isLoading = false
    public private(set) var isLoadingMore = false
    public private(set) var cacheNotice: String?
    public var query = "design"
    public var selectedSubject: String?

    public let subjects = ["Fiction", "Science", "Design", "History", "Technology"]
    private let searchUseCase: SearchBooksUseCase
    private let favoritesUseCase: FavoritesUseCase
    private var page = 1
    private var hasMore = true
    private var searchTask: Task<Void, Never>?

    public init(searchUseCase: SearchBooksUseCase, favoritesUseCase: FavoritesUseCase) {
        self.searchUseCase = searchUseCase
        self.favoritesUseCase = favoritesUseCase
    }

    public func bootstrap() {
        Task {
            favoriteIDs = await favoritesUseCase.favorites()
            await search(reset: true)
        }
    }

    public func updateSearch(_ value: String) {
        query = value
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await search(reset: true)
        }
    }

    public func setSubject(_ subject: String?) {
        selectedSubject = selectedSubject == subject ? nil : subject
        Task { await search(reset: true) }
    }

    public func loadMoreIfNeeded(current book: Book) {
        guard hasMore, book.id == books.last?.id, !isLoadingMore else { return }
        Task { await search(reset: false) }
    }

    public func retry() {
        Task { await search(reset: true) }
    }

    public func dismissError() {
        error = nil
    }

    public func toggleFavorite(_ id: String) {
        Task {
            favoriteIDs = await favoritesUseCase.toggle(id)
        }
    }

    public func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    private func search(reset: Bool) async {
        if reset {
            page = 1
            hasMore = true
            books = []
            isLoading = true
        } else {
            isLoadingMore = true
        }
        error = nil
        cacheNotice = nil

        do {
            let result = try await searchUseCase.execute(query: query, subject: selectedSubject, page: page)
            if reset {
                books = result.books
            } else {
                books.append(contentsOf: result.books)
            }
            page += 1
            hasMore = result.hasMore
            cacheNotice = result.isCacheFallback ? "Showing cached results while offline." : nil
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoading = false
        isLoadingMore = false
    }
}
