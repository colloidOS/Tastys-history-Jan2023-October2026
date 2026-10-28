//
//  FriendProfileView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 23/12/2025.
//

import SwiftUI

struct FriendProfileView: View {
    @State private var selectedFeed = 1
    @State private var showComment = false
    @Environment(\.dismiss) var dismiss
//    @State private var isFollowing = false
    @State private var showRatingCard = false
    @State private var isLoading = true
    @State private var lastOffset: CGFloat = 0
    @EnvironmentObject private var homeVM: HomeViewModel
    @StateObject private var vm: ProfileViewModel
    var friendsUserId: String
    @Binding var showTabButtons: Bool
    
    init(friendsUserId: String, showTabButtons: Binding<Bool>) {
        // Wait for the session first
        if let userId = supabase.auth.currentSession?.user.id.uuidString {
            _vm = StateObject(wrappedValue: ProfileViewModel(userId: userId))
            self.friendsUserId = friendsUserId
            self._showTabButtons = showTabButtons
        } else {
            // Fallback – will show an error or login prompt
            _vm = StateObject(wrappedValue: ProfileViewModel(userId: "placeholder"))
            self.friendsUserId = friendsUserId
            self._showTabButtons = showTabButtons
        }
        
        
    }
       // Received from MainTabView
    
    var body: some View {
        
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if let err = vm.errorMessage {
                PopUpView(error: err)
            }
            VStack {
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20){
                        
                        ZStack {
                            HStack(spacing: 20) {
                                ZStack{
                                    if let profilePicture = vm.friendsProfile?.avatar {
                                        Circle()
                                            .foregroundStyle(.rectTastys)
                                            .frame(width: 109, height: 109)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        Circle()
                                            .stroke(lineWidth: 3)
                                            .foregroundStyle(.white)
                                            .frame(width: 109, height: 109)
                                        
                                        AsyncImage(url: URL(string: profilePicture)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 108, height: 108)
                                        } placeholder: {
                                            Circle()
                                                .foregroundStyle(.rectTastys)
                                                .frame(width: 109, height: 109)
                                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                            Circle()
                                                .stroke(lineWidth: 3)
                                                .foregroundStyle(.white)
                                                .frame(width: 109, height: 109)
                                            
                                            Image("plateUsername")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 38.47, height: 38.47)
                                        }
                                        .frame(height: 109)
                                        .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .foregroundStyle(.rectTastys)
                                            .frame(width: 109, height: 109)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        Circle()
                                            .stroke(lineWidth: 3)
                                            .foregroundStyle(.white)
                                            .frame(width: 109, height: 109)
                                        
                                        Image("plateUsername")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40.47, height: 38.47)
                                    }
                                    
                                }
                                //                        .padding(.trailing, 20)
                                .overlay(alignment: .topTrailing){
                                    ZStack {
                                        //                                    Image("pickyImage")
                                        HStack(spacing: 3){
                                            if vm.friendsProfile?.food_profile == "\"\"" {
                                                Image("Picky")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 22, height: 22)
                                                
                                                
                                                Text("picky")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 14))
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                                
                                            } else {
                                                Image(vm.friendsProfile?.food_profile ?? "Picky")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 22, height: 22)
                                                
                                                
                                                Text(vm.friendsProfile?.food_profile ?? "Picky")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 14))
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                            
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background{
                                            
                                            colorForFoodProfile(vm.friendsProfile?.food_profile ?? "Picky")
                                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                        }
                                        .padding(.vertical, 8)
                                        //                                    .padding(.horizontal, 10)
                                    }
                                    .offset(x: 30, y: -5)
                                }
                                
                                VStack(alignment: .leading, spacing: 6){
                                    if isLoading {
                                        PlaceholderView(width: 80, height: 24, cornerRadius: 4)
                                        //                                            .padding(.trailing, 20)
                                    } else {
                                        Text("@\(vm.friendsProfile?.username ?? "unknown")")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20))
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                            .padding(.top, 10)
                                        //                                            .padding(.trailing, 20)
                                    }
                                    
                                    if isLoading {
                                        PlaceholderView(width: 120, height: 20, cornerRadius: 4)
                                        //                                            .padding(.trailing, 20)
                                    } else {
                                        Text(vm.friendsProfile?.bio ?? "")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .lineLimit(3)
                                            .lineSpacing(4)
                                            
                                        //                                            .padding(.trailing, 20)
                                            .opacity(0.4)
                                    }
                                }
                                .padding(.top, 30)
                                
                                Spacer()
                                
                                
                            }
                            .padding(.leading, 10)
                            
                            HStack{
                                Spacer()
                                
                                VStack {
                                    if friendsUserId.lowercased() != homeVM.currentUser?.id.uuidString.lowercased() {
                                        Button {
                                            Haptics.slide()
                                            
                                            Task {
                                                vm.isFollowLoading = true
                                                
                                                let wasFollowing = vm.isFollowing
                                                
                                                // optimistic update
                                                vm.isFollowing.toggle()
                                                
                                                do {
                                                    if wasFollowing {
                                                        await vm.unfollowSpecific(otherUserId: friendsUserId)
                                                    } else {
                                                        await vm.followSpecific(otherUserId: friendsUserId)
                                                    }
                                                } catch {
                                                    // rollback on failure
                                                    vm.isFollowing = wasFollowing
                                                }
                                                
                                                vm.isFollowLoading = false
                                            }
                                            
                                        } label: {
                                            ZStack {
                                                // keeps button width stable
                                                Text(vm.isFollowing ? "Unfollow" : "Follow")
                                                    .foregroundStyle(.clear)
                                                    .font(.system(size: 14))
                                                    .fontWeight(.semibold)
                                                
                                                if vm.isFollowLoading {
                                                    ProgressView()
                                                        .scaleEffect(0.8)
                                                        .tint(vm.isFollowing ? .black : .white)
                                                } else {
                                                    Text(vm.isFollowing ? "Unfollow" : "Follow")
                                                        .foregroundStyle(vm.isFollowing ? .black : .white)
                                                        .font(.system(size: 14))
                                                        .fontWeight(.semibold)
                                                }
                                            }
                                            .frame(height: 34)
                                            .frame(minWidth: 95) // prevents resizing
                                            .padding(.horizontal, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(vm.isFollowing ? Color.ashTastys : Color.tastysRed)
                                            )
                                            .animation(.easeInOut(duration: 0.2), value: vm.isFollowLoading)
                                            .animation(.easeInOut(duration: 0.2), value: vm.isFollowing)
                                        }
                                        .disabled(vm.isFollowLoading)
                                    }

                                    Spacer()
                                }
                                
                                
                            }
                            
                            
                            
                        }
                        
                        
//                        .overlay(alignment: .bottomTrailing) {
                            
////                            .buttonStyle(.plain)
//                        }
                        
                        
                        
//                        if isLoading {
//                            PlaceholderView(width: 120, height: 24, cornerRadius: 4)
//                                .padding(.trailing, 20)
//                        } else {
//                            Text("@\(vm.friendsProfile?.username ?? "—")")
//                                .foregroundStyle(.black)
//                                .font(.system(size: 20))
//                                .fontWeight(.bold)
//                                .padding(.trailing, 20)
//                        }
//                            .padding(.trailing, 20)
                        
//                        HStack {
////                            NavigationLink{
////                                FollowingsView()
////                            } label: {
//                            HStack(spacing: 5){
//                                Image("personList")
//                                
//                                if isLoading {
//                                    PlaceholderView(width: 30, height: 12, cornerRadius: 6)
//                                } else {
//                                    Text("\(vm.friendsProfile?.following_count ?? 0)")
//                                        .foregroundStyle(.black)
//                                        .font(.system(size: 11))
//                                        .fontWeight(.bold)
//                                }
//                            }
////                            }
//                            
////                            NavigationLink{
////                                FollowersView()
////                            } label: {
//                            HStack(spacing: 7){
//                                Image("personLove")
//                                
//                                if isLoading {
//                                    PlaceholderView(width: 30, height: 12, cornerRadius: 4)
//                                } else {
//                                    Text("\(vm.friendsProfile?.followers_count ?? 0)")
//                                        .foregroundStyle(.black)
//                                        .font(.system(size: 11))
//                                        .fontWeight(.bold)
//                                }
//                            }
////                            }
//                        }
//                        .padding(.trailing, 20)
                        
                        VStack(spacing: 15){
                            HStack{
                                Spacer()
                                NavigationLink{
                                    RatedDishesView(dishes: $vm.friendTopDishes, showTabButtons: $showTabButtons)
                                        .environmentObject(homeVM)
                                } label: {
                                    VStack(spacing: 10){
                                        if isLoading {
                                            PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                            
                                        } else {
                                            Text("\(vm.friendsProfile?.totalDishesRated ?? 0)")
                                                .foregroundStyle(.tastysRed)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                        }
                                        
                                        Text("Dishes Rated")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .fontWeight(.medium)
                                            .opacity(0.5)
                                    }
                                }
                                Spacer()
                                
                                NavigationLink{
                                    RestaurantVisitedView(restaurants: vm.friendVisitedRestaurants, userId: vm.userId, showTabButtons: $showTabButtons)
                                        .environmentObject(vm)
                                        .environmentObject(homeVM)
                                } label: {
                                    VStack(spacing: 10){
                                        if isLoading {
                                            PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                        } else {
                                            Text("\(vm.friendsProfile?.totalRestaurantsVisited ?? 0)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 17))
                                                .fontWeight(.medium)
                                        }
                                        
                                        Text("Restaurants")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .fontWeight(.medium)
                                            .opacity(0.5)
                                    }
                                }
                                Spacer()
                                
//                                NavigationLink{
//                                    FollowersView(viewModel: vm, showTabButtons: $showTabButtons)
//                                } label: {
                                    VStack(spacing: 10){
                                        if isLoading {
                                            PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                        } else {
                                            Text("\(vm.friendsProfile?.followers_count ?? 0)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                        }
                                        
                                        Text("Followers")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .fontWeight(.medium)
                                            .opacity(0.5)
                                    }
//                                }
                                Spacer()
                                
//                                NavigationLink{
//                                    FollowingsView(viewModel: vm, showTabButtons: $showTabButtons)
//                                } label: {
                                    VStack(spacing: 10){
                                        if isLoading {
                                            PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                        } else {
                                            Text("\(vm.friendsProfile?.following_count ?? 0)")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                        }
                                        
                                        Text("Following")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .fontWeight(.medium)
                                            .opacity(0.5)
                                    }
//                                }
                                Spacer()
                                
                            }
                            
                            VStack{
                                HStack{
                                    Image("starIcon")
                                    
                                    Text("\(vm.friendsProfile?.first_name ?? "friend")'s taste at a glance")
                                        .foregroundStyle(.black)
                                        .opacity(0.3)
                                        .font(.system(size: 13))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 10)
                                
                                HStack(alignment: .top){
//                                        Spacer()
                                    
                                    VStack(spacing: 12){
                                        Text("Average Rating")
                                            .foregroundStyle(.black)
                                            .opacity(0.5)
                                            .font(.system(size: 10))
                                            .fontWeight(.medium)
                                        
                                        if isLoading {
                                            PlaceholderView(width: 60, height: 16, cornerRadius: 4)
                                                .padding(.top, 5)
                                        } else {
                                            Text("\(Int(vm.friendsProfile?.average_rating ?? 50))%❤️")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 10))
                                                .fontWeight(.semibold)
                                                .padding(.top, 5)
                                        // .padding(.bottom, 5)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Rectangle()
                                        .foregroundStyle(.gray.opacity(0.2))
                                        .frame(width: 1, height: 80)
                                    
                                    Spacer()
                                    
                                    if let friendTopDish = vm.friendTopDishes.first {
                                        NavigationLink {
                                            FoodDetailView(dishId: friendTopDish.id.uuidString, showTabButtons: $showTabButtons)
                                                .environmentObject(homeVM)
                                        } label: {
                                            VStack(spacing: 12){
                                                Text("Top Rated Dish")
                                                    .foregroundStyle(.black)
                                                    .opacity(0.5)
                                                    .font(.system(size: 12))
                                                    .fontWeight(.medium)
                                                
                                                AsyncImage(url: URL(string: friendTopDish.image ?? "")) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Image("logoImage")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .opacity(0.6)
                                                }
                                                .frame(width: 35, height: 35)
                                                .clipShape(Circle())
                                                
                                                Text(friendTopDish.name)
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 12))
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                                    .opacity(0.5)
                                                
                                                
                                            }
                                        }
                                    } else {
                                        VStack(spacing: 12) {
                                            Text("Top Rated Dish")
                                                .foregroundStyle(.black)
                                                .opacity(0.5)
                                                .font(.system(size: 12))
                                                .fontWeight(.medium)

                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(0.6)
                                                .frame(width: 35, height: 35)
                                                .clipShape(Circle())

                                            Text("No rated dish yet")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 12))
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                                .opacity(0.5)
                                        }
                                    }
                                    Spacer()
                                    
                                    Rectangle()
                                        .foregroundStyle(.gray.opacity(0.2))
                                        .frame(width: 1, height: 80)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 12){
                                        Text("Favorite cuisine")
                                            .foregroundStyle(.black)
                                            .opacity(0.5)
                                            .font(.system(size: 12))
                                            .fontWeight(.medium)
                                        
                                    Image("Italian")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                        
                                        
                                        Text("Italian")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 12))
                                            .fontWeight(.medium)
                                        
                                    }
                                    
                                    
//                                        Spacer()
                                    
                                }
                            }
                            .padding(15)
                            .background{
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(.white)
                            }
                            
                        }
                        .padding(.top, 25)
                        .padding([.horizontal, .bottom], 4)
                        .background{
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.fakeWhite)
                        }
                        
                        VStack{
                            
                            HStack{
                                Text("\(vm.friendsProfile?.first_name ?? "friend")'s Top rated dishes")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                            
                            
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20){
                                        if vm.isLoading && vm.friendTopDishes.isEmpty {
                                            ForEach(0..<3) { _ in
                                                DishCardSkeletonView()
                                            }
                                        } else {
                                            if !vm.friendTopDishes.isEmpty {
                                                ForEach(vm.friendTopDishes) { dish in
                                                    NavigationLink {
                                                        FoodDetailView(dishId: dish.id.uuidString, showTabButtons: $showTabButtons)
                                                            .environmentObject(homeVM)
                                                    } label: {
                                                        DishCardView(
                                                            dish: dish,
                                                            restaurant: RestaurantDetails(
                                                                id: dish.restaurantId ?? UUID(),
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
                                                            ),
                                                            rating: Int(dish.rating ?? 0)
                                                        )
                                                    }
                                                }
                                            } else {
                                                HStack {
                                                    Spacer()
                                                    Text("No rated dishes yet🤧")
                                                        .foregroundStyle(.gray)
                                                        .font(.system(size: 15))
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                    }
                            }
                        }
                        
                        
                        VStack{
                            HStack{
                                Text("\(vm.friendsProfile?.first_name ?? "friend")'s Recent reviews")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                            
                           
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 5){
                                    if vm.isLoading && vm.friendPosts.isEmpty {
                                        ForEach(0..<3) { _ in
                                            PlainFeedCardSkeletonView()
                                        }
                                    } else {
                                        if !vm.friendPosts.isEmpty {
                                            
                                            ForEach(vm.friendPosts
//                                                .filter {
//                                                guard let comment = $0.post.comment else { return false }
//                                                return !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//                                            }
                                            ) { post in
                                                NavigationLink{
                                                    FoodDetailView(dishId: post.dishes?.first?.dish.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                                        .environmentObject(homeVM)
                                                } label:{
                                                    NewFeedCardView(post: post, showTabButtons: $showTabButtons)
                                                        .environmentObject(homeVM)
                                                }
//                                                    .offset(x: -10)
                                            }
                                            
                                        } else {
                                            HStack {
                                                Spacer()
                                                Text("No post yet🤧")
                                                    .foregroundStyle(.gray)
                                                    .font(.system(size: 15))
                                                Spacer()
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        .padding(.bottom, 20)
                        
                        
                        
                        
                        
//                        HStack(alignment: .top){
//                            VStack(spacing: 8){
//                                Text("Average Rating")
//                                    .foregroundStyle(.black)
//                                    .opacity(0.5)
//                                    .font(.system(size: 13))
//                                    .fontWeight(.medium)
//                                
//                                if isLoading {
//                                    PlaceholderView(width: 60, height: 16, cornerRadius: 4)
//                                        .padding(.top, 5)
//                                } else {
//                                    Text("\(Int(vm.friendsProfile?.average_rating ?? 0))%❤️")
//                                        .foregroundStyle(.black)
//                                        .font(.system(size: 14))
//                                        .fontWeight(.semibold)
//                                        .padding(.top, 5)
//                                // .padding(.bottom, 5)
//                                }
//                            }
//                            
//                            VStack(spacing: 12){
//                                Text("Community Score")
//                                    .foregroundStyle(.black)
//                                    .opacity(0.5)
//                                    .font(.system(size: 13))
//                                    .fontWeight(.medium)
//                                
//                                if isLoading {
//                                    PlaceholderView(width: 40, height: 20, cornerRadius: 10)
//                                } else {
//                                    ReuseableScoreBorderView(score: Int(vm.friendsProfile?.community_score ?? 0))
//                                }
//                            }
//                        }
//                        .padding(.trailing, 20)
                        
//                        HStack(spacing: 10){
//                            NavigationLink {
//                                FoodDetailView(dishId: vm.friendTopDishes.first?.id.uuidString ?? "", showTabButtons: $showTabButtons)
//                                    .environmentObject(homeVM)
//                            } label: {
//                                HStack(alignment: .bottom){
//                                    VStack(alignment: .leading, spacing: 9){
//                                        Text("Top rated dish")
//                                            .foregroundStyle(.black)
//                                            .opacity(0.5)
//                                            .font(.system(size: 13))
//                                            .fontWeight(.medium)
//                                        Spacer()
//                                        Text(vm.friendTopDishes.first?.name ?? "")
//                                            .foregroundStyle(.black)
//                                            .font(.system(size: 15))
//                                            .fontWeight(.semibold)
//                                            .lineLimit(2)
//                                    }
//                                    Spacer()
//                                    
//                                    AsyncImage(url: URL(string: vm.friendTopDishes.first?.image ?? "")) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                    } placeholder: {
//                                        Color.gray
//                                    }
//                                    .frame(width: 44, height: 44)
//                                    .clipShape(Circle())
//                                    
//                                }
//                                .padding(12)
//                                .background{
//                                    RoundedRectangle(cornerRadius: 16)
//                                        .stroke(lineWidth: 2)
//                                        .foregroundStyle(.strokedWhite)
//                                        .frame(height: 100)
//                                }
//                                .frame(height: 100)
//                            }
//                            
//                            HStack(alignment: .bottom){
//                                VStack(alignment: .leading, spacing: 9){
//                                    Text("Most eaten cuisine")
//                                        .foregroundStyle(.black)
//                                        .opacity(0.5)
//                                        .font(.system(size: 12))
//                                        .fontWeight(.medium)
//                                    Spacer()
//                                    Text("Italian")
//                                        .foregroundStyle(.black)
//                                        .font(.system(size: 15))
//                                        .fontWeight(.semibold)
//                                }
//                                Spacer()
//                                
//                                Image("Italian")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(height: 44)
//                                    .clipShape(Circle())
//                                
//                            }
//                            .padding(13)
//                            .background{
//                                RoundedRectangle(cornerRadius: 16)
//                                    .stroke(lineWidth: 2)
//                                    .foregroundStyle(.strokedWhite)
//                                    .frame(height: 100)
//                            }
//                            .frame(height: 100)
//                            
//                        }
//                        .padding(.horizontal, 15)
                        
                        
                        
                        
                        
//                        HStack{
//                            Button{
//                                Haptics.slide()
//                                selectedFeed = 1
//                            } label: {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 25.0)
//                                        .foregroundStyle(selectedFeed == 1 ? .tastysRed : .clear)
//                                        .frame(height: 32)
//                                    Text("User posts")
//                                        .foregroundStyle(selectedFeed == 1 ? .white : .black)
//                                    .font(.system(size: 12))
//                                    .fontWeight(.medium)
//                                }
//                                
//                            }
//                            .buttonStyle(.plain)
//                            .padding(.trailing, 20)
//                            
//                            Button{
//                                Haptics.slide()
//                                selectedFeed = 2
//                            } label: {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 25.0)
//                                        .foregroundStyle(selectedFeed == 2 ? .tastysRed : .clear)
//                                        .frame(height: 32)
//                                    Text("Top rated dishes")
//                                        .foregroundStyle(selectedFeed == 2 ? .white : .black)
//                                    .font(.system(size: 12))
//                                    .fontWeight(.medium)
//                                }
//                                
//                            }
//                            .buttonStyle(.plain)
//                        }
//                        .padding(.vertical, 2)
//                        .background{
//                            Color.white
//                                .clipShape(RoundedRectangle(cornerRadius: 25))
//                                .shadow(color: Color.black.opacity(0.1), radius: 2)
//                        }
//                        .padding(.horizontal, 15)
//                        if selectedFeed == 1 {
//                            if  !vm.isLoading || !vm.friendPosts.isEmpty {
//                                if vm.friendPosts.isEmpty {
//                                    Text("No posts yet🤧")
//                                        .foregroundStyle(.white)
//                                        .font(.system(size: 15))
//                                        
//                                } else {
//                                    ForEach(vm.friendPosts) { post in
//                                        FeedCardView(post: post, showTabButtons: $showTabButtons)
//                                            .environmentObject(homeVM)
//                                            .offset(x: -10)
//                                        
//                                    }
//                                }
//                            } else {
//                                ForEach(0..<3) {_ in
//                                FeedCardSkeletonView()
//                                }
//                            }
//                        } else if selectedFeed == 2 {
//                            if !vm.isLoading {
//                                if vm.friendTopDishes.isEmpty {
//                                    Text("No rated dishes yet🤧")
//                                        .foregroundStyle(.gray)
//                                        .font(.system(size: 15))
//                                } else {
//                                    RatedDishesView(dishes: $vm.friendTopDishes, showTabButtons: $showTabButtons)
//                                        .environmentObject(homeVM)
//                                }
//                            } else {
////                                ForEach(0..<3) {_ in
////                                   DishCardSkeletonView()
////                                }
//                            }
//                        }
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                        }
                        .frame(height: 0)
                    }
                    
                }
                .refreshable {
                    Task{
                        await vm.loadFriendsProfile(userId: friendsUserId)
                        await vm.loadFriendPosts(userId: friendsUserId)

                        await vm.get_friend_follow_data(p_user_id: vm.userId)
                        vm.isFollowing = vm.friendsFollowing.contains {
                            $0.user_id.lowercased() == friendsUserId.lowercased()
                        }
                        await vm.get_friend_top_dishes(p_user_id: friendsUserId)
                        isLoading = false
                    }
                }
            }
            .padding([.vertical, .horizontal], 15)
            
            .background{
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .ignoresSafeArea()
            }
            .blur(radius: showRatingCard ? 7 : 0)
            .onTapGesture {
                if showRatingCard {
                    showRatingCard = false
                }
                
            }
            
            
            
            if showRatingCard {
                VStack{
                    
                    HStack {
                        Spacer()
                        RatingPopUpView(isShowing: $showRatingCard)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            
            
            
        }
        .onAppear{
            print("friend's ID: \(friendsUserId)")
            Haptics.prepare()
        }
        
        .task {
            await vm.loadFriendsProfile(userId: friendsUserId)
            await vm.loadFriendPosts(userId: friendsUserId)
                print(vm.friendPosts)
            await vm.get_friend_follow_data(p_user_id: vm.userId)
            await vm.get_user_follow_data(p_user_id: vm.userId)
            
            print("friend id: \(friendsUserId)")
            print("your id: \(vm.userId)")
            
            vm.isFollowing = vm.friendsFollowing.contains {
                $0.user_id.lowercased() == friendsUserId.lowercased()
            }
            await vm.get_friend_top_dishes(p_user_id: friendsUserId)
            print(vm.isFollowing)
            isLoading = false
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { currentOffset in
            let directionIsUp = currentOffset > lastOffset
            
            if abs(currentOffset - lastOffset) > 5 {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabButtons = directionIsUp
                }
            }
            
            lastOffset = currentOffset
        }
        
//        .navigationBarBackButtonHidden()
        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button{
//                    dismiss()
//                } label: {
//                    Image("backButtonIcon")
//                        .renderingMode(.template)
//                        .foregroundStyle(.black)
////                        .padding()
////                        .clipShape(Circle())
////                    .foregroundStyle(.white)
//                }
//            }
            
            
            ToolbarItem(placement: .principal) {
                Text("User profile")
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
            }
            
        }
//        .enableSwipeBack()
    }
    func colorForFoodProfile(_ name: String) -> Color {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return .picky
        }
        
        // Or use predefined colors for specific names
        switch trimmed {
        case "Picky":
            return .picky
        case "Veggies":
            return .veggies
        case "Adventorous":
            return .adventorous
        case "Spicy":
            return .spicy
        case "Big Eater":
            return .bigEater
        case "Light Eater":
            return .lightEater
        default:
            return .picky
        }
    }
}

#Preview {
    FriendProfileView(friendsUserId: "", showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
//        .environmentObject(ProfileViewModel)
}
