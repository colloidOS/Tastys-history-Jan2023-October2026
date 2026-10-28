//
//  FoodViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 15/01/2026.
//

import SwiftUI
import Supabase

@MainActor
final class FoodViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isUpdateLoading = false
    private var errorTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?

    @Published var currentUser: UserDetails?
    @Published var userPlates: [UserPlateWithDishes] = []
    @Published var bookmarkedRestaurants: [RestaurantDetails] = []

    init() {
        session = supabase.auth.currentSession
        Task {
            await loadCurrentUser()
        }
    }
    
    func fetchData() async {
        guard let userId = session?.user.id else {
            print("no user found")
            return
        }
        if let bookmarks = await getUserBookmarks(userId: userId) {
            await MainActor.run {
                userPlates = bookmarks.plates
                bookmarkedRestaurants = bookmarks.bookmarkedRestaurants
                print("bookmak restarants: \(bookmarkedRestaurants)")
            }
        }
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

            currentUser = UserDetails(
                id: UUID(uuidString: profile.id) ?? UUID(),
                username: profile.username,
                firstName: profile.first_name,
                lastName: profile.last_name,
                avatar: profile.avatar
            )
        } catch {
            showError("Failed to load user profile")
            print("Failed to load user profile: \(error.localizedDescription)")
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
            isUpdateLoading = false
            showError(error.localizedDescription)
            print("Failed to create user plate: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Get User Plates (using get_user_plates_with_dishes for consistency, but note: use getUserBookmarks for full data)

    func getUserPlates(userId: UUID) async -> [UserPlateWithDishes]? {
        do {
            let params = ["p_user_id": userId.uuidString]

            let plates: [UserPlateWithDishes] = try await supabase
                .rpc("get_user_plates_with_dishes", params: params)
                .execute()
                .value

            print(plates)
            return plates
        } catch {
            showError("Failed to fetch user plates: \(error.localizedDescription)")
            print("Failed to fetch user plates: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Add Bookmarked Restaurant

    func addBookmarkedRestaurant(restaurantId: UUID) async {
        isUpdateLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let params = ["p_restaurant_id": restaurantId.uuidString]

            try await supabase
                .rpc("add_bookmarked_restaurant", params: params)
                .execute()

            isUpdateLoading = false
            showSuccess("Restaurant added to bookmarks successfully")
        } catch {
            isUpdateLoading = false
            showError("Failed to add bookmarked restaurant: \(error.localizedDescription)")
            print("Failed to add bookmarked restaurant: \(error.localizedDescription)")
        }
    }

    // MARK: - Remove Bookmarked Restaurant

    func removeBookmarkedRestaurant(restaurantId: UUID) async {
        isUpdateLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let params = ["p_restaurant_id": restaurantId.uuidString]

            try await supabase
                .rpc("remove_bookmarked_restaurant", params: params)
                .execute()

            isUpdateLoading = false
            showSuccess("Restaurant removed from bookmarks successfully")
        } catch {
            isUpdateLoading = false
            showError("Failed to remove bookmarked restaurant: \(error.localizedDescription)")
            print("Failed to remove bookmarked restaurant: \(error.localizedDescription)")
        }
    }

    // MARK: - Get User Bookmarks

    struct UserBookmarks: Decodable {
        let plates: [UserPlateWithDishes]
        let bookmarkedRestaurants: [RestaurantDetails]
    }

    func getUserBookmarks(userId: UUID) async -> UserBookmarks? {
        do {
            let params = ["p_user_id": userId.uuidString]

            let bookmarks: UserBookmarks = try await supabase
                .rpc("get_user_bookmarks", params: params)
                .execute()
                .value

            self.bookmarkedRestaurants = bookmarks.bookmarkedRestaurants
//            print("my bookmarked restaurants are \(bookmarkedRestaurants)")
            return bookmarks
            
        } catch {
            showError("Failed to fetch user bookmarks")
            print("Failed to fetch user bookmarks: \(error.localizedDescription)")
            return nil
        }
    }
    // MARK: - Remove Dishes from Plate

    struct RemoveDishesFromPlateParams: Encodable {
        let p_user_plate_id: String
        let p_dish_id: String
    }

    func removeDishesFromPlate(
        userPlateId: UUID,
        dishIds: [UUID]
    ) async -> Bool {

        guard !dishIds.isEmpty else { return true }

        isUpdateLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            for dishId in dishIds {
                let params = RemoveDishesFromPlateParams(
                    p_user_plate_id: userPlateId.uuidString,
                    p_dish_id: dishId.uuidString
                )

                try await supabase
                    .rpc("remove_dish_from_plate", params: params)
                    .execute()
            }

            isUpdateLoading = false
            showSuccess("Dishes removed from plate successfully")
            return true

        } catch {
            isUpdateLoading = false
            showError("Failed to remove dishes: \(error.localizedDescription)")
            print("Failed to remove dishes: \(error)")
            return false
        }
    }

}
