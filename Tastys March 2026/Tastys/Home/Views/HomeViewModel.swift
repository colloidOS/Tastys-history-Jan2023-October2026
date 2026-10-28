//
//  HomeViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/01/2026.
//

import SwiftUI
import Combine
import Auth
import Supabase


@MainActor
final class HomeViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = false
    @Published var isLoadingCategory = false
    @Published var isCreating = false
    @Published var errorMessage: String?
    @Published var postErrorMessage: String?
    @Published var successMessage: String?
    @Published var isUpdateLoading = false
    private var errorTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?
    @Published var showRatingBreakdown = false
    @Published var breakdownDishId = ""
    @Published var currentRestaurant: RestaurantDetailResponse? = nil
    @Published var currentDish: DishDetailResponse? = nil
    @Published var currentSingleDish: Dish?
    private let authService = AuthService(supabase: supabase)

    // Additional published properties for home-specific data
    @Published var searchedRestaurants: [RestaurantDetails] = []
    @Published var searchedDishes: [Dish] = []
    
    // Pending review data for retry
    @Published var pendingUserId: UUID?
    @Published var pendingRestaurantId: String?
    @Published var pendingDishRatings: [DishRatingInput] = []
    @Published var pendingComment: String?
    @Published var selectedTags: [String]?
    
//    Notifications Section
    @Published var notifications: [AppNotification] = []
    @Published var isLoadingNotifications = false
    @Published var unreadNotificationCount = 0
    
    @Published var currentUser: UserDetails?
    @Published var userProfile: UserProfile?  // Added to store full profile

    @Published var showPostView = false
    @Published var prefillRestaurant: RestaurantDetails? = nil
    @Published var prefillDishes: [Dish]? = nil
    @Published var userPlates: [UserPlateWithDishes] = []
    @Published var topRatedDishes: [Dish] = []
    @Published var trendingDishes: [Dish] = []
    @Published var feedPosts: [RatingPost] = []
    @Published var dishPosts: [RatingPost] = []
    @Published var restaurantPosts: [RatingPost] = []
    @Published var currentFeedPage: Int = 0
    @Published var hasMoreFeedPosts = true
    private let postsPerPage = 10
    @Published var showSuccessScreen = false
    @Published var CurrentDishId: String?
    @Published var CurrentRestaurantId: String?
    
    @State private var errorQueue: [String] = []
    @State private var isShowingQueuedError = false
    
    @Published var dishImages: [DishImage] = []
    @Published var dishImagesTotal = 0
    @Published var dishImagesHasMore = false
    @Published var isLoadingDishImages = false
    @Published var isLoadingMoreDishImages = false

    var dishImagesOffset = 0
    let dishImagesLimit = 20
    
    @Published var restaurantImages: [RestaurantImage] = []
    @Published var restaurantImagesTotal = 0
    @Published var restaurantImagesHasMore = false
    @Published var isLoadingRestaurantImages = false
    @Published var isLoadingMoreRestaurantImages = false

    var restaurantImagesOffset = 0
    let restaurantImagesLimit = 20
    
    private var lastLoadedDishId: String?
    private var lastLoadedRestaurantId: String?
    var isAuthenticated: Bool {
        session != nil
    }
    
    init() {
        // Optionally load session or other initial data
        session = supabase.auth.currentSession
        Task {
            await loadCurrentUser()
        }
    }
    
    func showError(_ message: String) {
        errorTask?.cancel()

        withAnimation {
            errorMessage = message
        }

        errorTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let self = self else { return }

                withAnimation {
                    self.errorMessage = nil
                }
            }
        }
    }

    func showError(_ error: Error) {
        let message: String

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .timedOut:
                message = "No internet connection."

            default:
                message = error.localizedDescription
            }
        } else {
            message = error.localizedDescription
        }

        showError(message)
    }
    
    func showCreateError(_ message: String) {
        errorTask?.cancel()
        postErrorMessage = message

        errorTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await MainActor.run {
                withAnimation {
                    postErrorMessage = nil
                }
            }
        }
    }
    
    func toggleReaction(for postId: UUID, isLike: Bool) async throws {
        guard let userId = session?.user.id else { throw NSError(domain: "No user", code: 0) }
        
        // Fetch existing reaction
        let existing: [RatingPostReaction] = try await supabase
            .from("rating_post_reaction")
            .select()
            .eq("post_id", value: postId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        if let reaction = existing.first {
            if reaction.is_like == isLike {
                // Delete
                try await supabase
                    .from("rating_post_reaction")
                    .delete()
                    .eq("id", value: reaction.id)
                    .execute()
            } else {
                // Update
                try await supabase
                    .from("rating_post_reaction")
                    .update(["is_like": isLike])
                    .eq("id", value: reaction.id)
                    .execute()
            }
        } else {
            // Insert
            let newReaction = RatingPostReaction(
                id: UUID().uuidString,
                post_id: postId.uuidString,
                user_id: userId.uuidString,
                is_like: isLike,
                created_at: nil,
                updated_at: nil
            )
            try await supabase
                .from("rating_post_reaction")
                .insert(newReaction)
                .execute()
        }
        
        // TODO: Refresh the post's engagement details if needed
    }

    func showSuccess(_ message: String) {
        successTask?.cancel()

        successMessage = message

        successTask = Task {
            try? await Task.sleep(for: .seconds(3))

            if Task.isCancelled { return }

            await MainActor.run {
                withAnimation {
                    successMessage = nil
                }
            }
        }
    }
    
    
    // MARK: - Create Rating Post (updated with FileOptions + proper params)

    struct CreateRatingPostParams: Encodable {
        let p_user_id: String
        let p_restaurant_id: String
        let p_dish_ratings: [DishRatingParam]
        let p_comment: String?
        let p_tags: [String]?
    }

    struct DishRatingInput: Encodable {
        let dishId: String?
        let dishName: String?          // 👈 NEW (for user-created dish)
        let description: String?       // 👈 optional
        let imageData: [Data]

        let rating: Int

        let categories: [String]
        let diets: [String]
        let tags: [String]
    }
    func createRatingPost(userId: UUID, restaurantId: String, dishRatings: [DishRatingInput], comment: String?, tags: [String]?) async {
        isCreating = true
        postErrorMessage = nil
        successMessage = nil

        do {
            var dishRatingParams: [DishRatingParam] = []

            for input in dishRatings {
                var imageUrls: [String] = []
                for (index, data) in input.imageData.enumerated() {
                    let fileName = "\(UUID().uuidString)_dish_\(input.dishId ?? "")_img_\(index).jpg"
                    
                    let uploadedPath = try await supabase.storage
                        .from("rating")
                        .upload(
                            fileName,
                            data: data,
                            options: FileOptions(contentType: "image/jpeg")
                        )
                    
                    let publicUrl = try supabase.storage
                        .from("rating")
                        .getPublicURL(path: uploadedPath.path)  // ← use .path property!
                    
                    imageUrls.append(publicUrl.absoluteString)
                }

                dishRatingParams.append(
                    DishRatingParam(
                        dish_id: input.dishId,
                        dish_name: input.dishName,
                        description: input.description,
                        rating: input.rating,
                        images: imageUrls,
                        categories: input.categories,
                        diets: input.diets,
                        tags: input.tags
                    )
                )
            }

            let params = CreateRatingPostParams(
                p_user_id: userId.uuidString,
                p_restaurant_id: restaurantId,
                p_dish_ratings: dishRatingParams,
                p_comment: comment,
                p_tags: tags
            )

            let _: UUID = try await supabase
                .rpc("create_rating_post", params: params)
                .single()
                .execute()
                .value

            showSuccess("Review uploaded successfully")
            clearPending()
        } catch {
            if isCancellationError(error) {
                return
            }
            showCreateError("Failed to create rating post")
            showError("Failed to create rating post: \(error.localizedDescription)")
        }

        isCreating = false
    }
    
    func createRatingPost2(
        userId: UUID,
        restaurantId: String,
        dishRatings: [DishRatingInput],
        comment: String?,
        tags: [String]?
    ) async {

        isCreating = true
        defer { isCreating = false }

        do {
            var dishRatingParams: [DishRatingParam] = []

            for input in dishRatings {

                // 1. upload images
                var imageUrls: [String] = []

                for (index, data) in input.imageData.enumerated() {
                    let fileName = "\(UUID().uuidString)_\(index).jpg"

                    let uploaded = try await supabase.storage
                        .from("rating")
                        .upload(fileName, data: data)

                    let publicUrl = try supabase.storage
                        .from("rating")
                        .getPublicURL(path: uploaded.path)

                    imageUrls.append(publicUrl.absoluteString)
                }

                // 2. build param
                dishRatingParams.append(
                    DishRatingParam(
                        dish_id: input.dishId,
                        dish_name: input.dishName,
                        description: input.description,
                        rating: input.rating,
                        images: imageUrls,
                        categories: input.categories,
                        diets: input.diets,
                        tags: input.tags
                    )
                )
            }

            let params = CreateRatingPostParams(
                p_user_id: userId.uuidString,
                p_restaurant_id: restaurantId,
                p_dish_ratings: dishRatingParams,
                p_comment: comment,
                p_tags: tags
            )

            let _: UUID = try await supabase
                .rpc("create_rating_post_v2", params: params)
                .single()
                .execute()
                .value

            showSuccess("Review uploaded successfully")
            clearPending()
            showSuccessScreen = true
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("something went wrong")
            print("Failed: \(error.localizedDescription)")
        }
    }
    
    
    func retryPending() {
        guard let pUserId = pendingUserId,
              let pRest = pendingRestaurantId,
              !pendingDishRatings.isEmpty else { return }
        
        Task {
            await createRatingPost(
                userId: pUserId,
                restaurantId: pRest,
                dishRatings: pendingDishRatings,
                comment: pendingComment,
                tags: selectedTags
            )
        }
    }
    
    private func clearPending() {
        pendingUserId = nil
        pendingRestaurantId = nil
        pendingDishRatings = []
        pendingComment = nil
    }
    
    // MARK: - Comments
    
    
    struct GetPostCommentsParams: Encodable {
        let p_post_id: String
        let p_current_user_id: String?
        let p_limit: Int
        let p_offset: Int
        let p_order_by: String
    }
    
    func getPostComments(postId: UUID, limit: Int = 20, offset: Int = 0, orderBy: String = "newest") async -> [PostComment]? {
        do {
            let params = GetPostCommentsParams(
                p_post_id: postId.uuidString,
                p_current_user_id: session?.user.id.uuidString,
                p_limit: limit,
                p_offset: offset,
                p_order_by: orderBy
            )
            
            let result: [PostComment] = try await supabase
                .rpc("get_rating_post_comments", params: params)
                .execute()
                .value
//            print("post's comments: \(result)")
            
            return result
            
        } catch {
            if isCancellationError(error) {
                return nil
            }
            showError("Failed to fetch comments")
            print("Failed to fetch comments: \(error.localizedDescription)")
            return nil
        }
    }
    
    struct AddPostCommentParams: Encodable {
        let p_post_id: String
        let p_content: String
        let p_user_id: String
    }
    
    func addComment(to postId: UUID, content: String) async -> UUID? {
        do {
            let params = AddPostCommentParams(
                p_post_id: postId.uuidString,
                p_content: content,
                p_user_id: session?.user.id.uuidString ?? ""
            )
            
            let commentId: UUID = try await supabase
                .rpc("add_post_comment", params: params)
                .single()
                .execute()
                .value
            
            print("new comment id: \(commentId)")
            return commentId
        } catch {
            if isCancellationError(error) {
                return nil
            }
            showError("Failed to add comment")
            print("Failed to add comment: \(error.localizedDescription)")
            print(errorMessage ?? "error adding comment")
            return nil
        }
    }
    
    struct ToggleCommentLikeParams: Encodable {
        let p_comment_id: String
        let p_user_id: String
    }
    
    func toggleCommentLike(commentId: UUID) async -> String? {
        do {
            let params = ToggleCommentLikeParams(
                p_comment_id: commentId.uuidString,
                p_user_id: session?.user.id.uuidString ?? ""
            )
            
            let result: String = try await supabase
                .rpc("toggle_comment_like", params: params)
                .single()
                .execute()
                .value
            
            return result
        } catch {
            if isCancellationError(error) {
                return nil
            }
            showError("Failed to toggle comment like")
            print("Failed to toggle comment like: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Load Current User
    
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
    
    func loadCurrentUser() async {
        guard let userId = session?.user.id else { return }
        
        do {
            let profile: UserProfile = try await getUserById(userId.uuidString)
            self.userProfile = profile  // Store full profile
            
            currentUser = UserDetails(
                id: UUID(uuidString: profile.id) ?? UUID(),
                username: profile.username,
                firstName: profile.first_name,
                lastName: profile.last_name,
                avatar: profile.avatar
            )
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to load user profile")
            print("Failed to load user profile: \(error.localizedDescription)")
            
        }
    }
    

    
//    struct DishRatingInput: Encodable {
//        let dishId: String
//        let rating: Int
//        let imageData: [Data]  // Raw image data to upload
////        let tags: [String]
//    }

    

    
    func searchRestaurantsByName(searchTerm: String, resultLimit: Int = 10) async {
        isLoading = true
//        errorMessage = nil
//        searchedRestaurants = []

        do {
            let params = SearchRestaurantsParams(
                search_term: searchTerm,
                result_limit: resultLimit
            )

            searchedRestaurants = try await supabase
                .rpc("search_restaurants_by_name", params: params)
                .execute()
                .value
//            print(searchedRestaurants)
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to search restaurants")
            print("Failed to search restaurants: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Search Dishes

    struct SearchDishesParams: Encodable {
        let p_restaurant_id: String
        let p_query: String
    }

    func searchRestaurantDishes(restaurantId: UUID, query: String) async {
        isLoading = true
//        errorMessage = nil
//        searchedDishes = []

        do {
            let params = SearchDishesParams(
                p_restaurant_id: restaurantId.uuidString,
                p_query: query
            )

            searchedDishes = try await supabase
                .rpc("search_restaurant_dishes", params: params)
                .execute()
                .value
//            print(searchedDishes)
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to search dishes")
            print("Failed to search dishes: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Add to Plate

    struct AddToPlateParams: Encodable {
        let p_user_plate_id: String
        let p_dish_id: String
    }

    func addDishToPlate(userPlateId: UUID, dishId: UUID) async -> Bool {
        isUpdateLoading = true
        
        do {
            let response = try await supabase
                .rpc("add_dish_to_plate", params: [
                    "p_user_plate_id": userPlateId.uuidString,
                    "p_dish_id": dishId.uuidString
                ])
                .execute()
            
            isUpdateLoading = false
            
            // 2 bytes = "[]" (empty array from PostgREST when no rows returned)
            if response.data.count <= 2 {
                showSuccess("Dish is already in plate")
                return false
            } else {
                showSuccess("Dish added to plate successfully")
                return true
            }
            
        } catch {
            if isCancellationError(error) {
                return false
            }
            isUpdateLoading = false

            if let postgrestError = error as? PostgrestError {
                if postgrestError.message == "This dish is already in the plate" {
                    showSuccess("Dish is already in plate")
                    return false
                }
            }

            showError("Failed to add dish to plate")
            print("Error: \(error)")
            return false
        }
    }
    
    func suggestRestaurant(
        name: String,
        address: String,
        city: String
    ) async -> Bool {
        
        isUpdateLoading = true
        
        do {
            try await supabase
                .rpc("add_restaurant_suggestion", params: [
                    "p_name": name,
                    "p_address": address,
                    "p_city": city
                ])
                .execute()
            
            isUpdateLoading = false
            
            showSuccess("Restaurant suggestion submitted successfully")
            return true
            
        } catch {
            if isCancellationError(error) {
                return false
            }
            isUpdateLoading = false
            
            if let postgrestError = error as? PostgrestError {
                if postgrestError.message == "This restaurant has already been suggested." {
                    showSuccess("This restaurant has already been suggested")
                    return false
                }
            }
            
            showError("Failed to submit restaurant suggestion")
            print("Error: \(error)")
            return false
        }
    }

    // MARK: - Create Plate

    struct CreatePlateParams: Encodable {
        let p_user_id: String
        let p_plate_name: String
    }

    func createUserPlate(userId: UUID, plateName: String) async -> UserPlate? {
        isUpdateLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let params = CreatePlateParams(
                p_user_id: userId.uuidString,
                p_plate_name: plateName
            )

            let plate: UserPlate = try await supabase
                .rpc("create_user_plate", params: params)
                .single()
                .execute()
                .value

            isUpdateLoading = false
            showSuccess("User plate created successfully")
            return plate
        } catch {
            if isCancellationError(error) {
                return nil
            }
            isUpdateLoading = false
            
            if error.localizedDescription == "A plate with the name \"\(plateName)\" already exists for this user" {
                let err = "A plate with the name \"\(plateName)\" already exists"
                showError(err)
            } else {
                showError(error.localizedDescription)
            }
            print("Failed to create user plate: \(error.localizedDescription)")
            return nil
        }

        
    }
    
    func getUserPlates(userId: UUID) async -> [UserPlateWithDishes]? {
        do {
            let params = ["p_user_id": userId.uuidString]
            
            let plates: [UserPlateWithDishes] = try await supabase
                .rpc("get_user_plates_with_dishes", params: params)
                .execute()
                .value
            
            return plates
        } catch {
            if isCancellationError(error) {
                return nil
            }
            showError("Failed to fetch user plates")
            print("Failed to fetch user plates: \(error.localizedDescription)")
            return nil
        }
    }
    
    struct GetTopRatedDishesParams: Encodable {
        let p_user_id: String?
        let p_limit: Int
        let p_max_distance_meters: Double
        let p_category: String?
    }

    func getTopRatedDishesNearUser(
        limit: Int = 20,
        maxDistanceMeters: Double = 10000,
        category: String? = nil
    ) async {
        
        let userId = session?.user.id.uuidString
        
        isLoadingCategory = true
        do {
            let params = GetTopRatedDishesParams(
                p_user_id: userId,
                p_limit: limit,
                p_max_distance_meters: maxDistanceMeters,
                p_category: category
            )
                        
            
            let dishes: [Dish] = try await supabase
                .rpc("get_top_rated_dishes_near_users", params: params)
                .execute()
                .value
            
            topRatedDishes = dishes
            
//            print("top rated dishes: \(topRatedDishes)")
            isLoadingCategory = false
        } catch {
            if isCancellationError(error) {
                return
            }
            showError(error)
            print("Error fetching top rated dishes: \(error)")
            isLoadingCategory = false
        }
    }
    
    struct GetTrendingDishesParams: Encodable {
        let p_user_id: String?
        let p_limit: Int
        let p_max_distance_meters: Double
        let p_category: String?
    }

    func getTrendingDishesNearUser(
        limit: Int = 20,
        maxDistanceMeters: Double = 10000,
        category: String? = nil
    ) async {
        
//        guard
            let userId = session?.user.id
//        else { return }
        isLoadingCategory = true
        do {
            let params = GetTrendingDishesParams(
                p_user_id: userId?.uuidString,
                p_limit: limit,
                p_max_distance_meters: maxDistanceMeters,
                p_category: category
            )
            
            let dishes: [Dish] = try await supabase
                .rpc("get_trending_dishes_near_users", params: params)
                .execute()
                .value
            
            trendingDishes = dishes
            
//            print("trending dishes: \(trendingDishes)")
            isLoadingCategory = false
        } catch {
            if isCancellationError(error) {
                return
            }
            showError(error)
            print("Error fetching trending dishes: \(error)")
            isLoadingCategory = false
        }
    }
    
    func updateLocation(longitude: Double, latitude: Double) async {
        guard let userId = session?.user.id.uuidString else {
            showError("No user session")
            return
        }
        
        isUpdateLoading = true
        defer { isUpdateLoading = false }
        
        let pointString = "POINT(\(longitude) \(latitude))"
        do {
            try await supabase
                .from("user_profile")
                .update(["location": pointString])
                .eq("user_id", value: userId)
                .execute()
            
            // Reload user profile to update local state
            await loadCurrentUser()
            
            showSuccess("Location updated successfully")
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to update location")
            print("Failed to update location: \(error.localizedDescription)")
        }
    }
    
    func loadFeedPosts(refresh: Bool = false) async {
            guard hasMoreFeedPosts || refresh else { return }
            
            if refresh {
                currentFeedPage = 0
                feedPosts.removeAll()
                hasMoreFeedPosts = true
            }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let posts = try await getPosts(
                    limit: postsPerPage,
                    offset: currentFeedPage * postsPerPage,
                    userId: session?.user.id.uuidString  // optional: pass current user for personalized feed
                )
                
                await MainActor.run {
                    feedPosts.append(contentsOf: posts)
                    currentFeedPage += 1
                    
                    if posts.count < postsPerPage {
                        hasMoreFeedPosts = false
                    }
//                    print("feed posts:\(feedPosts)")
                    isLoading = false
                }
            } catch {
                if isCancellationError(error) {
                    return
                }
                await MainActor.run {
                    print("Failed to load feed: \(error.localizedDescription)")
                    showError("Failed to load feed")
                    isLoading = false
                }
            }
        }

        // MARK: - Helper: Get Posts (from service)

        func getPosts(limit: Int = 10, offset: Int = 0, userId: String? = nil) async throws -> [RatingPost] {
            let params = GetPostsParams(
                p_limit: limit,
                p_offset: offset,
                p_current_user_id: userId  // for personalized reactions/engagement
            )

            return try await supabase
                .rpc("get_posts", params: params)
                .execute()
                .value
        }

        // Call this when user scrolls near the bottom (e.g., in a List/.onAppear on last item)
        func loadMoreFeedPostsIfNeeded(currentPost: RatingPost?) async {
            guard let lastPost = feedPosts.last,
                  lastPost.id == currentPost?.id,
                  !isLoading,
                  hasMoreFeedPosts else { return }
            
            await loadFeedPosts()
        }

        // Refresh feed (pull to refresh)
        func refreshFeed() async {
            await loadFeedPosts(refresh: true)
        }
    // MARK: - Create Recommendation

    struct CreateRecommendationParams: Encodable {
        let p_name:   String
        let p_reason: String
        let p_emoji:  String
    }

    func createRecommendation(name: String, reason: String, emoji: String) async -> Recommendation? {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let params = CreateRecommendationParams(
                p_name:   name,
                p_reason: reason,
                p_emoji:  emoji
            )
            
            let newRecommendation: Recommendation = try await supabase
                .rpc("create_recommendation", params: params)
                .single()
                .execute()
                .value
            
            await MainActor.run {
                showSuccess("Recommendation added successfully!")
                // Optional: if you want to keep a local list of recent recommendations
                // self.recentRecommendations.insert(newRecommendation, at: 0)
            }
            
            isLoading = false
            return newRecommendation
        } catch {
            if isCancellationError(error) {
                    return nil
                }
            await MainActor.run {
                showError("Failed to create recommendation")
                print("Failed to create recommendation: \(error.localizedDescription)")
            }
            isLoading = false
            return nil
        }
    }
    
    func fetchRestaurantDetail(restaurantId: String, userId: String? = nil) async {
        isLoading = true
        errorMessage = nil
        currentRestaurant = nil
        
        do {
            // Use String? directly — Supabase/PostgREST handles NULL correctly when value is nil
            let params = [
                "p_restaurant_id": restaurantId,
                "p_user_id": userId     // ← just pass the optional String
            ]
            
            let result: RestaurantDetailResponse = try await supabase
                .rpc("get_restaurant_by_id", params: params)
                .single()
                .execute()
                .value
            
            self.currentRestaurant = result
        } catch {
            if isCancellationError(error) {
                    return
                }
            showError("Failed to load restaurant details")
            print("error loading restaurant:", error)
        }
        
        isLoading = false
    }
        
    func fetchDishDetail(dishId: String, userId: String? = nil) async {
        isLoading = true
        errorMessage = nil
//        currentDish = nil
        
        do {
            let params = [
                "p_dish_id": dishId,
                "p_user_id": userId     // ← String? is fine
            ]
            
            let result: DishDetailResponse = try await supabase
                .rpc("get_dish_by_id", params: params)
                .single()
                .execute()
                .value
            
            self.currentDish = result
            print(self.currentDish ?? "nothing fetched")
            self.currentSingleDish = self.currentDish?.dish
//            print(self.currentSingleDish)
        } catch {
            if isCancellationError(error) {
                    return
                }
            showError("Failed to load dish details")
            print("error loading dish:", error)
        }
        
        isLoading = false
    }
    
    // Inside HomeViewModel
    // Update loadFilteredPosts:
    func loadFilteredPosts(
        dishId: String? = nil,
        restaurantId: String? = nil,
        sortBy: String? = nil, // "popular" or "recent"
        limit: Int = 10,
        offset: Int = 0,
        refresh: Bool = false,
        feedType: PostFeedType,
        filterHighRated: Bool = false
    ) async {
        guard !isLoading else { return }
        
        if refresh {
            switch feedType {
            case .general:
                feedPosts.removeAll()
            case .restaurant:
                restaurantPosts.removeAll()
                lastLoadedRestaurantId = restaurantId
            case .dish:
                dishPosts.removeAll()
                lastLoadedDishId = dishId
            }
            currentFeedPage = 0
            hasMoreFeedPosts = true
        } else {
            switch feedType {
            case .general:
                break
            case .restaurant(let id):
                if lastLoadedRestaurantId != id {
                    restaurantPosts.removeAll()
                    currentFeedPage = 0
                    hasMoreFeedPosts = true
                    lastLoadedRestaurantId = id
                }
            case .dish(let id):
                if lastLoadedDishId != id {
                    dishPosts.removeAll()
                    currentFeedPage = 0
                    hasMoreFeedPosts = true
                    lastLoadedDishId = id
                }
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let params = GetPostsByFilterParams(
                p_dish_id: dishId,
                p_restaurant_id: restaurantId,
                p_sort_by: sortBy,
                p_limit: limit,
                p_offset: offset,
                p_current_user_id: session?.user.id.uuidString
            )
            
            var newPosts: [RatingPost] = try await supabase
                .rpc("get_posts_by_filter", params: params)
                .execute()
                .value
            
            if filterHighRated {
                if let dishId = dishId {
                    newPosts = newPosts.filter { post in
                        guard let dishes = post.dishes else { return false }
                        if let matching = dishes.first(where: { $0.dish.id.uuidString == dishId }) {
                            return matching.rating >= 80
                        }
                        return false
                    }
                } else {
                    newPosts = newPosts.filter { post in
                        guard let dishes = post.dishes, !dishes.isEmpty else {
                            return false
                        }
                        let avg = dishes.reduce(0.0) { $0 + Double($1.rating) } / Double(dishes.count)
                        return avg >= 80.0
                    }
                }
            }
            
            await MainActor.run {
                switch feedType {
                case .general:
                    feedPosts.append(contentsOf: newPosts)
                    currentFeedPage += 1
                    
                    if newPosts.count < limit {
                        hasMoreFeedPosts = false
                    }
                    
                    isLoading = false
                case .restaurant(_):
                    restaurantPosts.append(contentsOf: newPosts)
                    currentFeedPage += 1
                    
                    if newPosts.count < limit {
                        hasMoreFeedPosts = false
                    }
                    
                    isLoading = false
                case .dish(_):
                    dishPosts.append(contentsOf: newPosts)
                    currentFeedPage += 1
                    
                    if newPosts.count < limit {
                        hasMoreFeedPosts = false
                    }
                    
                    isLoading = false
                }
            }
        } catch {
            if isCancellationError(error) {
                    return
                }
            await MainActor.run {
                isLoading = false
                showError("Failed to load filtered posts: \(error.localizedDescription)")
                print(error)
            }
        }
    }
    // For restaurant-specific feed
    func loadRestaurantPosts(
        restaurantId: String,
        sortBy: String? = "recent",
        refresh: Bool = false,
        filterHighRated: Bool = false
    ) async {
        await loadFilteredPosts(
            restaurantId: restaurantId,
            sortBy: sortBy,
            refresh: refresh,
            feedType: .restaurant(restaurantId),
            filterHighRated: filterHighRated
        )
    }

    // For dish-specific feed
    func loadDishPosts(
        dishId: String,
        sortBy: String? = "popular",
        refresh: Bool = false,
        filterHighRated: Bool = false
    ) async {
        await loadFilteredPosts(
            dishId: dishId,
            sortBy: sortBy,
            refresh: refresh,
            feedType: .dish(dishId),
            filterHighRated: filterHighRated
        )
    }

    // General / home feed (no filter)
    func loadGeneralFeed(
        sortBy: String? = "recent",
        refresh: Bool = false
    ) async {
        await loadFilteredPosts(
            sortBy: sortBy,
            refresh: refresh, feedType: .general
        )
    }
    func addBookmarkedRestaurant(restaurantId: UUID) async -> Bool {
        isUpdateLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let params = ["p_restaurant_id": restaurantId.uuidString]

            try await supabase
                .rpc("add_bookmarked_restaurant", params: params)
                .execute()

            isUpdateLoading = false
            showSuccess("Restaurant added to bookmarks")

            return true

        } catch {
            if isCancellationError(error) {
                    return false
                }
            isUpdateLoading = false
            showError("Failed to bookmark restaurant")
            print("Failed to bookmark restaurant: \(error.localizedDescription)")

            return false
        }
    }

    func removeBookmarkedRestaurant(restaurantId: UUID) async -> Bool {
        isUpdateLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let params = ["p_restaurant_id": restaurantId.uuidString]

            try await supabase
                .rpc("remove_bookmarked_restaurant", params: params)
                .execute()

            isUpdateLoading = false
            showSuccess("Restaurant removed from bookmarks")

            return true

        } catch {
            if isCancellationError(error) {
                    return false
                }
            isUpdateLoading = false
            showError("Failed to remove bookmarked restaurant: \(error.localizedDescription)")
            print("Failed to remove bookmarked restaurant: \(error.localizedDescription)")

            return false
        }
    }
    

    struct GetCommentRepliesParams: Encodable {
        let p_comment_id: String
        let p_current_user_id: String?
        let p_limit: Int
        let p_offset: Int
        let p_order_by: String
    }

    func getCommentReplies(
        commentId: UUID,
        limit: Int = 50,
        offset: Int = 0,
        orderBy: String = "oldest"
    ) async -> [PostReply]? {
        let params = GetCommentRepliesParams(
            p_comment_id: commentId.uuidString,
            p_current_user_id: session?.user.id.uuidString,
            p_limit: limit,
            p_offset: offset,
            p_order_by: orderBy
        )
        
        do {
            let replies: [PostReply] = try await supabase
                .rpc("get_comment_replies", params: params)
                .execute()
                .value
            print("Full replies fetch for \(commentId) → got \(replies.count) replies")
            print("First few: ", replies.prefix(3).map { $0.reply.content })
            return replies
        } catch {
            if isCancellationError(error) {
                    return nil
                }
            showError("Failed to fetch replies")
            print("Failed to fetch replies: \(error.localizedDescription)")
            return nil
        }
    }

    struct AddCommentReplyParams: Encodable {
        let p_comment_id: String
        let p_user_id: String
        let p_content: String
    }

    func addCommentReply(commentId: UUID, content: String) async -> UUID? {
        guard let userId = session?.user.id.uuidString else {
            showError("No user session")
            return nil
        }
        
        let params = AddCommentReplyParams(
            p_comment_id: commentId.uuidString,
            p_user_id: userId,
            p_content: content
        )
        
        do {
            let replyId: UUID = try await supabase
                .rpc("add_comment_reply", params: params)
                .single()
                .execute()
                .value
            return replyId
        } catch {
            if isCancellationError(error) {
                    return nil
                }
            showError("Failed to add reply")
            print("Failed to add reply: \(error.localizedDescription)")
            return nil
        }
    }

    func getPostById(postId: UUID) async throws -> RatingPost {
        let params: [String: String?] = [
            "p_post_id": postId.uuidString,
            "p_current_user_id": session?.user.id.uuidString
        ]
        
//        print("🔍 getPostById called for: \(postId.uuidString)")
        
        let response: SinglePostResponse = try await supabase
            .rpc("get_post_by_id", params: params)
            .single()
            .execute()
            .value
        
        print("✅ RPC succeeded — comments count: \(response.engagement.commentsCount)")
        
        return response.asRatingPost
    }
    func getNotifications(
        limit: Int = 20,
        offset: Int = 0
    ) async {

        guard let userId = session?.user.id.uuidString else {
            return
        }

        isLoadingNotifications = true

        defer {
            isLoadingNotifications = false
        }

        do {

            let params = GetNotificationsParams(
                p_user_id: userId,
                p_limit: limit,
                p_offset: offset
            )

            let notifications: [AppNotification] = try await supabase
                .rpc("get_user_notifications", params: params)
                .execute()
                .value

            self.notifications = notifications
            print(self.notifications)

            unreadNotificationCount = notifications.filter {
                !$0.is_read
            }.count

        } catch {
            if isCancellationError(error) {
                    return
                }
            showError(error)
            print(error.localizedDescription)
        }
    }
    
    func markNotificationsAsRead() async {

        guard let userId = session?.user.id.uuidString else {
            return
        }

        do {
            try await supabase
                .rpc(
                    "mark_notifications_as_read",
                    params: [
                        "p_user_id": userId
                    ]
                )
                .execute()

            notifications = notifications.map {
                AppNotification(
                    id: $0.id,
                    type: $0.type,
                    is_read: true,
                    created_at: $0.created_at,
                    actor: $0.actor,
                    post_id: $0.post_id,
                    comment_id: $0.comment_id,
                    storedTitle: $0.storedTitle,
                    body: $0.body
                )
            }

            unreadNotificationCount = 0

        } catch {
            if isCancellationError(error) {
                    return
                }
            print(error)
        }
    }
    
    private func fetchSystemNotifications() async -> [AppNotification] {
        guard let userId = try? await supabase.auth.session.user.id else { return [] }
        do {
            let rows: [PushLogRow] = try await supabase
                .from("push_notification_log")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("sent_at", ascending: false)
                .limit(50)
                .execute()
                .value

            return rows.map { row in
                AppNotification(
                    id: row.id,
                    type: row.notif_type,
                    is_read: true, // see note below
                    created_at: row.sent_at,
                    actor: nil,
                    post_id: nil,
                    comment_id: nil,
                    storedTitle: row.title,
                    body: row.body
                )
            }
        } catch {
            print("Failed to fetch push notifications: \(error)")
            return []
        }
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
}



