//
//  ProfileView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/12/2025.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userId") private var userId = ""
    @StateObject private var vm: ProfileViewModel
    @State private var selectedFeed = 1
    @State private var showComment = false
    @State private var isMenuOpen = false
    @State private var showRatingCard = false
    @State private var showingShareSheet = false
    @State private var shareData: ShareData?
    @State private var isLoading = true
    @Binding var showTabButtons: Bool
    @EnvironmentObject private var homeVM: HomeViewModel
    @AppStorage("avatar") private var avatar = ""
    @StateObject private var foodVM = FoodViewModel()
    @State private var lastOffset: CGFloat = 0
    @AppStorage("selectedDish") private var faveDish = "Italian"
    @Environment(\.openURL) private var openURL
    @State private var showDeleteConfirmation = false
    init(showTabButtons: Binding<Bool>) {
        // Wait for the session first
        if let userId = supabase.auth.currentSession?.user.id.uuidString {
            _vm = StateObject(wrappedValue: ProfileViewModel(userId: userId))
            _showTabButtons = showTabButtons
        } else {
            // Fallback – will show an error or login prompt
            _vm = StateObject(wrappedValue: ProfileViewModel(userId: "placeholder"))
            _showTabButtons = showTabButtons
        }
        
        
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                    let shareMessage = "Checkout this Dish I rated on Tastys:"
                    let shareURL = URL(string: "https://tastysapp.com")!
                
                
//                if isMenuOpen {
                    LinearGradient(gradient: Gradient(colors: [.menu1, .menu2]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
//                } else {
//                    Color.white
//                        .ignoresSafeArea()
//                }
                
                if let err = vm.errorMessage {
                    PopUpView(error: err)
                }
                
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(.white)
                    .opacity(0.1)
                    .scaleEffect((geo.size.height - 240) / geo.size.height)
                    .offset(x: (geo.size.width * (1.0 / 5.1) - geo.size.width * ((geo.size.height - 240) / geo.size.height)))
                
                
                VStack {
                    HStack(spacing: 10){
                        NavigationLink{
                            EditProfileView()
                                .environmentObject(vm)
                        } label: {
                            ZStack{
                                Circle()
                                    .foregroundStyle(.fakeWhite)
                                    .frame(height: 45)
                                
                                Circle()
                                    .stroke(lineWidth: 0.4)
                                    .foregroundStyle(.strokedWhite)
                                    .frame(height: 45)
                                
                                Image("pencilIcon")
                                
                            }
                        }
                        
                        Spacer()
                        Spacer()
                        
                        Text("Your profile")
                            .foregroundStyle(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button{
                            Haptics.slide()
                            shareData = ShareData(items: [shareMessage, shareURL])
                        } label: {
                            ZStack{
                                Circle()
                                    .foregroundStyle(.fakeWhite)
                                    .frame(height: 42)
                                
                                Circle()
                                    .stroke(lineWidth: 0.4)
                                    .foregroundStyle(.strokedWhite)
                                    .frame(height: 42)
                                
                                Image(systemName: "arrowshape.turn.up.right")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 22))
                            }
                        }
                        .buttonStyle(.plain)
                        .sheet(item: $shareData) { data in
                            ActivityView(activityItems: data.items)
                        }
                        
                        Button{
                            Haptics.slide()
                            showTabButtons = false
                            isMenuOpen.toggle()
                        } label: {
                            ZStack{
                                Circle()
                                    .foregroundStyle(.fakeWhite)
                                    .frame(height: 38)
                                
                                Circle()
                                    .stroke(lineWidth: 0.4)
                                    .foregroundStyle(.strokedWhite)
                                    .frame(height: 42)
                                
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 22))
                            }
                        }
                    }
                    .padding(.trailing)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20){
                            HStack(spacing: 20) {
                                ZStack{
                                    if let profilePicture = vm.profile?.avatar {
                                        Circle()
                                            .foregroundStyle(.rectTastys)
                                            .frame(width: 109, height: 109)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                        Circle()
                                            .stroke(lineWidth: 3)
                                            .foregroundStyle(.white)
                                            .frame(width: 113, height: 109)
                                        
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
                                                .frame(width: 39.47, height: 38.47)
                                        }
                                        .frame(width: 109, height: 109)
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
                                            .frame(width: 34.47, height: 38.47)
                                    }
                                }
                                .padding(.trailing, 20)
                                .padding(.leading, 10)
                                .padding(.top, 10)
                                .overlay(alignment: .topTrailing){
                                    ZStack {
                                        //                                    Image("pickyImage")
                                        HStack(spacing: 3){
                                            if vm.profile?.food_profile == "\"\"" {
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
                                                Image(vm.profile?.food_profile ?? "Picky")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 22, height: 22)
                                                
                                                
                                                Text(vm.profile?.food_profile ?? "Picky")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                            
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background{
                                            
                                            colorForFoodProfile(vm.profile?.food_profile ?? "Picky")
                                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                        }
                                        .padding(.vertical, 8)
                                        //                                    .padding(.horizontal, 11)
                                    }
                                    .offset(x: 10, y: -6)
                                }
                                
                                VStack(alignment: .leading, spacing: 6){
                                    if isLoading {
                                        PlaceholderView(width: 120, height: 24, cornerRadius: 4)
//                                            .padding(.trailing, 20)
                                    } else {
                                        Text("@\(vm.profile?.username ?? "—")")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20))
                                            .fontWeight(.bold)
//                                            .padding(.trailing, 20)
                                    }
                                    
                                    if isLoading {
                                        PlaceholderView(width: 150, height: 20, cornerRadius: 4)
//                                            .padding(.trailing, 20)
                                    } else {
                                        Text(vm.profile?.bio ?? "")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .lineLimit(3)
                                            .lineSpacing(4)
//                                            .padding(.trailing, 20)
                                            .opacity(0.4)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            
                            VStack(spacing: 15){
                                HStack{
                                    Spacer()
                                    NavigationLink{
                                        RatedDishesView(dishes: $vm.topDishes, showTabButtons: $showTabButtons)
                                            .environmentObject(homeVM)
                                    } label: {
                                        VStack(spacing: 10){
                                            if isLoading {
                                                PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                                
                                            } else {
                                                Text("\(vm.profile?.totalDishesRated ?? 0)")
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
                                        RestaurantVisitedView(restaurants: vm.visitedRestaurants, userId: vm.userId, showTabButtons: $showTabButtons)
                                            .environmentObject(vm)
                                            .environmentObject(homeVM)
                                    } label: {
                                        VStack(spacing: 10){
                                            if isLoading {
                                                PlaceholderView(width: 30, height: 12, cornerRadius: 5)
                                            } else {
                                                Text("\(vm.profile?.totalRestaurantsVisited ?? 0)")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 16))
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
                                    
                                    NavigationLink{
                                        FollowersView(viewModel: vm, showTabButtons: $showTabButtons)
                                    } label: {
                                        VStack(spacing: 10){
                                            if isLoading {
                                                PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                            } else {
                                                Text("\(vm.profile?.followers_count ?? 0)")
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
                                    }
                                    Spacer()
                                    
                                    NavigationLink{
                                        FollowingsView(viewModel: vm, showTabButtons: $showTabButtons)
                                    } label: {
                                        VStack(spacing: 10){
                                            if isLoading {
                                                PlaceholderView(width: 30, height: 12, cornerRadius: 4)
                                            } else {
                                                Text("\(vm.profile?.following_count ?? 0)")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 15))
                                                    .fontWeight(.medium)
                                            }
                                            
                                            Text("Following")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 11))
                                                .fontWeight(.medium)
                                                .opacity(0.5)
                                        }
                                    }
                                    Spacer()
                                    
                                }
                                
                                VStack{
                                    HStack{
                                        Image("starIcon")
                                        
                                        Text("Your taste at a glance")
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
                                                .font(.system(size: 16))
                                                .fontWeight(.medium)
                                            
                                            if isLoading {
                                                PlaceholderView(width: 60, height: 16, cornerRadius: 4)
                                                    .padding(.top, 5)
                                            } else {
                                                Text("\(Int(vm.profile?.average_rating ?? 0))%❤️")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 14))
                                                    .fontWeight(.semibold)
                                                    .padding(.top, 5)
                                            // .padding(.bottom, 9)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Rectangle()
                                            .foregroundStyle(.gray.opacity(0.2))
                                            .frame(width: 1, height: 80)
                                        
                                        Spacer()
                                        
                                        if let topDish = vm.topDishes.first {
                                            NavigationLink {
                                                FoodDetailView(
                                                    dishId: topDish.id.uuidString,
                                                    showTabButtons: $showTabButtons
                                                )
                                                .environmentObject(homeVM)
                                            } label: {
                                                VStack(spacing: 14) {
                                                    Text("Top Rated Dish")
                                                        .foregroundStyle(.black)
                                                        .opacity(0.5)
                                                        .font(.system(size: 12))
                                                        .fontWeight(.medium)

                                                    AsyncImage(url: URL(string: topDish.image ?? "")) { image in
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

                                                    Text(topDish.name)
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
                                            
                                        Image(faveDish)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35, height: 35)
                                            .clipShape(Circle())
                                            
                                            
                                            Text(faveDish)
                                                .foregroundStyle(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.medium)
                                            
                                        }
                                        
                                        
//                                        Spacer()
                                        
                                    }
                                }
                                .padding(19)
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
//                                    .frame(width: 360, height: 231)
                            }
//                            .frame(width: 360, height: 231)
                            .padding(.trailing, 20)
                            
                        
                            
//                            HStack(alignment: .top){
//                                
//                                
//                                VStack(spacing: 8){
//                                    Text("Community Score")
//                                        .foregroundStyle(.black)
//                                        .opacity(0.5)
//                                        .font(.system(size: 13))
//                                        .fontWeight(.medium)
//                                    
//                                    if isLoading {
//                                        PlaceholderView(width: 40, height: 20, cornerRadius: 6)
//                                    } else {
//                                        ReuseableScoreBorderView(score: Int(vm.profile?.community_score ?? 0))
//                                    }
//                                }
//                            }
//                            .padding(.trailing, 20)
                            
                            SubProfileView(showTabButtons: $showTabButtons)
                                .environmentObject(homeVM)
                                .environmentObject(vm)
                                .environmentObject(foodVM)
                            
                            VStack{
                                
                                HStack{
                                    Text("Top rated dishes")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                
                                
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20){
                                            if vm.isLoading && vm.topDishes.isEmpty {
                                                ForEach(0..<3) { _ in
                                                    DishCardSkeletonView()
                                                }
                                            } else {
                                                if !vm.topDishes.isEmpty {
                                                    ForEach(vm.topDishes) { dish in
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
                                    Text("Recent reviews")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                
                               
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 5){
                                        if vm.isLoading && vm.posts.isEmpty {
                                            ForEach(0..<3) { _ in
                                                PlainFeedCardSkeletonView()
                                            }
                                        } else {
                                            if !vm.posts.isEmpty {
                                                
                                                ForEach(vm.posts
//                                                    .filter {
//                                                    guard let comment = $0.post.comment else { return false }
//                                                    return !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//                                                }
                                                ) { post in
                                                    
                                                    NavigationLink{
                                                        FoodDetailView(dishId: post.dishes?.first?.dish.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                                            .environmentObject(homeVM)
                                                    } label:{
                                                        NewFeedCardView(post: post, showTabButtons: $showTabButtons)
                                                            .environmentObject(homeVM)
                                                    }
//                                                        .offset(x: -10)
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
                            
                            
                            
                            
                            
                            
                            
                            
                            
//                            HStack{
//                                Button{
//                                    Haptics.slide()
//                                    selectedFeed = 1
//                                } label: {
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 25.0)
//                                            .foregroundStyle(selectedFeed == 1 ? .tastysRed : .clear)
//                                            .frame(height: 32)
//                                        Text("Recently posted")
//                                            .foregroundStyle(selectedFeed == 1 ? .white : .black)
//                                        .font(.system(size: 12))
//                                        .fontWeight(.medium)
//                                    }
//                                    
//                                }
//                                .buttonStyle(.plain)
//                                .padding(.trailing, 20)
//                                
//                                Button{
//                                    Haptics.slide()
//                                    selectedFeed = 2
//                                } label: {
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 25.0)
//                                            .foregroundStyle(selectedFeed == 2 ? .tastysRed : .clear)
//                                            .frame(height: 32)
//                                        Text("Top rated dishes")
//                                            .foregroundStyle(selectedFeed == 2 ? .white : .black)
//                                        .font(.system(size: 12))
//                                        .fontWeight(.medium)
//                                    }
//                                    
//                                }
//                                .buttonStyle(.plain)
//                            }
//                            .padding(.vertical, 2)
//                            .background{
//                                Color.white
//                                    .clipShape(RoundedRectangle(cornerRadius: 27))
//                                    .shadow(color: Color.black.opacity(0.1), radius: 2)
//                            }
//                            .padding(.trailing, 15)
                            
//                            if selectedFeed == 1 {
//                                if  !vm.isLoading || !vm.posts.isEmpty {
//                                    if vm.posts.isEmpty {
//                                        Text("No post yet🤧")
//                                            .foregroundStyle(.gray)
//                                            .font(.system(size: 15))
//                                            
//                                    } else {
//                                        ForEach(vm.posts) { post in
//                                            FeedCardView(post: post, showTabButtons: $showTabButtons)
//                                                .environmentObject(homeVM)
//                                                .offset(x: -10)
//                                            
//                                        }
//                                    }
//                                } else {
//                                    ForEach(0..<3) {_ in
//                                    FeedCardSkeletonView()
//                                    }
//                                }
//                            } else if selectedFeed == 2 {
//                                if !vm.isLoading {
//                                    if vm.topDishes.isEmpty {
//                                        Text("No rated dishes yet🤧")
//                                            .foregroundStyle(.gray)
//                                            .font(.system(size: 15))
//                                    } else {
//                                        RatedDishesView(dishes: $vm.topDishes, showTabButtons: $showTabButtons)
//                                            .environmentObject(homeVM)
//                                    }
//                                } else {
////                                    ForEach(0..<3) {_ in
////                                       DishCardSkeletonView()
////                                    }
//                                }
//                            }
                            
                            
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                            }
                            .frame(height: 2)
                        }
//                        .padding(.bottom, 50)
                    }
                    .refreshable {
                        Task{
                            await vm.loadProfile()
//                            await vm.loadPlates()
                            await vm.loadPosts(userId: vm.profile?.user_id ?? "")
                            await vm.getUserVisitedRestaurants(p_user_id: vm.profile?.user_id ?? "")
                            await vm.get_user_top_dishes(p_user_id: vm.userId)
                            let userIdForBookmarks = vm.session?.user.id
                                ?? supabase.auth.currentSession?.user.id
                                ?? UUID()

//                            if !userIdForBookmarks {
                                await foodVM.getUserBookmarks(userId: userIdForBookmarks)
//                            }
                            isLoading = false
                        }
                    }
                }
                .padding(.leading, 15)
                
                .background{
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .ignoresSafeArea()
                }
                .scaleEffect(isMenuOpen ? ((geo.size.height - 180) / geo.size.height) : 1)
                .offset(x: isMenuOpen ? (geo.size.width * (1.0 / 6.0) - geo.size.width * ((geo.size.height - 180) / geo.size.height)) : 0)
                .animation(.default, value: isMenuOpen)
//                .blur(radius: showRatingCard ? 7 : 0)
//                .onTapGesture {
//                    if showRatingCard {
//                        showRatingCard = false
//                    }
//                    
//                }
                
                
                
                if showRatingCard {
                    VStack{
                        
                        HStack {
                            Spacer()
                            RatingPopUpView(isShowing: $showRatingCard)
                                .padding(.trailing, 15)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
                
                if isMenuOpen {
                    VStack {
                        HStack{
                            Spacer()
                            Spacer()
                            Spacer()
                            Text("More Menu")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            Spacer()
                            Spacer()
                            
                            Button{
                                Haptics.revealDone()
                                showTabButtons = true
                                isMenuOpen = false
                            } label: {
                                ZStack{
                                    Circle()
                                        .foregroundStyle(.lightBlack)
                                        .opacity(0.14)
                                        .frame(height: 43)
                                    
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(.strokedWhite)
                                        .opacity(0.27)
                                        .frame(height: 47)
                                    
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                }
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
//                        .padding(.trailing, 20)
                        
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 20) {
//                                ForEach(["your plate", "your current city", "FAQ", "change password", "support", "notifications", "privacy & policy"], id: \.self) { item in
//                                    Button {
                                         
//                                    } label: {
//                                        Text(item)
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 16))
//                                            .fontWeight(.medium)
//                                    }
//                                }
                                
//                                NavigationLink{
//                                    
//                                } label: {
//                                    Text("🍽️ your plate")
//                                        .foregroundStyle(.white)
//                                        .font(.system(size: 14))
//                                        .fontWeight(.semibold)
//                                }
                                
//                                NavigationLink{
//                                    
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "location")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 18))
//                                        Text("current city: New York")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 15))
//                                        .fontWeight(.semibold)
//                                    }
//                                }
                                
//                                NavigationLink{
//                                    
//                                } label: {
//                                    HStack {
//                                        Image("dietaryIcon")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 18))
//                                        Text("Dietary restrictions")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 14))
//                                        .fontWeight(.semibold)
//                                    }
//                                }
                                
//                                NavigationLink{
//                                    
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "key")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 18))
//                                        Text("Change password")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 14))
//                                        .fontWeight(.semibold)
//                                    }
//                                }
                                
//                                NavigationLink{
//                                    
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "questionmark")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 14))
//                                        Text("FAQ")
//                                            .foregroundStyle(.white)
//                                            .font(.system(size: 14))
//                                        .fontWeight(.semibold)
//                                    }
//                                }
                                
                                NavigationLink{
                                    NotificationsView()
                                        .environmentObject(homeVM)
                                } label: {
                                    HStack {
                                        Image(systemName: "bell")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18))
                                        Text("Notifications")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                    }
                                }
                                
                                Button {
                                    let subject = "Tastys Support Request"
                                    let body = """
                                    Hi Tastys Support,

                                    I'm experiencing the following issue:


                                    ---

                                    Username: @\(vm.profile?.username ?? "")
                                    User ID: \(vm.userId)
                                    App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                                    iOS Version: \(UIDevice.current.systemVersion)
                                    Device: \(UIDevice.current.model)

                                    """

                                    let email = "ash@tastysapp.com"

                                    guard
                                        let subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                        let body = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                        let url = URL(string: "mailto:\(email)?subject=\(subject)&body=\(body)")
                                    else { return }

                                    openURL(url)
                                } label: {
                                    HStack {
                                        Image(systemName: "headphones")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18))

                                        Text("Support")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink{
                                    
                                } label: {
                                    HStack {
                                        Image(systemName: "eye.slash")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18))
                                        Text("Privacy policy")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                    }
                                }
                                
                                
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                            .offset(x: 30)
                        }
                        .frame(width: geo.size.width * (3.0 / 5.0))
                    .transition(.move(edge: .trailing))
                        Spacer()
                        
                        Button{
                            Haptics.slide()
                            avatar = ""
                            Task {
                                try? await supabase.auth.signOut()
                            }
    
                        } label: {
                            HStack {
                                Spacer()
                                Image("logoutIcon")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("Log out")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                Spacer()
                                    
                            }
                            .background{
                                ZStack {
                                    RoundedRectangle(cornerRadius: 23.0)
                                        .foregroundStyle(.black)
                                    .opacity(0.08)
                                    
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundStyle(.white)
                                        .opacity(0.13)
                                }
                                
                            }
                        
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 15)
                        
                        Button{
                            showDeleteConfirmation = true
                        } label: {
                            Text("Delete Account")
                                .foregroundStyle(.white)
                                .font(.system(size: 12))
                                .opacity(0.8)
                        }
                        .disabled(vm.isDeleting)
                        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                            Button("Cancel", role: .cancel) { }
                            Button("Delete", role: .destructive) {
                                avatar = ""
                                Task {
                                    await vm.deleteAccount()
                                }
                            }
                        } message: {
                            Text("This will permanently delete your account and all your data, including posts, ratings, and personal data. This action cannot be undone.")
                        }
                                
                        
//                        .padding(.bottom, 20)
                        
                    }
                }
                
//                if isMenuOpen {
//                    Color.clear
//                        .frame(width: geo.size.width * (1.0 / 5.0), height: geo.size.height)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            isMenuOpen = false
//                        }
//                }
                
                if vm.isDeleting {
                    Color.ashTastys
                        .opacity(0.5)
                        .ignoresSafeArea()
                    
                    ProgressView()
                }
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
            .onAppear{
                Haptics.prepare()
            }
           

            .task {
                await vm.loadProfile()
//                await vm.loadPlates()
                print("your id: \(vm.profile?.user_id ?? "")")
                await vm.loadPosts(userId: vm.profile?.user_id ?? "")
                await vm.getUserVisitedRestaurants(p_user_id: vm.profile?.user_id ?? "")
                await vm.get_user_top_dishes(p_user_id: vm.userId)
                let userIdForBookmarks = vm.session?.user.id
                    ?? supabase.auth.currentSession?.user.id
                    ?? UUID()

//                if !userIdForBookmarks.isEmpty {
                    await foodVM.getUserBookmarks(userId: userIdForBookmarks)
//                }

                isLoading = false
            }
            
        }
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
    NavigationStack {
        ProfileView(showTabButtons: .constant(false))
            .environmentObject(HomeViewModel())
    }
}

struct ShareData: Identifiable {
    let id = UUID()  // Makes it Identifiable for .sheet(item:)
    let items: [Any]
}

struct SubProfileView: View {
    @AppStorage("selectedDish") private var faveDish = "Italian"
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var foodVM: FoodViewModel
    
    @Binding var showTabButtons: Bool   // Received from MainTabView
//    @State private var lastOffset: CGFloat = 0
    var body: some View {
        VStack{
            NavigationLink{
                FoodView(showTabButtons: $showTabButtons)
                    .environmentObject(homeVM)
            } label: {
                HStack(spacing: 25){
                    // Stacked Images
                    ZStack {
                        // Bottom image (third layer) - smallest and most offset
                        Image("plate1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .clipShape(Circle())
                            .overlay{
                                Circle()
                                    .stroke(lineWidth: 1.7)
                                    .foregroundStyle(.white)
                            }
                            .offset(x: 16)
                            .zIndex(1)
                        
                        // Middle image (second layer) - medium size and offset
                        Image("plate2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 27)
                            .clipShape(Circle())
                            .overlay{
                                Circle()
                                    .stroke(lineWidth: 1.7)
                                    .foregroundStyle(.white)
                            }
                            .offset(x: 8)
                            .zIndex(2)
                        
                        // Top image (first layer) - full size
                        Image("plate4")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .clipShape(Circle())
                            .overlay{
                                Circle()
                                    .stroke(lineWidth: 1.7)
                                    .foregroundStyle(.white)
                            }
                            .zIndex(3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4){
                        Text("See Your plate")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .opacity(0.8)
                        
                        Text("Places & Dishes i want to try")
                            .foregroundStyle(.black)
                            .font(.system(size: 13))
                            .fontWeight(.regular)
                            .opacity(0.5)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                    
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.fakeWhite)
                }
            }
            .padding(.trailing, 20)
            
            ZStack{
                HStack(alignment: .bottom){
                    VStack(alignment: .leading){
                        Text("Hungry Friends")
                            .foregroundStyle(.white)
                            .font(.system(size: 14))
                        
                        Text("See what your friends \nare eating")
                            .foregroundStyle(.white)
                            .opacity(0.7)
                            .font(.system(size: 11))
                        
                        ShareLink(
                            item: URL(string: "https://www.tastysapp.com")!,
                            message: Text("Hi, check out this dish rating app called Tastys")
                        ) {
                            HStack{
                                Image(systemName: "plus")
                                    .foregroundStyle(.tastysRed)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("Invite friends to rate")
                                    .foregroundStyle(.tastysRed)
                                    .font(.system(size: 13))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 13)
                            .background{
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 23))
                            }
                        }
                        
                    }
                    .padding([.vertical, .leading])
                    
                    Spacer()
                    
                    Image("pizzaImage")
                        
                }
                .background{
                    ZStack{
                        Color.tastysRed
                        
                        LinearGradient(colors: [.darkRedTastys.opacity(0.6), .clear], startPoint: .topTrailing, endPoint: .bottomLeading)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: -10)
                            .padding(.top, 14)
                            .clipped()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 23))
                    
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 23))
                
            }
            .padding(.trailing, 15)
            

        }
    }
}



struct PlaceholderView: View {
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat = 8
    
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.4))
            .frame(width: width, height: height)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .white.opacity(0.2), location: 0.2),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? width : -width)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

