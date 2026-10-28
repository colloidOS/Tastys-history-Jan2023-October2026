//
//  HomeViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/02/2024.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var restaurants: [Restaurant] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var myRatings: [UUID: Reaction] = [:]

    private let client: APIClient

    init(client: APIClient = MockAPIClient()) {
        self.client = client
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            restaurants = try await client.fetchRestaurants()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rate(_ dish: Dish, reaction: Reaction) {
        myRatings[dish.id] = reaction
    }
}
