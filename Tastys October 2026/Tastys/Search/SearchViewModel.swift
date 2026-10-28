//
//  SearchViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/02/2026.
//

import SwiftUI
import Supabase
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchedDishes: [Dish] = []
    @Published var searchedRestaurants: [RestaurantDetails] = []
    @Published var searchedFoodies: [UserProfile] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false          // ← NEW
    @Published var errorMessage: String?
    @Published var searchText = ""
    private var searchTask: Task<Void, Never>?
    
    @Published var hasMoreDishes = false          // ← NEW
    @Published var hasMoreRestaurants = false     // ← NEW
    @Published var hasMoreFoodies = false         // ← NEW
    
    private let postsPerPage = 20
    private var dishOffset = 0                    // ← NEW
    private var restaurantOffset = 0              // ← NEW
    private var foodieOffset = 0                  // ← NEW
    
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
    
    // Wherever the user's input changes, e.g. in your View or ViewModel:
    func onSearchTextChanged(_ term: String) {
        searchTask?.cancel()
        searchTask = Task {
            await searchDishes(term: term)
        }
    }
   
    // MARK: - Initial Search (resets pagination)
    func searchDishes(term: String) async {
        if term.isEmpty {
            searchedDishes = []
            hasMoreDishes = false
            dishOffset = 0
            return
        }

        // Debounce: wait a bit before firing, bail if a newer keystroke already cancelled us
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        if Task.isCancelled { return }

        isLoading = true
        errorMessage = nil
        dishOffset = 0
        searchedDishes = []

        do {
            let params = SearchRestaurantsParamss(search_term: term, result_limit: postsPerPage, offset: dishOffset)
            let results: [Dish] = try await supabase
                .rpc("search_rated_dishes_by_name", params: params)
                .execute()
                .value

            // CRITICAL: check again after the await returns —
            // a newer search may have started and cancelled us while we were waiting on the network
            if Task.isCancelled { return }

            searchedDishes = results
            print(searchedDishes)
            hasMoreDishes = results.count == postsPerPage
            dishOffset = results.count
        } catch {
            if Task.isCancelled || isCancellationError(error) {
                return
            }
            print("Failed to search dishes: \(error.localizedDescription)")
            hasMoreDishes = false
        }

        isLoading = false
    }
    
    func searchRestaurants(term: String) async {
        if term.isEmpty {
            searchedRestaurants = []
            hasMoreRestaurants = false
            restaurantOffset = 0
            return
        }
        
        isLoading = true
        errorMessage = nil
        restaurantOffset = 0
        searchedRestaurants = []
        
        do {
            let params = SearchRestaurantsParamss(search_term: term, result_limit: postsPerPage, offset: restaurantOffset)
            let results: [RestaurantDetails] = try await supabase
                .rpc("search_rated_restaurants_by_name", params: params)
                .execute()
                .value
            
            searchedRestaurants = results
            hasMoreRestaurants = results.count == postsPerPage
            restaurantOffset = results.count
        } catch {
            if isCancellationError(error) {
                return
            }
//            errorMessage = "something went wrong"
            print("Failed to search restaurants: \(error.localizedDescription)")
            hasMoreRestaurants = false
        }
        
        isLoading = false
    }
    
    func searchFoodies(term: String) async {
        if term.isEmpty {
            searchedFoodies = []
            hasMoreFoodies = false
            foodieOffset = 0
            return
        }
        
        isLoading = true
        errorMessage = nil
        foodieOffset = 0
//        searchedFoodies = []
        
        do {
            let params = SearchRestaurantsParamss(search_term: term, result_limit: postsPerPage, offset: foodieOffset)
            let results: [UserProfile] = try await supabase
                .rpc("search_user_profiles", params: params)
                .execute()
                .value
            
            searchedFoodies = results
            print(searchedFoodies)
            hasMoreFoodies = results.count == postsPerPage
            foodieOffset = results.count
        } catch {
            if isCancellationError(error) {
                return
            }
//            errorMessage = "something went wrong"
            print("Failed to search foodies: \(error.localizedDescription)")
            hasMoreFoodies = false
        }
        
        isLoading = false
    }
    
    // MARK: - Load More (called when reaching the end)
    func loadMoreDishes(term: String) async {
        guard hasMoreDishes, !isLoadingMore, !term.isEmpty else { return }
        isLoadingMore = true
        
        do {
            let params = SearchRestaurantsParamss(search_term: term, result_limit: postsPerPage, offset: dishOffset)
            let newResults: [Dish] = try await supabase
                .rpc("search_rated_dishes_by_name", params: params)
                .execute()
                .value
            
            searchedDishes.append(contentsOf: newResults)
            hasMoreDishes = newResults.count == postsPerPage
            dishOffset += newResults.count
        } catch {
            if isCancellationError(error) {
                return
            }
            hasMoreDishes = false
        }
        
        isLoadingMore = false
    }
    
    func loadMoreRestaurants(term: String) async {
        guard hasMoreRestaurants, !isLoadingMore, !term.isEmpty else { return }
        isLoadingMore = true
        
        do {
            let params = SearchRestaurantsParamss(search_term: term, result_limit: postsPerPage, offset: restaurantOffset)
            let newResults: [RestaurantDetails] = try await supabase
                .rpc("search_rated_restaurants_by_name", params: params)
                .execute()
                .value
            
            searchedRestaurants.append(contentsOf: newResults)
            hasMoreRestaurants = newResults.count == postsPerPage
            restaurantOffset += newResults.count
        } catch {
            if isCancellationError(error) {
                return
            }
            hasMoreRestaurants = false
        }
        
        isLoadingMore = false
    }
    
    func loadMoreFoodies(term: String) async {
        guard hasMoreFoodies, !isLoadingMore, !term.isEmpty else { return }
        isLoadingMore = true
        
        do {
            let params = SearchRestaurantsParamss(search_term: term, result_limit: postsPerPage, offset: foodieOffset)
            let newResults: [UserProfile] = try await supabase
                .rpc("search_user_profiles", params: params)
                .execute()
                .value
            
            searchedFoodies.append(contentsOf: newResults)
            hasMoreFoodies = newResults.count == postsPerPage
            foodieOffset += newResults.count
        } catch {
            if isCancellationError(error) {
                return
            }
            hasMoreFoodies = false
        }
        
        isLoadingMore = false
    }
    
    func clearResults() {
        searchedDishes = []
        searchedRestaurants = []
        searchedFoodies = []
        dishOffset = 0
        restaurantOffset = 0
        foodieOffset = 0
        hasMoreDishes = false
        hasMoreRestaurants = false
        hasMoreFoodies = false
    }
}


extension TopDish {
    func toDish() -> Dish {
        Dish(
            id: UUID(uuidString: dishId) ?? UUID(),
            name: dishName,
            description: dishDescription,
            categories: dishCategories,
            createdAt: nil,
            updatedAt: nil,
            image: dishImage,
            restaurantId: UUID(uuidString: restaurantId),
            restaurantName: restaurantName,
            avgRating: rating,
            ratingCount: ratingCount,
            rating: rating,
            sectionType: nil, tags: nil,
            diets: []
        )
    }
}

extension TrendingDish {
    func toDish() -> Dish {
        Dish(
            id: UUID(uuidString: dishId) ?? UUID(),
            name: dishName ?? "Unknown Dish",
            description: dishDescription,
            categories: dishCategories,
            createdAt: nil,
            updatedAt: nil,
            image: dishImage,
            restaurantId: restaurantId != nil
                ? UUID(uuidString: restaurantId!)
                : nil,
            restaurantName: restaurantName,
            avgRating: dishRating,
            ratingCount: ratingCount,
            rating: dishRating,
            sectionType: nil, tags: nil,
            diets: []
        )
    }
}

extension TopRestaurant {
    func toRestaurantDetails() -> RestaurantDetails {
        RestaurantDetails(
            id: UUID(uuidString: restaurantId) ?? UUID(),
            name: restaurantName,
            image: restaurantImage,
            description: restaurantDescription,
            address: restaurantAddress,
            website: restaurantWebsite,
            telephone: restaurantTelephone,
            createdAt: nil,
            updatedAt: nil,
            rank: nil,
            rating: rating,
            avgRating: rating,
            totalRating: ratingCount,
            isBookmarked: isBookmarked,
            distanceKm: distanceKm,
            topDishes: topDishes
        )
    }
}

extension TopUser {
    func toUserProfile() -> UserProfile {
        UserProfile(
            idField: userId,
            user_id: userId,
            username: username,
            email: nil,
            phone: nil,
            email_verified: nil,
            phone_verified: nil,
            first_name: firstName,
            last_name: lastName,
            address: nil,
            location: nil,
            tiktok: nil,
            instagram: nil,
            avatar: avatar,
            bio: nil,
            created_at: nil,
            followers_count: followersCount,
            following_count: followingCount,
            average_rating: nil,
            community_score: communityScore,
            food_profile: nil,
            totalDishesRated: dishRatingCount,
            totalRestaurantsVisited: restaurantVisitedCount,
            topDishes: topDishes,
            otherHighRatedCount: otherHighRatedCount,
            isFollowing: isFollowing
        )
    }
}
