//
//  FoodieCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/05/2026.
//

import SwiftUI

struct FoodieCardView: View {
    let foodie: UserProfile
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    @StateObject private var profileVM = ProfileViewModel(userId: "")
    
    @State private var isFollowing: Bool = false
    @State private var isLoading: Bool = false
    @Binding var showTabButtons: Bool
    var body: some View {
        ZStack{
            VStack(spacing: 17){
                HStack{
                    AsyncImage(url: URL(string: foodie.avatar ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.gray)
                                    .opacity(0.3)
                                
                                Image(systemName: "person")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 30))
                                    
                            }
                        }
                    }
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 67, height: 67)
                    
                    VStack(alignment: .leading){
                        Text(("\(foodie.first_name) \(foodie.last_name)").capitalized)
                            .foregroundStyle(.black)
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        HStack {
                            Text("@\(foodie.username)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .opacity(0.5)
                            
                            Divider()
                                .frame(height: 20)
                            Text("\(foodie.followers_count ?? 0) followers")
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .opacity(0.5)
                        }
                        
                        
                    }
                    
                    Spacer()
                    
                    if foodie.user_id.lowercased() != viewModel.currentUser?.id.uuidString.lowercased() {
                        Button {
                            Haptics.slide()
                            
                            guard !isLoading else { return }
                            
                            let previous = isFollowing
                            isFollowing.toggle()
                            isLoading = true
                            
                            Task {
                                do {
                                    if previous {
                                        await profileVM.unfollowSpecific(otherUserId: foodie.user_id)
                                        await  leaderboardVM.loadFor(option: "Foodies")
                                        await searchVM.searchFoodies(term: searchVM.searchText)
                                    } else {
                                        await profileVM.followSpecific(otherUserId: foodie.user_id)
                                        await  leaderboardVM.loadFor(option: "Foodies")
                                        await searchVM.searchFoodies(term: searchVM.searchText)
                                    }
                                } catch {
                                    // rollback
                                    isFollowing = previous
                                }
                                
                                isLoading = false
                            }
                            
                        } label: {
                            ZStack {
                                Text(isFollowing ? "Unfollow" : "Follow")
                                    .foregroundStyle(.clear)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(isFollowing ? .black : .white)
                                } else {
                                    Text(isFollowing ? "Unfollow" : "Follow")
                                        .foregroundStyle(isFollowing ? .black : .white)
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(height: 34)
                            .frame(minWidth: 70)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(isFollowing ? Color.white : Color.tastysRed)
                            )
                        }
                        .disabled(isLoading)
                        .animation(.easeInOut(duration: 0.2), value: isFollowing)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                    }

                 }
                .padding([.horizontal, .top], 20)
                
                VStack(alignment: .leading){
                    
                    Text("Top Dishes")
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 11){
                            ForEach(foodie.topDishes ?? [], id: \.dishId) { dish in
                                NavigationLink {
                                    FoodDetailView(dishId: dish.dishId, showTabButtons: $showTabButtons)
                                        .environmentObject(viewModel)
                                } label: {
                                    let dishModel = Dish(
                                        id: UUID(uuidString: dish.dishId) ?? UUID(),
                                        name: dish.dishName,
                                        description: nil,
                                        categories: nil,
                                        createdAt: nil,
                                        updatedAt: nil,
                                        image: dish.dishImage,
                                        restaurantId: nil,
                                        restaurantName: dish.restaurantName ?? "",
                                        avgRating: nil,
                                        ratingCount: nil,
                                        rating: nil,
                                        sectionType: nil,
                                        tags: nil,
                                        diets: nil
                                    )
                                    
                                    let restaurantModel = RestaurantDetails(
                                        id: UUID(),
                                        name: dish.restaurantName ?? "",
                                        image: nil,
                                        description: nil,
                                        address: nil,
                                        website: nil,
                                        telephone: nil,
                                        createdAt: nil,
                                        updatedAt: nil,
                                        rank: nil,
                                        rating: nil,
                                        avgRating: nil,
                                        totalRating: nil,
                                        isBookmarked: false,
                                        distanceKm: nil,
                                        topDishes: nil
                                    )
                                    DishCardView(
                                        dish: dishModel,
                                        restaurant: restaurantModel,
                                        rating: Int(dish.rating),
                                        size: 150
                                    )
                                    .environmentObject(viewModel)
                                    //                                VStack{
                                    //                                    AsyncImage(url: URL(string: dish.dishImage ?? "")) { phase in
                                    //                                        if let image = phase.image {
                                    //                                            image.resizable()
                                    //                                        } else {
                                    //                                            ZStack {
                                    //                                                Color.ashTastys
                                    //                                                
                                    //                                            }
                                    //                                        }
                                    //                                    }
                                    //                                    .scaledToFill()
                                    //                                    .frame(width: 85, height: 49)
                                    //                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    //                                    .clipped()
                                    //                                    
                                    //                                    Text(dish.dishName)
                                    //                                        .foregroundStyle(.black)
                                    //                                        .font(.system(size: 12))
                                    //                                        .fontWeight(.regular)
                                    //                                        .lineLimit(3)
                                    //                                    
                                    //                                }
                                }
                                
                            }
                            
                            //                        if foodie.otherHighRatedCount != nil && foodie.otherHighRatedCount != 0 {
                            //                            ZStack{
                            //                                Circle()
                            //                                    .foregroundStyle(.tastysRed)
                            //                                    .opacity(0.11)
                            //                                
                            //                                Circle()
                            //                                    .stroke(lineWidth: 1)
                            //                                    .foregroundStyle(.tastysRed)
                            //                                    .opacity(0.14)
                            //                                
                            //                                
                            //                                Text("+\(foodie.otherHighRatedCount ?? 0)")
                            //                                    .foregroundStyle(.tastysRed)
                            //                                    .font(.system(size: 15))
                            //                                    .fontWeight(.semibold)
                            //                                
                            //                            }
                            //                            .frame(width: 49, height: 49)
                            //                        } else {
                            //                            Spacer()
                            //                        }
                        }
                    }
                    
                    
                }
                .padding(.vertical, 12)
//                .padding(.top, 8)
                .padding(.horizontal, 15)
                .background{
                    RoundedRectangle(cornerRadius: 14)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(1)
        .background{
            RoundedRectangle(cornerRadius: 18)
                .foregroundStyle(.fakeWhite)
        }
        .onAppear {
            isFollowing = foodie.isFollowing ?? false
            print(viewModel.currentUser?.id.uuidString ?? "nothing for current user")
        }
    }
}

#Preview {
    FoodieCardView(foodie: UserProfile(idField: "", user_id: "", username: "", email: "", phone: "", email_verified: true, phone_verified: true, first_name: "", last_name: "", address: "", location: "", tiktok: "", instagram: "", avatar: "", bio: "", created_at: Date(), followers_count: 10, following_count: nil, average_rating: 0.0, community_score: nil, food_profile: "", totalDishesRated: 1, totalRestaurantsVisited: 1, topDishes: [], otherHighRatedCount: 0, isFollowing: true), showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
        .environmentObject(LeaderboardViewModel())
        .environmentObject(SearchViewModel())
    
}



struct FoodieCardSkeletonView: View {
    var body: some View {
        VStack(spacing: 15) {
            
            // MARK: - Top Section
            HStack {
                
                // Avatar skeleton
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 71, height: 67)
                    .shimmering()
                
                VStack(alignment: .leading, spacing: 9) {
                    
                    // Name
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 139, height: 16)
                        .shimmering()
                    
                    // Username + followers
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 89, height: 14)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 14)
                    }
                    .shimmering()
                }
                
                Spacer()
                
                // Follow button skeleton
                RoundedRectangle(cornerRadius: 19)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 34)
                    .shimmering()
            }
            .padding([.horizontal, .top], 20)
            
            // MARK: - Top Dishes Label
            VStack(alignment: .leading, spacing: 12) {
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 91, height: 15)
                    .shimmering()
                
                // MARK: - Dishes Row
                HStack(spacing: 14) {
                    
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(spacing: 7) {
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 85, height: 49)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 10)
                        }
                        .shimmering()
                    }
                    
                    // "+ count" circle placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 47, height: 49)
                        .shimmering()
                    
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.08))
        )
    }
}
