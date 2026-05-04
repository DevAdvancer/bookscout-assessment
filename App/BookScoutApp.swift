import BookData
import BookDomain
import BookFeature
import SwiftUI

@main
struct BookScoutApp: App {
    var body: some Scene {
        WindowGroup {
            BooksListView(
                viewModel: BooksViewModel(
                    searchUseCase: SearchBooksUseCase(repository: LiveBookRepository()),
                    favoritesUseCase: FavoritesUseCase(store: UserDefaultsFavoritesStore())
                )
            )
        }
    }
}
