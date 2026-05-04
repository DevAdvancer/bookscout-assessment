import AppCore
import BookDomain
import Testing

private struct StubRepository: BookRepository {
    let handler: @Sendable (String, String?, Int, Int) async throws -> BookPage

    func search(query: String, subject: String?, page: Int, pageSize: Int) async throws -> BookPage {
        try await handler(query, subject, page, pageSize)
    }
}

@Test
func emptySearchFallsBackToDefaultQuery() async throws {
    let repository = StubRepository { query, subject, page, pageSize in
        #expect(query == "swift programming")
        #expect(subject == "Design")
        #expect(page == 1)
        #expect(pageSize == 20)
        return BookPage(books: [], page: page, hasMore: false)
    }

    _ = try await SearchBooksUseCase(repository: repository).execute(query: "  ", subject: "Design", page: 1)
}
