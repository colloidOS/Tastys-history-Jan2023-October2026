//
//  PlateStore.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 10/04/2024.
//

import Foundation

struct PlateItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var dishName: String
    var restaurantName: String
    var imageName: String
    var addedAt = Date()
}

@MainActor
final class PlateStore: ObservableObject {
    @Published private(set) var items: [PlateItem] = [] {
        didSet { save() }
    }

    private let url = URL.documentsDirectory.appending(path: "plate.json")

    init() {
        if let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([PlateItem].self, from: data) {
            self.items = items
        }
    }

    func add(_ dish: Dish, from restaurant: Restaurant) {
        guard !items.contains(where: { $0.dishName == dish.name && $0.restaurantName == restaurant.name }) else { return }
        items.insert(PlateItem(dishName: dish.name, restaurantName: restaurant.name, imageName: dish.imageName), at: 0)
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func save() {
        try? JSONEncoder().encode(items).write(to: url, options: .atomic)
    }
}
