//
//  ProfileModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/01/2026.
//

import Foundation

// Common ISO8601 decoder helper
extension JSONDecoder {
    static var supabase: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

// MARK: - Models

struct UserProfile: Codable, Identifiable {
    // Matches public.user_profile
    let idField: String?   // ← Optional
    public var id: String { idField ?? user_id }
    let user_id: String
    var username: String
    let email: String?
    let phone: String?
    let email_verified: Bool?
    let phone_verified: Bool?
    var first_name: String
    var last_name: String
    let address: String?
    var location: String?     // user-defined Postgres geography -> map as WKT/geojson string
    var tiktok: String?
    var instagram: String?
    var avatar: String?
    var bio: String?
    let created_at: Date?
    let followers_count: Int?
    let following_count: Int?
    let average_rating: Double?
    let community_score: Double?
    let food_profile: String?
    let totalDishesRated: Int?
    let totalRestaurantsVisited: Int?
    let topDishes: [UserTopDish]?
    let otherHighRatedCount: Int?
    let isFollowing: Bool?
    
    // the SQL had both user_id and id; keep both
//    let idField: String

    enum CodingKeys: String, CodingKey {
        case user_id, username, email, phone, email_verified, phone_verified, first_name, last_name, address, location, tiktok, instagram, avatar, bio, created_at
        case idField = "id"
        case followers_count              // ← matches the alias in SELECT
        case following_count
        case average_rating
        case community_score
        case food_profile
        case totalDishesRated = "total_dishes_rated"
        case totalRestaurantsVisited = "total_restaurants_visited"
        case topDishes = "top_dishes"
        case otherHighRatedCount = "other_high_rated_count"
        case isFollowing = "is_following"
    }
}


struct RatingPost: Codable, Identifiable {
    let id: UUID
    let post: PostDetails
    let user: UserDetails?
    let restaurant: RestaurantDetails?
    let dishes: [DishRatingDetails]?
    let engagement: EngagementDetails?
    let tags: [String]?
    
    // ←←← ADD THIS NEW INITIALIZER (right here)
        init(
            id: UUID,
            post: PostDetails,
            user: UserDetails?,
            restaurant: RestaurantDetails?,
            dishes: [DishRatingDetails]?,
            engagement: EngagementDetails?,
            tags: [String]?
        ) {
            self.id = id
            self.post = post
            self.user = user
            self.restaurant = restaurant
            self.dishes = dishes
            self.engagement = engagement
            self.tags = tags
        }
    
    enum CodingKeys: String, CodingKey {
        case post
        case user
        case restaurant
        case dishes
        case engagement
        case tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.post = try container.decode(PostDetails.self, forKey: .post)
        self.user = try container.decode(UserDetails.self, forKey: .user)
        self.restaurant = try container.decode(RestaurantDetails.self, forKey: .restaurant)
        self.dishes = try container.decode([DishRatingDetails].self, forKey: .dishes)
        self.engagement = try container.decode(EngagementDetails.self, forKey: .engagement)
        self.id = self.post.id  // Derive id from post.id
        self.tags = self.post.tags
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(post, forKey: .post)
        try container.encode(user, forKey: .user)
        try container.encode(restaurant, forKey: .restaurant)
        try container.encode(dishes, forKey: .dishes)
        try container.encode(engagement, forKey: .engagement)
    }
}

struct PostDetails: Codable {
    let id: UUID
    let comment: String?
    let shared: Int
    let createdAt: Date?
    let updatedAt: Date?
    let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case comment
        case shared
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case tags
    }
}

struct UserDetails: Codable {
    let id: UUID
    let username: String?
    let firstName: String?
    let lastName: String?
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}

struct RestaurantDetails: Codable, Identifiable {
    let id: UUID
    let name: String
    let image: String?
    let description: String?
    let address: String?
//    let location: LocationCoordinates?
    let website: String?
    let telephone: String?
    let createdAt: Date?
    let updatedAt: Date?
    let rank: Double?
    let rating: Double?
    let avgRating: Double?
    let totalRating: Int?
    let isBookmarked: Bool?
    let distanceKm: Double?
    let topDishes: [Dish]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case description
        case address
//        case location
        case website
        case telephone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rank
        case rating
        case avgRating
        case totalRating = "total_rating"
        case isBookmarked = "is_bookmarked"
        case distanceKm = "distance_km"
        case topDishes = "top_dishes"
    }
    
    
}

struct LocationCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct DishRatingDetails: Codable {
    let dish: Dish
    let rating: Int
    let images: [String]?

    enum CodingKeys: String, CodingKey {
        case dish
        case rating = "userRating"
        case images
    }
}


//struct PlateDish: Decodable, Identifiable {
//    let id: UUID
//    let name: String
//    let description: String?
//    let categories: [String]?
//    let restaurantId: UUID
//    let restaurantName: String
//    let restaurantImage: String?
//    let addedAt: Date?
//    let image: String?
//}

struct Dish: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let categories: [String]?
    let createdAt: Date?
    let updatedAt: Date?
    let image: String?
    let restaurantId: UUID?
    let restaurantName: String?
//    let restaurantImage: String?
//    let restaurantAddress: String?
//    let distanceMeters: Double?
    let avgRating: Double?
    let ratingCount: Int?
    let rating: Double?
    let sectionType: String?
    let tags: [String]?
    let diets: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case categories
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case image
        case restaurantId, restaurantName, /*restaurantImage, restaurantAddress, distanceMeters,*/ avgRating, ratingCount, rating
        case sectionType = "section_type"
        case tags
        case diets
    }
}

extension Dish: Equatable {
    static func == (lhs: Dish, rhs: Dish) -> Bool {
        lhs.id == rhs.id
    }
}

struct EngagementDetails: Codable {
    var likesCount: Int
    var dislikesCount: Int
    var commentsCount: Int
    var engagementScore: Int
    var userHasLiked: Bool
    var userHasDisliked: Bool
    
    enum CodingKeys: String, CodingKey {
        case likesCount = "likes_count"
        case dislikesCount = "dislikes_count"
        case commentsCount = "comments_count"
        case engagementScore = "engagement_score"
        case userHasLiked = "user_has_liked"
        case userHasDisliked = "user_has_disliked"
    }
}

// Minimal version if you only get IDs
struct DishRatingMinimal: Codable {
    let dishId: UUID
    let rating: Int
}

struct RatingPostComment: Codable, Identifiable {
    let id: String
    let post_id: String
    let user_id: String
    let content: String
    let created_at: Date?
    let updated_at: Date?
}

struct RatingPostReaction: Codable, Identifiable {
    let id: String
    let post_id: String
    let user_id: String
    let is_like: Bool
    let created_at: Date?
    let updated_at: Date?
}

struct UserPlate: Codable, Identifiable {
    let id: String
    let user_id: String
    let plate_name: String
    let created_at: Date?
    let updated_at: Date?
}

struct UserPlateItem: Codable, Identifiable {
    let id: String
    let dish_id: String
    let user_plate_id: String
    let created_at: Date?
}

struct UserFollower: Codable, Identifiable {
    let id: String
    let follower_id: String
    let following_id: String
    let followed_at: Date?
}

struct Plate: Codable, Identifiable {
    let plateId: String
    let plateName: String
    let createdAt: Date?
    let updatedAt: Date?
    let dishes: [Dish]
    
    var id: String { plateId }
}



// Add these new structs to your models file or above the ProfileViewModel

struct FollowUser: Codable, Identifiable {
    let user_id: String
    let username: String
    let email: String?
    let phone: String?
    let email_verified: Bool?
    let phone_verified: Bool?
    let first_name: String
    let last_name: String
    let address: String?
    let tiktok: String?
    let instagram: String?
    let avatar: String?
    let bio: String?
    let created_at: Date?
    let followed_at: Date?
    
    var id: String { user_id }
    
    enum CodingKeys: String, CodingKey {
        case user_id, username, email, phone, email_verified, phone_verified, first_name, last_name, address, tiktok, instagram, avatar, bio, created_at, followed_at
    }
}

struct FollowData: Codable {
    let followers: [FollowUser]
    let following: [FollowUser]
}

//struct UserTopDish: Codable, Identifiable {
//    let dishId: UUID
//    let dishName: String
//    let dishDescription: String?
//    let dishImage: String?
//    let categories: [String]?
//    let dishRating: Double
//    let userRating: Int
//    let images: [String]?
//    let restaurantId: UUID
//    let restaurantName: String
//    let restaurantImage: String?
//    let restaurantRating: Double
//    let ratedAt: Date?
//    
//    var id: UUID { dishId }
//    
//    enum CodingKeys: String, CodingKey {
//        case dishId, dishName, dishDescription, dishImage, categories, dishRating, userRating, images, restaurantId, restaurantName, restaurantImage, restaurantRating, ratedAt
//    }
//}


struct VisitedRestaurant: Decodable, Identifiable {
    let restaurant: RestaurantDetails
    let avgRating: Double?
    let totalDishesRated: Int?
    let lastRatedAt: Date?
    
    var id: UUID { restaurant.id }
    
    enum CodingKeys: String, CodingKey {
        case restaurant
        case avgRating = "avg_rating"
        case totalDishesRated = "total_dishes_rated"
        case lastRatedAt = "last_rated_at"
    }
}


// MARK: - Single Post Response (exact match for get_post_by_id RPC)

struct SinglePostResponse: Decodable {
    let post: PostDetails
    let user: UserDetails
    let restaurant: RestaurantDetails
    let dishes: [SingleDishRatingDetails]
    let engagement: EngagementDetails
    
    // Convert to your existing RatingPost type
    var asRatingPost: RatingPost {
        RatingPost(
            id: post.id,
            post: post,
            user: user,
            restaurant: restaurant,
            dishes: dishes.map { $0.asDishRatingDetails },
            engagement: engagement,
            tags: post.tags
        )
    }
}

// Lightweight version that matches the exact JSON from your RPC
struct SingleDishRatingDetails: Decodable {
    let dish: Dish
    let rating: Int          // ← this is "rating" in the RPC (not userRating)
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case dish
        case rating          // important: no "userRating"
        case images
    }
    
    // Convert to your existing model
    var asDishRatingDetails: DishRatingDetails {
        DishRatingDetails(
            dish: dish,
            rating: rating,           // map to whatever your UI expects
            images: images
        )
    }
}

