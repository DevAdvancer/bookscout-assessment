import AppCore
import Foundation

public protocol URLSessioning: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessioning {}

struct OpenLibraryResponse: Decodable {
    let numFound: Int
    let docs: [OpenLibraryBookDTO]
}

struct OpenLibraryBookDTO: Decodable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let subject: [String]?
    let language: [String]?
    let ratingsAverage: Double?
    let editionCount: Int?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case subject
        case language
        case ratingsAverage = "ratings_average"
        case editionCount = "edition_count"
    }

    func toBook() -> Book {
        Book(
            id: key,
            title: title,
            authors: authorName ?? [],
            firstPublishYear: firstPublishYear,
            coverID: coverI,
            subjects: Array((subject ?? []).prefix(8)),
            languages: language ?? [],
            ratingsAverage: ratingsAverage,
            editionCount: editionCount ?? 0
        )
    }
}

public struct OpenLibraryClient: Sendable {
    private let session: any URLSessioning
    private let decoder: JSONDecoder

    public init(session: any URLSessioning = URLSession.shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func search(query: String, subject: String?, page: Int, pageSize: Int) async throws -> OpenLibraryResponse {
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        var items = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(pageSize)),
            URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year,cover_i,subject,language,ratings_average,edition_count")
        ]
        if let subject, !subject.isEmpty {
            items.append(URLQueryItem(name: "subject", value: subject))
        }
        components?.queryItems = items

        guard let url = components?.url else {
            throw AppError.unknown("Unable to build the Open Library request.")
        }

        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw AppError.server("Server returned HTTP \(http.statusCode).")
            }
            return try decoder.decode(OpenLibraryResponse.self, from: data)
        } catch let error as AppError {
            throw error
        } catch is DecodingError {
            throw AppError.decoding
        } catch {
            throw AppError.offline
        }
    }
}
