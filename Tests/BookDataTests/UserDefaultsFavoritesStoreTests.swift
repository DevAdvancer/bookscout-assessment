import BookData
import Testing
import Foundation

@Test
func favoritesArePersistedAndRemoved() async {
    let suite = UserDefaults(suiteName: "BookScoutTests.\(UUID().uuidString)")!
    let store = UserDefaultsFavoritesStore(defaults: suite)

    await store.setFavorite("/works/OL1W", isFavorite: true)
    #expect(await store.favorites() == ["/works/OL1W"])

    await store.setFavorite("/works/OL1W", isFavorite: false)
    #expect(await store.favorites().isEmpty)
}
