//
//  FavoritesStore.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 20/09/2023.
//

import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var ids: Set<UUID>

    private let defaults: UserDefaults
    private let key = "favoriteRestaurantIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let ids = defaults.stringArray(forKey: key) ?? []
        self.ids = Set(ids.compactMap(UUID.init(uuidString:)))
    }

    func contains(_ restaurant: Restaurant) -> Bool {
        ids.contains(restaurant.id)
    }

    func toggle(_ restaurant: Restaurant) {
        if ids.contains(restaurant.id) {
            ids.remove(restaurant.id)
        } else {
            ids.insert(restaurant.id)
        }
        defaults.set(ids.map(\.uuidString), forKey: key)
    }
}
