//
//  LeaderboardViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/01/2026.
//

import SwiftUI
import Supabase


// MARK: - Leaderboard Models

struct TopUser: Decodable, Identifiable {
    let userId: String
    let username: String
    let firstName: String
    let lastName: String
    let avatar: String?
    let dishRatingCount: Int
    let restaurantVisitedCount: Int
    let restaurants: [SimpleRestaurant]
    let communityScore: Double?
    let topDishes: [UserTopDish]?
    let followersCount: Int?
    let followingCount: Int?
    let otherHighRatedCount: Int?
    let isFollowing: Bool?
    
    var id: String { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
        case dishRatingCount = "dish_rating_count"
        case restaurantVisitedCount = "restaurant_visited_count"
        case restaurants
        case communityScore = "community_score"
        case topDishes = "top_dishes"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case otherHighRatedCount = "other_high_rated_count"
        case isFollowing = "is_following"
    }
}

struct UserTopDish: Codable {
    let dishId: String
    let dishName: String
    let dishImage: String?
    let restaurantName: String?
    let rating: Int
    
    enum CodingKeys: String, CodingKey {
        case dishId = "dish_id"
        case dishName = "dish_name"
        case dishImage = "dish_image"
        case restaurantName = "restaurant_name"
        case rating
    }
}

struct SimpleRestaurant: Decodable {
    let restaurantId: String
    let restaurantName: String
    let restaurantImage: String?
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case restaurantImage = "restaurant_image"
    }
}

struct TopRestaurant: Decodable, Identifiable {
    let restaurantId: String
    let restaurantName: String
    let restaurantImage: String?
    let restaurantDescription: String?
    let restaurantAddress: String?
    let restaurantWebsite: String?
    let restaurantTelephone: String?
    let rating: Double
    let ratingCount: Int?
    let isBookmarked: Bool?
    let distanceKm: Double?
    let topDishes: [Dish]?
    
    
    var id: String { restaurantId }
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case restaurantImage = "restaurant_image"
        case restaurantDescription = "restaurant_description"
        case restaurantAddress = "restaurant_address"
        case restaurantWebsite = "restaurant_website"
        case restaurantTelephone = "restaurant_telephone"
        case rating
        case ratingCount = "rating_count"
        case isBookmarked = "is_bookmarked"
        case distanceKm = "distance_km"
        case topDishes = "top_dishes"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        restaurantId = try c.decode(String.self, forKey: .restaurantId)
        restaurantName = try c.decode(String.self, forKey: .restaurantName)
        restaurantImage = try c.decodeIfPresent(String.self, forKey: .restaurantImage)
        restaurantDescription = try c.decodeIfPresent(String.self, forKey: .restaurantDescription)
        restaurantAddress = try c.decodeIfPresent(String.self, forKey: .restaurantAddress)
        restaurantWebsite = try c.decodeIfPresent(String.self, forKey: .restaurantWebsite)
        restaurantTelephone = try c.decodeIfPresent(String.self, forKey: .restaurantTelephone)
        rating = try c.decode(Double.self, forKey: .rating)
        ratingCount = try c.decodeIfPresent(Int.self, forKey: .ratingCount)
        isBookmarked = try c.decodeIfPresent(Bool.self, forKey: .isBookmarked)
        distanceKm = try c.decodeIfPresent(Double.self, forKey: .distanceKm)
        // Tolerate a missing key, null, or any malformed dish inside the
        // array without failing the whole TopRestaurant decode.
        topDishes = (try? c.decodeIfPresent([Dish].self, forKey: .topDishes)) ?? []
    }
}

struct TopDish: Decodable, Identifiable {
    let dishId: String
    let dishName: String
    let dishDescription: String?
    let dishImage: String?
    let dishCategories: [String]?
    let restaurantId: String
    let restaurantName: String
    let rating: Double
    let ratingCount: Int?
    
    var id: String { dishId }
    
    enum CodingKeys: String, CodingKey {
        case dishId = "dish_id"
        case dishName = "dish_name"
        case dishDescription = "dish_description"
        case dishImage = "dish_image"
        case dishCategories = "dish_categories"
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case rating
        case ratingCount = "rating_count"
    }
}

struct TrendingUserDTO: Decodable {
    let id: String          // UUID
    let username: String
    let first_name: String?
    let last_name: String?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case first_name
        case last_name
        case avatar
    }
}

struct TrendingDish: Decodable, Identifiable {
    let dishId: String
    let dishName: String?
    let dishDescription: String?
    let dishImage: String?
    let dishCategories: [String]?
    let dishRating: Double?
    let restaurantId: String?
    let restaurantName: String?
    let ratingCount: Int?
    let ratedBy: [TrendingUserDTO]
    
    var id: String { dishId }
    
    enum CodingKeys: String, CodingKey {
        case dishId = "dish_id"
        case dishName = "dish_name"
        case dishDescription = "dish_description"
        case dishImage = "dish_image"
        case dishCategories = "dish_categories"
        case dishRating = "dish_rating"
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case ratingCount = "rating_count"
        case ratedBy = "rated_by"
    }
}

// MARK: - Leaderboard View Model

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    private var errorTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?
    
    @Published var topUsers: [TopUser] = []
    @Published var topRestaurants: [TopRestaurant] = []
    @Published var topDishes: [TopDish] = []
    @Published var trendingDishes: [TrendingDish] = []
    
    private struct RPCPaginationParams: Encodable {
        let p_limit: Int
        let p_offset: Int
        let p_user_id: UUID?
    }
    
    private func isCancellationError(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        if let urlError = error as? URLError,
           urlError.code == .cancelled {
            return true
        }

        return false
    }
    
    func showError(_ message: String) {
        errorTask?.cancel()
        errorMessage = message
        
        errorTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                withAnimation {
                    errorMessage = nil
                }
            }
        }
    }
    
    func showSuccess(_ message: String) {
        successTask?.cancel()
        successMessage = message
        
        successTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                withAnimation {
                    successMessage = nil
                }
            }
        }
    }
    
    func loadTopUsers(limit: Int = 20, offset: Int = 0) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let params = RPCPaginationParams(p_limit: limit, p_offset: offset, p_user_id: nil)
            topUsers = try await supabase.rpc("get_top_users", params: params).execute().value
            showSuccess("Top users loaded successfully")
            print(topUsers)
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to load top users")
            print("Failed to load top users: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func loadTopRestaurants(limit: Int = 20, offset: Int = 0) async {
        isLoading = true
        errorMessage = nil
        print("started loading top restaurants")
        print(supabase.auth.currentUser!.id)
        do {
            let params = RPCPaginationParams(p_limit: limit, p_offset: offset, p_user_id: supabase.auth.currentUser!.id)
            topRestaurants = try await supabase.rpc("get_top_restaurants", params: params).execute().value
            print("top restaurants: \(topRestaurants)")
            showSuccess("Top restaurants loaded successfully")
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to load top restaurants")
            print("Failed to load top restaurants: \(error.localizedDescription)")
        }
        
        isLoading = false
        print("stopped loading top restaurants")
    }
    
    func loadTopDishes(limit: Int = 20, offset: Int = 0) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let params = RPCPaginationParams(p_limit: limit, p_offset: offset, p_user_id: nil)
            topDishes = try await supabase.rpc("get_dish_leaderboard", params: params).execute().value
            showSuccess("Top dishes loaded successfully")
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to load top dishes")
            print("Failed to load top dishes: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func loadTrendingDishes(limit: Int = 20, offset: Int = 0) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let params = RPCPaginationParams(p_limit: limit, p_offset: offset, p_user_id: nil)
            trendingDishes = try await supabase.rpc("get_trending_dishes", params: params).execute().value
            showSuccess("Trending dishes loaded successfully")
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to load trending dishes")
            print("Failed to load trending dishes: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func loadFor(option: String) async {
        isLoading = true
        switch option {
        case "Foodies":
            if topUsers.isEmpty || isLoading { await loadTopUsers() }
        case "Restaurants":
            if topRestaurants.isEmpty || isLoading { await loadTopRestaurants() }
        case "Top":
            if topDishes.isEmpty || isLoading { await loadTopDishes() }
        case "Trending":
            if trendingDishes.isEmpty || isLoading { await loadTrendingDishes() }
        case "Dishes":
            if topDishes.isEmpty || isLoading { await loadTopDishes() }
            if trendingDishes.isEmpty || isLoading { await loadTrendingDishes() }
        default:
            break
        }
    }
}
