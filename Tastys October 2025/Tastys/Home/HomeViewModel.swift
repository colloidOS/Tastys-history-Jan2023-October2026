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
    @Published private(set) var feed: [FeedPost] = []
    @Published private(set) var isLoadingMore = false
    private var page = 0
    private var reachedEnd = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var myRatings: [String: Reaction] = [:]

    private let client: APIClient

    init(client: APIClient = SupabaseAPIClient()) {
        self.client = client
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            restaurants = try await client.fetchRestaurants()
            page = 0
            reachedEnd = false
            feed = try await client.fetchFeed(page: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreIfNeeded(current post: FeedPost) async {
        guard post.id == feed.last?.id, !isLoadingMore, !reachedEnd else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        let next = (try? await client.fetchFeed(page: page + 1)) ?? []
        if next.isEmpty { reachedEnd = true } else { page += 1; feed += next }
    }

    func rate(_ dish: Dish, reaction: Reaction) {
        myRatings[dish.id] = reaction
    }

    func toggleLike(_ post: FeedPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[index].isLiked.toggle()
        feed[index].likes += feed[index].isLiked ? 1 : -1
    }
}
