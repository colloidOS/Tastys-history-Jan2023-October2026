//
//  SupabaseAPIClient.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 03/01/2025.
//

import Foundation
import Supabase

struct SupabaseAPIClient: APIClient {
    func fetchRestaurants() async throws -> [Restaurant] {
        try await supabase
            .from("restaurants")
            .select("*, dishes(*)")
            .order("rating", ascending: false)
            .execute()
            .value
    }

    func fetchFeed(page: Int) async throws -> [FeedPost] {
        let pageSize = 20
        let from = page * pageSize
        return try await supabase
            .from("feed_posts")
            .select()
            .order("created_at", ascending: false)
            .range(from: from, to: from + pageSize - 1)
            .execute()
            .value
    }

    func fetchLeaderboard() async throws -> [LeaderboardEntry] {
        try await supabase
            .from("dish_leaderboard")
            .select()
            .limit(50)
            .execute()
            .value
    }
}
