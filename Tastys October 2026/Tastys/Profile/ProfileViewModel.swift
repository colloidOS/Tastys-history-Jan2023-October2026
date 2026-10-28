//
//  ProfileViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/01/2026.
//

import SwiftUI
import Combine
import Auth

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var friendsProfile: UserProfile?
    @Published var isFollowing = false
    @Published var plates: [Plate] = []
    @Published var posts: [RatingPost] = []
    @Published var friendPosts: [RatingPost] = []
    @Published var isLoading = false
    @Published var isFollowLoading = false
    @Published var errorMessage: String?
    @AppStorage("avatar") private var avatar = ""
    @Published var followers: [FollowUser] = []
    @Published var following: [FollowUser] = []
    @Published var friendsFollowers: [FollowUser] = []
    @Published var friendsFollowing: [FollowUser] = []
    @Published var topDishes: [Dish] = []
    @Published var friendTopDishes: [Dish] = []
    @Published var userRestaurants: [VisitedRestaurant] = []
//    @Published var friendRestaurants: [VisitedRestaurant] = []
    @Published var visitedRestaurants: [RestaurantDetails] = []
    @Published var friendRestaurants: [VisitedRestaurant] = []
    @Published var friendVisitedRestaurants: [RestaurantDetails] = []
    @Published var isDeleting = false
    
    @Published var session: Session?
    private let authService = AuthService(supabase: supabase)
    @Published var successMessage: String?
    @Published var isUpdateLoading = false
    private var errorTask: Task<Void, Never>?
 
    private let service = UserProfileService(supabase: supabase)
 
    private let userIdOrUsername: String
    private let isUsingUsername: Bool
    
    var userId: String {
        userIdOrUsername
    }
 
    init(userId: String, isUsername: Bool = false) {
        self.userIdOrUsername = userId
        self.isUsingUsername = isUsername
        if !isUsername && (userId.isEmpty || UUID(uuidString: userId) == nil) {
            errorMessage = "Invalid or empty user ID provided."
            print(errorMessage ?? "error")
            return
        }
    }
    
    private var currentSession: Session? {
            supabase.auth.currentSession
        }
 
    convenience init(userId: String) {
        self.init(userId: userId, isUsername: false)
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
 
    // Fetch profile by id or username
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            if isUsingUsername {
                profile = try await service.getUserByUsername(userIdOrUsername)
 //               print("profile: \(String(describing: profile))")
            } else {
                profile = try await service.getUserById(userIdOrUsername)
//                print("profile: \(String(describing: profile))")
                if let profilePicture = profile?.avatar {
                    avatar = profilePicture
                }
            }
        } catch {
            if isCancellationError(error) {
                return
            }
            print("FULL DECODING ERROR: \(error)")
            showError("Failed to load profile")
 //           errorMessage = "Failed to load profile: \(error.localizedDescription)"
            print("error: Failed to load profile: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func loadFriendsProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        do {

                friendsProfile = try await service.getUserById(userId)
//                print("friend's profile: \(String(describing: friendsProfile))")
                
        } catch {
            if isCancellationError(error) {
                return
            }
            print("FULL DECODING ERROR: \(error)")
            showError("Failed to load profile")
 //           errorMessage = "Failed to load profile: \(error.localizedDescription)"
            print("error: Failed to load friends profile: \(error.localizedDescription)")
        }
        isLoading = false
    }
 
    func loadPlates() async {
        guard let uid = profile?.user_id else { return }
        do {
            plates = try await service.getUserPlatesWithDishes(userId: uid)
 //           print("Plates: \(plates)")
        } catch {
            if isCancellationError(error) {
                return
            }
            errorMessage = "Failed to load plates: \(error.localizedDescription)"
            print("error: \(errorMessage ?? "")")
            showError("failed to load plates")
        }
    }
 
    func loadPosts(limit: Int = 20, userId: String) async {
        guard let uid = profile?.user_id else { return }
        do {
            posts = try await service.getUserPosts(limit: limit, offset: 0, userId: userId, currentUserId: uid)
//            print("your posts: \(posts)")
        } catch {
            if isCancellationError(error) {
                return
            }
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
            print("error: \(errorMessage ?? "")")
            showError("failed to load post")
        }
    }
    
    func loadFriendPosts(limit: Int = 20, userId: String) async {
        /*guard*/ let uid = userId /*else {*/
//            return
//        }
        do {
            friendPosts = try await service.getUserPosts(limit: limit, offset: 0, userId: userId, currentUserId: uid)
//            print("friend posts: \(friendPosts)")
        } catch {
            if isCancellationError(error) {
                return
            }
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
            print("error: \(errorMessage ?? "")")
            showError("failed to load post")
        }
    }

 
    // Follow / unfollow convenience
    func follow(currentUserId: String) async {
        guard let targetUser = profile?.user_id else { return }
        do {
            try await service.followUser(userId: currentUserId, otherUserId: targetUser)
        } catch {
            if isCancellationError(error) {
                return
            }
            errorMessage = "Follow failed: \(error.localizedDescription)"
            print("error: \(errorMessage ?? "")")
            showError("Follow failed")
        }
    }
 
    func unfollow(currentUserId: String) async {
        guard let targetUser = profile?.user_id else { return }
        do {
            try await service.unfollowUser(userId: currentUserId, otherUserId: targetUser)
        } catch {
            if isCancellationError(error) {
                return
            }
            errorMessage = "Unfollow failed: \(error.localizedDescription)"
            showError("Unfollow failed")
            print("error: \(errorMessage ?? "")")
        }
    }
    
    func showError(_ message: String) {
        errorTask?.cancel()
        errorMessage = message
 
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation {
                    errorMessage = nil
                }
            }
        }
    }
 
    
    /// Checks if a username is available
    func isUsernameAvailable(_ username: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
 
        do {
            let available = try await authService.checkUsernameAvailability(username)
            if !available {
                showError("Username is already taken")
            }
            return available
        } catch {
            if isCancellationError(error) {
                return false
            }
            showError(error.localizedDescription)
            return false
        }
    }
 
        /// Updates the username for the current user
    func updateUsername(_ username: String) async -> Bool {
        guard let session = currentSession else {
            showError("User not authenticated")
            return false
        }
 
        isUpdateLoading = true
        defer { isUpdateLoading = false }
 
        do {
            _ = try await authService.updateUsername(
                userId: session.user.id.uuidString,
                username: username
            )
            successMessage = "Username updated"
            return true
        } catch {
            if isCancellationError(error) {
                return false
            }
            showError(error.localizedDescription)
            return false
        }
    }
    
    func updateOtherFields(firstName: String, lastName: String, bio: String, location: String, instagram: String, tiktok: String, avatar: String?, foodProfile: String?) async {
        isUpdateLoading = true
        defer { isUpdateLoading = false }
        
        struct ProfileUpdate: Encodable {
            let first_name: String
            let last_name: String
            let bio: String?
            let location: String?
            let instagram: String?
            let tiktok: String?
            let avatar: String?
            let food_profile: String?
        }
        
        do {
            let updateData = ProfileUpdate(
                first_name: firstName,
                last_name: lastName,
                bio: bio.isEmpty ? nil : bio,
                location: location.isEmpty ? nil : location,
                instagram: instagram.isEmpty ? nil : instagram,
                tiktok: tiktok.isEmpty ? nil : tiktok,
                avatar: avatar,
                food_profile: foodProfile
            )
            
            try await supabase
                .from("user_profile")
                .update(updateData)
                .eq("user_id", value: userIdOrUsername)
                .execute()
            
            if var currentProfile = profile {
                currentProfile.first_name = firstName
                currentProfile.last_name = lastName
                currentProfile.bio = bio.isEmpty ? nil : bio
                currentProfile.location = location.isEmpty ? nil : location
                currentProfile.instagram = instagram.isEmpty ? nil : instagram
                currentProfile.tiktok = tiktok.isEmpty ? nil : tiktok
                currentProfile.avatar = avatar
                
                profile = currentProfile
                if let profilePicture = profile?.avatar {
                    self.avatar = profilePicture
                }
            }
            
            successMessage = "Profile updated successfully"
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Failed to update profile: \(error.localizedDescription)")
        }
    }
 
    func get_user_follow_data(p_user_id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.rpc("get_user_follow_data", params: ["p_user_id": p_user_id]).execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Adjust if your dates are in a different format
            let followData = try decoder.decode(FollowData.self, from: response.data)
            self.followers = followData.followers
            self.following = followData.following
            
            print("followers: \(self.followers)")
            print("following: \(self.following)")
        } catch {
            if isCancellationError(error) {
                return
            }
            print("FULL DECODING ERROR: \(error)")
            showError("Failed to load follow data")
            print("error: Failed to load follow data: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func get_friend_follow_data(p_user_id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.rpc("get_user_follow_data", params: ["p_user_id": p_user_id]).execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Adjust if your dates are in a different format
            let followData = try decoder.decode(FollowData.self, from: response.data)
            self.friendsFollowers = followData.followers
            self.friendsFollowing = followData.following
            
//            print("your friend's followers are \(friendsFollowers)")
//            isFollowing = friendsFollowing.contains {
//                $0.user_id == p_user_id
//            }
            print("is user following?: \(isFollowing)")
        } catch {
            if isCancellationError(error) {
                return
            }
            print("FULL DECODING ERROR: \(error)")
            showError("Failed to load follow data")
            print("error: Failed to load follow data: \(error.localizedDescription)")
        }
        isLoading = false
    }
 
    func get_user_top_dishes(p_user_id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.rpc("get_user_top_dishes", params: ["p_user_id": p_user_id]).execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Adjust if your dates are in a different format
            self.topDishes = try decoder.decode([Dish].self, from: response.data)
        } catch {
            if isCancellationError(error) {
                return
            }
            print("FULL DECODING ERROR: \(error)")
            showError("Failed to load top dishes")
            print("error: Failed to load top dishes: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func get_friend_top_dishes(p_user_id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase.rpc("get_user_top_dishes", params: ["p_user_id": p_user_id]).execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Adjust if your dates are in a different format
            self.friendTopDishes = try decoder.decode([Dish].self, from: response.data)
        } catch {
            if isCancellationError(error) {
                return
            }
            print("FULL DECODING ERROR: \(error)")
            showError("Failed to load top dishes")
            print("error: Failed to load top dishes: \(error.localizedDescription)")
        }
        isLoading = false
    }
    func followSpecific(otherUserId: String) async {
            guard let currentUserId = currentSession?.user.id.uuidString else { return }
        isFollowLoading = true
            do {
                try await service.followUser(userId: currentUserId, otherUserId: otherUserId)
                await get_user_follow_data(p_user_id: currentUserId)
                await loadFriendsProfile(userId: otherUserId)
                isFollowLoading = false
            } catch {
                if isCancellationError(error) {
                    return
                }
                showError("Follow failed: \(error.localizedDescription)")
                print("error: \(error.localizedDescription)")
                isFollowLoading = false
            }
        }
    
    func unfollowSpecific(otherUserId: String) async {
        guard let currentUserId = currentSession?.user.id.uuidString else { return }
        isFollowLoading = true
        print(currentUserId)
        do {
            try await service.unfollowUser(userId: currentUserId, otherUserId: otherUserId)
            // Update local list
            following.removeAll { $0.user_id == otherUserId }
            isFollowLoading = false
        } catch {
            if isCancellationError(error) {
                return
            }
            showError("Unfollow failed: \(error.localizedDescription)")
            print("error: \(error.localizedDescription)")
            isFollowLoading = false
        }
    }
    
    func getUserVisitedRestaurants(p_user_id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase
                .rpc("get_user_visited_restaurants", params: ["p_user_id": p_user_id])
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            self.userRestaurants = try decoder.decode([VisitedRestaurant].self, from: response.data)
            syncVisitedRestaurants()
//            print("✅ Visited restaurants loaded: \(visitedRestaurants.count) items")
            
        } catch {
            if isCancellationError(error) {
                return
            }
            print("❌ FULL DECODING ERROR (get_user_visited_restaurants): \(error)")
            showError("Failed to load visited restaurants")
            print("error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func getFriendVisitedRestaurants(p_user_id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase
                .rpc("get_user_visited_restaurants", params: ["p_user_id": p_user_id])
                .execute()
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            self.friendRestaurants = try decoder.decode([VisitedRestaurant].self, from: response.data)
            
            syncFriendVisitedRestaurants()
//            print("✅ Visited restaurants loaded: \(visitedRestaurants.count) items")
            
        } catch {
            if isCancellationError(error) {
                return
            }
            print("❌ FULL DECODING ERROR (get_user_visited_restaurants): \(error)")
            showError("Failed to load visited restaurants")
            print("error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    private func syncFriendVisitedRestaurants() {
        friendVisitedRestaurants = friendRestaurants.compactMap { $0.restaurant }
    }
    private func syncVisitedRestaurants() {
        visitedRestaurants = userRestaurants.compactMap { $0.restaurant }
    }
    
    func deleteAccount() async {
            isDeleting = true
            defer { isDeleting = false }

            do {
                try await supabase.rpc("delete_user_account").execute()
                try await supabase.auth.signOut()
                // navigate back to auth/onboarding here
            } catch {
                showError("Failed to delete user")
                print(error.localizedDescription)
            }
        }
    

}



