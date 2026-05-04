import BookDomain
import Foundation

public actor UserDefaultsFavoritesStore: FavoritesStore {
    private let defaults: UserDefaults
    private let key = "bookscout.favorite.ids"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func favorites() async -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    public func setFavorite(_ id: String, isFavorite: Bool) async {
        var values = Set(defaults.stringArray(forKey: key) ?? [])
        if isFavorite {
            values.insert(id)
        } else {
            values.remove(id)
        }
        defaults.set(Array(values).sorted(), forKey: key)
    }
}
