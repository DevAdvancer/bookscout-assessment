import AppCore
import BookDomain
import SwiftUI

public struct BooksListView: View {
    @State private var viewModel: BooksViewModel

    public init(viewModel: BooksViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Finding books")
                } else if let error = viewModel.error, viewModel.books.isEmpty {
                    ContentUnavailableView(error.title, systemImage: "wifi.exclamationmark", description: Text(error.message))
                        .overlay(alignment: .bottom) {
                            Button("Try Again", action: viewModel.retry)
                                .buttonStyle(.borderedProminent)
                        }
                } else {
                    List {
                        if let cacheNotice = viewModel.cacheNotice {
                            Text(cacheNotice)
                                .foregroundStyle(.secondary)
                        }
                        ForEach(viewModel.books) { book in
                            BookListLink(
                                book: book,
                                isFavorite: viewModel.isFavorite(book.id),
                                onAppear: { viewModel.loadMoreIfNeeded(current: book) }
                            )
                        }
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("BookScout")
            .searchable(
                text: Binding<String>(
                    get: { viewModel.query },
                    set: { newValue in viewModel.updateSearch(newValue) }
                ),
                prompt: "Search title, author, subject"
            )
            .safeAreaInset(edge: .top) {
                SubjectFilterBar(
                    subjects: viewModel.subjects,
                    selectedSubject: viewModel.selectedSubject,
                    onSelect: { subject in viewModel.setSubject(subject) }
                )
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    FavoriteToolbarIcon()
                }
                #else
                ToolbarItem {
                    FavoriteToolbarIcon()
                }
                #endif
            }
            .navigationDestination(for: Book.self) { selectedBook in
                BookDetailView(book: selectedBook, isFavorite: viewModel.isFavorite(selectedBook.id)) {
                    viewModel.toggleFavorite(selectedBook.id)
                }
            }
            .alert(
                viewModel.error?.title ?? "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.error != nil && !viewModel.books.isEmpty },
                    set: { isPresented in
                        if !isPresented { viewModel.dismissError() }
                    }
                )
            ) {
                Button("OK", role: .cancel) { viewModel.dismissError() }
            } message: {
                Text(viewModel.error?.message ?? "")
            }
        }
        .task { viewModel.bootstrap() }
    }
}

private struct FavoriteToolbarIcon: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundStyle(.red)
            .accessibilityLabel("Favorites are saved locally")
    }
}

private struct BookListLink: View {
    let book: Book
    let isFavorite: Bool
    let onAppear: () -> Void

    var body: some View {
        NavigationLink(value: book) {
            BookRow(book: book, isFavorite: isFavorite)
        }
        .onAppear(perform: onAppear)
    }
}

private struct SubjectFilterBar: View {
    let subjects: [String]
    let selectedSubject: String?
    let onSelect: (String?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(subjects, id: \.self) { subject in
                    Button {
                        onSelect(subject)
                    } label: {
                        Label(subject, systemImage: selectedSubject == subject ? "checkmark.circle.fill" : "circle")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }
}

private struct BookRow: View {
    let book: Book
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: 12) {
            CoverImage(url: book.coverURL)
                .frame(width: 54, height: 78)
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(book.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(metadata)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 6)
    }

    private var metadata: String {
        let year = book.firstPublishYear.map(String.init) ?? "Year unknown"
        return "\(year) · \(book.editionCount) editions"
    }
}

private struct CoverImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondary.opacity(0.12))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
