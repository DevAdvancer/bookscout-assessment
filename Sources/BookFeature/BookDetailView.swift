import AppCore
import SwiftUI

public struct BookDetailView: View {
    let book: Book
    let isFavorite: Bool
    let onFavorite: () -> Void

    public init(book: Book, isFavorite: Bool, onFavorite: @escaping () -> Void) {
        self.book = book
        self.isFavorite = isFavorite
        self.onFavorite = onFavorite
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 18) {
                    AsyncImage(url: book.coverURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "book.closed.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.secondary.opacity(0.12))
                    }
                    .frame(width: 130, height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text(book.title)
                            .font(.title2.bold())
                        Text(book.subtitle)
                            .foregroundStyle(.secondary)
                        Button(action: onFavorite) {
                            Label(isFavorite ? "Saved" : "Save", systemImage: isFavorite ? "heart.fill" : "heart")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                LabeledContent("First published", value: book.firstPublishYear.map(String.init) ?? "Unknown")
                LabeledContent("Editions", value: String(book.editionCount))
                if let rating = book.ratingsAverage {
                    LabeledContent("Average rating", value: String(format: "%.1f", rating))
                }

                if !book.subjects.isEmpty {
                    Text("Subjects")
                        .font(.headline)
                    FlowLayout(items: book.subjects)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private struct FlowLayout: View {
    let items: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
