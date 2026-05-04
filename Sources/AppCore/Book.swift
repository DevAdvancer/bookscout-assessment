import Foundation

public struct Book: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let authors: [String]
    public let firstPublishYear: Int?
    public let coverID: Int?
    public let subjects: [String]
    public let languages: [String]
    public let ratingsAverage: Double?
    public let editionCount: Int

    public init(
        id: String,
        title: String,
        authors: [String],
        firstPublishYear: Int?,
        coverID: Int?,
        subjects: [String],
        languages: [String],
        ratingsAverage: Double?,
        editionCount: Int
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.firstPublishYear = firstPublishYear
        self.coverID = coverID
        self.subjects = subjects
        self.languages = languages
        self.ratingsAverage = ratingsAverage
        self.editionCount = editionCount
    }

    public var subtitle: String {
        authors.isEmpty ? "Unknown author" : authors.joined(separator: ", ")
    }

    public var coverURL: URL? {
        guard let coverID else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")
    }
}
