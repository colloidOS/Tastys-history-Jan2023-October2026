//
//  UserProfileService.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/01/2026.
//

import Foundation
import Supabase

enum APIError: Error {
    case rpcError(String)
    case decodingError(Error)
    case unknown
}

// MARK: - Inputs

//struct DishRatingInput: Codable {
//    let dish_id: String
//    let rating: Int
//}

// MARK: - RPC Params (Encodable structs)
//
// Use these to avoid Swift inferring [String: Any] / [String: String] and the related errors.

private struct CreateRatingPostParams: Encodable {
    let p_user_id: String
    let p_dish_ratings: String
    let p_images: [String]
    let p_comment: String
    let p_restaurant_id: String
}

private struct TogglePostReactionParams: Encodable {
    let post_id: String
    let user_id: String
    let is_like: Bool
}

 struct GetPostsParams: Encodable {
    let p_limit: Int
    let p_offset: Int
    let p_current_user_id: String?
}

struct GetUserPostsParams: Encodable {
   let p_limit: Int
   let p_offset: Int
   let p_current_user_id: String?
    let p_user_id: String?
}

//private struct GetPostCommentsParams: Encodable {
//    let post_id: String
//    let user_id: String?
//    let limit: Int
//    let order: String
//}

// MARK: - Service

final class UserProfileService {

    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    // MARK: - Users

    func getUserById(_ userId: String) async throws -> UserProfile {
        try await supabase
            .rpc(
                "get_user_by_id",
                params: ["p_user_id": userId]
            )
            .single()
            .execute()
            .value
    }

    func getUserByUsername(_ username: String) async throws -> UserProfile {
        try await supabase
            .rpc(
                "get_user_by_username",
                params: ["p_username": username]
            )
            .single()
            .execute()
            .value
    }

    func followUser(userId: String, otherUserId: String) async throws {
        _ = try await supabase
            .rpc(
                "follow_user",
                params: [/*"p_follower_id": userId, */"p_following_id": otherUserId]
            )
            .execute()
    }

    func unfollowUser(userId: String, otherUserId: String) async throws {
        _ = try await supabase
            .rpc(
                "unfollow_user",
                params: ["p_follower_id": userId, "p_following_id": otherUserId]
            )
            .execute()
    }

    // MARK: - Plates

    func createUserPlate(
        userId: String,
        plateName: String
    ) async throws -> UserPlate {

        try await supabase
            .rpc(
                "create_user_plate",
                params: ["p_user_id": userId, "p_plate_name": plateName]
            )
            .single()
            .execute()
            .value
    }

    func addDishToPlate(
        dishId: String,
        userPlateId: String
    ) async throws {

        _ = try await supabase
            .rpc(
                "add_dish_to_plate",
                params: ["dish_id": dishId, "user_plate_id": userPlateId]
            )
            .execute()
    }

    

    func getUserPlatesWithDishes(userId: String) async throws -> [Plate] {
        try await supabase
            .rpc(
                "get_user_plates_with_dishes",
                params: ["p_user_id": userId]
            )
            .execute()
            .value
    }

    // MARK: - Restaurants / Dishes

    func getRestaurantWithDishes(
        restaurantId: String
    ) async throws -> RestaurantDetails {

        try await supabase
            .rpc(
                "get_restaurant_with_dishes",
                params: ["restaurant_id": restaurantId]
            )
            .single()
            .execute()
            .value
    }

    // MARK: - Rating Posts

    func createRatingPost(
        userId: String,
        dishRatings: [DishRatingInput],
        images: [String],
        comment: String?,
        restaurantId: String
    ) async throws -> String {

        // encode dishRatings as a JSON string (RPC expects JSON string)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(dishRatings)
        guard let dishRatingsJSON = String(data: data, encoding: .utf8) else {
            throw APIError.unknown
        }

        let params = CreateRatingPostParams(
            p_user_id: userId,
            p_dish_ratings: dishRatingsJSON,
            p_images: images,
            p_comment: comment ?? "",
            p_restaurant_id: restaurantId
        )

        let response: CreateRatingPostResponse = try await supabase
            .rpc(
                "create_rating_post_json",
                params: params
            )
            .single()
            .execute()
            .value

        return response.id
    }

    private struct CreateRatingPostResponse: Codable {
        let id: String
    }

    func togglePostReaction(
        postId: String,
        userId: String,
        isLike: Bool
    ) async throws {

        let params = TogglePostReactionParams(
            post_id: postId,
            user_id: userId,
            is_like: isLike
        )

        _ = try await supabase
            .rpc(
                "toggle_post_reaction",
                params: params
            )
            .execute()
    }

    func incrementPostShare(postId: String) async throws {
        _ = try await supabase
            .rpc(
                "increment_post_share",
                params: ["post_id": postId]
            )
            .execute()
    }

    func addPostComment(
        postId: String,
        userId: String,
        content: String
    ) async throws {

        _ = try await supabase
            .rpc(
                "add_post_comment",
                params: ["post_id": postId, "user_id": userId, "content": content]
            )
            .execute()
    }

    // MARK: - Feed / Discovery

    func getTopDishesNearby(userId: String) async throws -> [Dish] {
        try await supabase
            .rpc(
                "get_top_dishes_nearby",
                params: ["p_user_id": userId]
            )
            .execute()
            .value
    }

    func getPosts(
        limit: Int = 20,
        offset: Int = 0,
        userId: String?
    ) async throws -> [RatingPost] {

        let params = GetPostsParams(p_limit: limit, p_offset: offset, p_current_user_id: userId)

        return try await supabase
            .rpc("get_posts", params: params)
            .execute()
            .value
    }

    func getPostById(postId: String) async throws -> RatingPost {
        try await supabase
            .rpc(
                "get_post_by_id",
                params: ["post_id": postId]
            )
            .single()
            .execute()
            .value
    }
    
    func getUserPosts(
        limit: Int = 20,
        offset: Int = 0,
        userId: String?,
        currentUserId: String
        
    ) async throws -> [RatingPost] {

        let params = GetUserPostsParams(p_limit: limit, p_offset: offset, p_current_user_id: currentUserId, p_user_id: userId)

        return try await supabase
            .rpc("get_posts_by_user", params: params)
            .execute()
            .value
    }

//    func getPostComments(
//        postId: String,
//        userId: String?,
//        limit: Int = 50,
//        order: String = "newest"
//    ) async throws -> [RatingPostComment] {
//
//        let params = GetPostCommentsParams(
//            post_id: postId,
//            user_id: userId,
//            limit: limit,
//            order: order
//        )
//
//        return try await supabase
//            .rpc("get_post_comments", params: params)
//            .execute()
//            .value
//    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let response: Bool = try await supabase
            .rpc(
                "check_username_availability",
                params: ["target_username": username.lowercased()]
            )
            .execute()
            .value
        return response
    }
    
    func updateUsername(userId: String, username: String) async throws -> UserProfile {
        let response = try await supabase
            .rpc(
                "update_user_profile",
                params: ["p_user_id": userId, "p_username": username.lowercased()]
            )
            .execute()

        // Decode directly
        let updatedProfile = try JSONDecoder.supabase.decode(UserProfile.self, from: response.data)
        return updatedProfile
    }
}
