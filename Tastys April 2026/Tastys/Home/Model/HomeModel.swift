//
//  HomeModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/01/2026.
//

import SwiftUI


struct PostComment: Identifiable, Decodable {
    let comment: CommentDTO
    let user: UserDTO
    var likes: LikesDTO
    let replies: [PostReply]?
    var id: String { comment.id }
}

struct PostReply: Codable, Identifiable {
    var id: String { reply.id }
    let reply: CommentDTO
    let user: UserDTO
    // If replies have likes, add: let likes: LikesDTO?
}

struct CommentDTO: Codable {
    let id: String          // UUID as string
    let content: String
    let created_at: String // ISO timestamp
    let updated_at: String // ISO timestamp
}

struct UserDTO: Codable {
    let id: String          // UUID
    let username: String
    let first_name: String
    let last_name: String
    let avatar: String?    
}

struct LikesDTO: Codable {
    var count: Int
    var user_has_liked: Bool
}




// MARK: - Search Restaurants

struct SearchRestaurantsParams: Encodable {
    let search_term: String
    let result_limit: Int
}

struct SearchRestaurantsParamss: Encodable {
    let search_term: String
    let result_limit: Int
    let offset: Int
}


struct DishRatingParam: Encodable {
    let dish_id: String?
    let dish_name: String?
    let description: String?
    let rating: Int
    let images: [String]
    let categories: [String]
    let diets: [String]
    let tags: [String]
}


struct AddPostCommentParams: Encodable {
    let p_post_id: String
    let p_content: String
    let p_user_id: String
}

struct ToggleCommentLikeParams: Encodable {
    let p_comment_id: String
    let p_user_id: String
}

struct GetPostCommentsParams: Encodable {
    let p_post_id: String
    let p_current_user_id: String
    let p_limit: Int
    let p_offset: Int
    let p_order_by: String
}

struct DishRatingInput: Encodable {
    let dishId: String
    let rating: Int
    let imageData: [Data]  // Raw image data to upload
}


struct UserPlateWithDishes: Decodable, Identifiable {
    let plateName: String
    let plateId: UUID
    let createdAt: Date?
    let updatedAt: Date?
    let dishes: [Dish]
    
    
    var id: UUID { plateId }
}

//struct Plate: Codable, Identifiable {
//    let plateId: String
//    let plateName: String
//    let createdAt: Date?
//    let updatedAt: Date?
//    let dishes: [Dish]
//    
//    var id: String { plateId }
//}

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


struct TopRatedDish: Decodable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let categories: [String]?
    let image: String?
    let restaurantId: UUID
    let restaurantName: String
    let restaurantImage: String?
    let restaurantAddress: String?
    let distanceMeters: Double?
    let avgRating: Double
    let ratingCount: Int
}


struct Recommendation: Codable, Identifiable {
    let id: UUID
    let name: String?
    let reason: String?
    let emoji: String?
    let created_at: Date?       // usually timestamptz
    let updated_at: Date?       // usually timestamptz
    
    // If your table has more columns (created_by, is_active, etc.), add them here
}










struct RestaurantUserImage: Decodable {
    let image: String?
    let dishId: UUID
    let dishName: String?
//    let rating: Int
//    let user: ReviewerUser
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case image
        case dishId = "dish_id"
        case dishName = "dish_name"
//        case rating
//        case user
        case createdAt = "created_at"
    }
}



// Add near your other detail-related models (RestaurantDetails, Dish, etc.)

struct RestaurantDetailResponse: Decodable {
    let restaurant: RestaurantDetails
    let topDishes: [Dish]
    let totalVisits: Int
    let reviewers: [ReviewerUser]
    let followersRated: [ReviewerUser]
    let topUsers: [TopUserAtPlace]
    let ratingBreakdown: [String: RatingBucket]
    let userImages: [RestaurantUserImage]

    enum CodingKeys: String, CodingKey {
        case restaurant
        case topDishes = "top_dishes"
        case totalVisits = "total_visits"
        case reviewers
        case followersRated = "followers_rated"
        case topUsers = "top_users"
        case ratingBreakdown = "rating_breakdown"
        case userImages = "user_images"
    }
}

struct RatingBucket: Decodable {
    let count: Int
}
protocol AvatarUser: Identifiable {
    var avatar: String? { get }
}

enum RatingDetailType {
    case dish(DishDetailResponse)
    case restaurant(RestaurantDetailResponse)
}

struct DishDetailResponse: Decodable {
    let dish: Dish
    let restaurant: RestaurantDetails
    let mealRating: Int?
    let totalReviews: Int
    let reviewers: [ReviewerWithRating]
    let relatedDishes: [RelatedDishEntry]
    let followersRated: [ReviewerUser]
    let followingRated: [ReviewerUser]
    let topUsers: [TopUserWithRating]
    let ratingBreakdown: [String: RatingBucket]?
    let hasImages: Bool

    enum CodingKeys: String, CodingKey {
        case dish
        case restaurant
        case mealRating = "meal_rating"
        case totalReviews = "total_reviews"
        case reviewers
        case relatedDishes = "related_dishes"
        case followersRated = "followers_rated"
        case followingRated = "following_rated"
        case topUsers = "top_users"
        case ratingBreakdown = "rating_breakdown"
        case hasImages
    }
}

// ─── Helper sub-structures ─────────────────────────────────────

struct ReviewerUser: Decodable, Identifiable {
    let userId: String
    let name: String
    let avatar: String?
    let email: String?
    
    var id: String { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case avatar
        case email
    }
}

struct ReviewerWithRating: Decodable, Identifiable {
    let userId: String
    let name: String
    let avatar: String?
    let rating: Int
    
    var id: String { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case avatar
        case rating
    }
}

struct TopUserAtPlace: Decodable, Identifiable, AvatarUser {
    let userId: String
    let username: String
    let name: String
    let avatar: String?
    let communityScore: Double?
    let ratingsHere: Int?
    
    var id: String { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case name
        case avatar
        case communityScore = "community_score"
        case ratingsHere = "ratings_here"
    }
}

struct TopUserWithRating: Decodable, Identifiable, AvatarUser {
    let userId: String
    let username: String
    let name: String
    let avatar: String?
    let communityScore: Double?
    let rating: Int
    
    var id: String { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case name
        case avatar
        case communityScore = "community_score"
        case rating
    }
}

struct RelatedDishEntry: Decodable, Identifiable {
    let dish: Dish
    let restaurant: RestaurantDetails

    var id: UUID {
        dish.id
    }
}


struct RatingDetailData {
    let reviewers: [ReviewerWithRating]
    let totalReviews: Int
    let followersRated: [ReviewerUser]
    let topUsers: [TopUserWithRating]
    let averageRating: Int
}


struct NotificationActor: Codable {
    let user_id: String
    let username: String
    let first_name: String
    let last_name: String
    let avatar: String?
}

struct AppNotification: Codable, Identifiable {
    let id: String
    let type: String
    let is_read: Bool
    let created_at: Date

    let actor: NotificationActor?   // now optional — nil for geo/system pushes

    let post_id: String?
    let comment_id: String?

    // New: only populated for rows sourced from push_notification_log
    let storedTitle: String?
    let body: String?
}

struct PushLogRow: Codable {
    let id: String
    let notif_type: String
    let subject_id: String?
    let title: String
    let body: String
    let sent_at: Date
}

extension AppNotification {

    var message: String {
        if let storedBody = body, !storedBody.isEmpty {
            return storedBody
        }

        switch type {
        case "follow":
            return "@\(actor?.username ?? "Someone") followed you"
        case "post_like":
            return "\(actor?.username ?? "Someone") liked your post"
        case "post_comment":
            return "\(actor?.username ?? "Someone") commented on your post"
        case "comment_like":
            return "\(actor?.username ?? "Someone") liked your comment"
        case "comment_reply":
            return "\(actor?.username ?? "Someone") replied to your comment"
        default:
            return "New notification"
        }
    }

    var title: String? {
        storedTitle
    }

    var isSystemNotification: Bool {
        actor == nil
    }
}

extension AppNotification {

    var subtitle: String {
        switch type {
        case "follow":
            return "started following you"

        case "post_like":
            return "liked your post"

        case "post_comment":
            return "commented on your post"

        default:
            return ""
        }
    }
}


extension AppNotification {
    var timeAgoText: String {
        let seconds = Date().timeIntervalSince(created_at)
        if seconds < 60 {
            return "Just now"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated // "5m ago", "3h ago", "2d ago"
        formatter.formattingContext = .standalone
        formatter.calendar = {
            var cal = Calendar.current
            cal.locale = Locale.current
            return cal
        }()

        // Round down to the minute so it never renders seconds.
        let roundedDate = created_at.addingTimeInterval(-created_at.timeIntervalSince1970.truncatingRemainder(dividingBy: 60))
        return formatter.localizedString(for: roundedDate, relativeTo: Date())
    }
}


struct DishImage: Decodable, Identifiable {
    let image: String
    let ratingId: String
    let rating: Int
    let user: ReviewerUser
    let createdAt: Date

    var id: String {
        "\(ratingId)-\(image)"
    }

    enum CodingKeys: String, CodingKey {
        case image
        case ratingId = "rating_id"
        case rating
        case user
        case createdAt = "created_at"
    }
}

struct DishImagesResponse: Decodable {
    let images: [DishImage]
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case images
        case total
        case limit
        case offset
        case hasMore
    }
}

struct RestaurantImage: Decodable, Identifiable {
    let image: String
    let ratingId: String
    let dishId: String
    let dishName: String
    let rating: Int
    let user: ReviewerUser
    let createdAt: Date

    var id: String {
        "\(ratingId)-\(image)"
    }

    enum CodingKeys: String, CodingKey {
        case image
        case ratingId = "rating_id"
        case dishId = "dish_id"
        case dishName = "dish_name"
        case rating
        case user
        case createdAt = "created_at"
    }
}

struct RestaurantImagesResponse: Decodable {
    let images: [RestaurantImage]
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case images
        case total
        case limit
        case offset
        case hasMore
    }
}


struct GetNotificationsParams: Encodable {
    let p_user_id: String
    let p_limit: Int
    let p_offset: Int
}

struct GetPostsByFilterParams: Encodable {
    let p_dish_id: String?
    let p_restaurant_id: String?
    let p_sort_by: String?          // "popular" | "recent" | nil
    let p_limit: Int
    let p_offset: Int
    let p_current_user_id: String?
}


enum PostFeedType {
    case general
    case restaurant(String)     // restaurant_id
    case dish(String)           // dish_id
}
