import AppCore
import Foundation

actor BookCache {
    private let url: URL

    init(filename: String = "book-cache.json") {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.url = base.appendingPathComponent("BookScout", isDirectory: true).appendingPathComponent(filename)
    }

    func load() -> [Book] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([Book].self, from: data)) ?? []
    }

    func save(_ books: [Book]) {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(books)
            try data.write(to: url, options: [.atomic])
        } catch {
            // Cache failures should never block the user from viewing fresh data.
        }
    }
}
