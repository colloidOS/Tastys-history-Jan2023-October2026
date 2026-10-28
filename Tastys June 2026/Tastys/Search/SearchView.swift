//
//  SearchView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/02/2026.
//

import SwiftUI




struct SearchView: View {
    @State private var options = ["Dishes", "Restaurants", "Foodies"]
    @State private var selectedOption = "Dishes"
    
    @Binding var showTabButtons: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State private var lastOffset: CGFloat = 0
    
    @State private var showLocationCard = false
    @State private var searchAddressText = ""
//    @State private var searchText = ""
    
    @AppStorage("userLocation") private var userLocation = "New York"
    
    @StateObject private var viewModel = SearchViewModel()
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Button {
                    Haptics.slide()
                    showLocationCard = true
                } label: {
                    VStack {
                        Text("Location")
                            .foregroundStyle(.black)
                            .opacity(0.4)
                            .font(.system(size: 13))
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.tastysRed)
                                .font(.system(size: 18))
                                .rotationEffect(Angle(degrees: -90))
                            
                            Text(userLocation)
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.black)
                                .opacity(0.4)
                                .font(.system(size: 13))
                        }
                    }
                }
                .padding(.bottom, 15)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                    
                    ZStack(alignment: .leading) {
                        TextField("", text: $viewModel.searchText)
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .focused($isTextFieldFocused)
                        
                        if viewModel.searchText.isEmpty {
                            Text("dishes, restaurants, foodies")
                                .foregroundStyle(.black)
                                .opacity(0.4)
                                .font(.system(size: 15))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background {
                    Color.ashTastys.opacity(0.8)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                .padding(.horizontal, 25)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(options, id: \.self) { option in
                            Button {
                                Haptics.slide()
                                withAnimation(.spring()) {
                                    selectedOption = option
                                }
                            } label: {
                                Text(option)
                                    .foregroundStyle(selectedOption == option ? .white : .black)
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundStyle(selectedOption == option ? .tastysRed : .white)
                                            .shadow(color: .black.opacity(0.1), radius: 3)
                                            .padding(.bottom, 2)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 15)
                }
                .padding(.top, 10)
                .scrollDismissesKeyboard(.interactively)
                
                if let error = viewModel.errorMessage {
                    PopUpView(error: error)
                }
                
                ScrollView {
                    switch selectedOption {
                    case "Dishes":
                        if (viewModel.isLoading && viewModel.searchedDishes.isEmpty)
                            || (viewModel.searchText.isEmpty && leaderboardVM.topDishes.isEmpty) {
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(0..<4, id: \.self) { _ in
                                    FoodCardSkeletonView()
//                                        .frame(height: 224)
                                }
                            }
                            .padding(.horizontal)
                        } else if viewModel.searchedDishes.isEmpty && !viewModel.searchText.isEmpty {
                            Text("No dishes found")
                                .foregroundStyle(.gray)
                                .font(.system(size: 16))
                                .padding(.top, 50)
                            
                        } else if viewModel.searchedDishes.isEmpty && viewModel.searchText.isEmpty {
                            
                            VStack(spacing: 29) {
                                VStack(alignment: .leading){
                                    
                                    HStack(spacing: 5){
                                        Image("chefsKissIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 21)
                                        
                                        Text("Top Dishes")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 18))
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text("Highest rated Dishes near you")
                                        .foregroundStyle(.black)
                                        .opacity(0.5)
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack{
                                            ForEach(leaderboardVM.topDishes) { topDish in
                                                let dish = topDish.toDish()
                                                
                                                NavigationLink {
                                                    FoodDetailView(
                                                        dishId: dish.id.uuidString,
                                                        showTabButtons: $showTabButtons
                                                    )
                                                    .environmentObject(homeVM)
                                                    
                                                } label: {
                                                    DishCardView(
                                                        dish: dish,
                                                        restaurant: RestaurantDetails(
                                                            id: dish.restaurantId ?? UUID(),
                                                            name: dish.restaurantName ?? "Unknown",
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
                                                    .environmentObject(homeVM)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                VStack(alignment: .leading){
                                    HStack(spacing: 3){
                                        Image("chefsKissIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 21)
                                        
                                        Text("Trending Dishes")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 18))
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text("People are talking about these")
                                        .foregroundStyle(.black)
                                        .opacity(0.5)
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack{
                                            ForEach(leaderboardVM.trendingDishes) { trendingDish in
                                                let dish = trendingDish.toDish()
                                                
                                                NavigationLink {
                                                    FoodDetailView(
                                                        dishId: dish.id.uuidString,
                                                        showTabButtons: $showTabButtons
                                                    )
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
                                                    .environmentObject(homeVM)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                }
                            }
                            
                        } else {
                            // ─────────────────────────────────────────────────────────────
                            // NEW SEARCH RESULTS LAYOUT FOR DISHES (with sectionType)
                            // Labels now match the leaderboard style exactly
                            // Trending → horizontal row
                            // Top Rated → horizontal row
                            // Everything else → 2-column grid
                            // ─────────────────────────────────────────────────────────────
                            let trendingDishes = viewModel.searchedDishes.filter { $0.sectionType == "trending" }
                            let topRatedDishes = viewModel.searchedDishes.filter { $0.sectionType == "top_rated" }
                            let otherDishes = viewModel.searchedDishes.filter { $0.sectionType != "trending" && $0.sectionType != "top_rated" }
                            
                            VStack(spacing: 25) {
                                
                                // Top Rated section (matches leaderboard style)
                                if !topRatedDishes.isEmpty {
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 3) {
                                            Image("chefsKissIcon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 21)
                                            
                                            Text("Top Dishes")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 18))
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        
                                        Text("Highest rated Dishes near you")
                                            .foregroundStyle(.black)
                                            .opacity(0.5)
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .padding(.horizontal)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(topRatedDishes) { dish in
                                                    NavigationLink {
                                                        FoodDetailView(
                                                            dishId: dish.id.uuidString,
                                                            showTabButtons: $showTabButtons
                                                        )
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
                                                        .environmentObject(homeVM)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // Trending section (matches leaderboard style)
                                if !trendingDishes.isEmpty {
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 3) {
                                            Image("chefsKissIcon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 21)
                                            
                                            Text("Trending Dishes")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.horizontal)
                                        
                                        Text("People are talking about these")
                                            .foregroundStyle(.black)
                                            .opacity(0.5)
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .padding(.horizontal)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(trendingDishes) { dish in
                                                    NavigationLink {
                                                        FoodDetailView(
                                                            dishId: dish.id.uuidString,
                                                            showTabButtons: $showTabButtons
                                                        )
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
                                                        .environmentObject(homeVM)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // Other dishes → 2-column grid (same as your old search layout)
                                if !otherDishes.isEmpty {
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 3) {
                                            HStack(spacing: 3){
                                                VStack(spacing: 3){
                                                    Circle()
                                                        .stroke(lineWidth: 1)
                                                        .foregroundStyle(.tastysRed)
                                                        .frame(width: 6, height: 6)
                                                    
                                                    Circle()
                                                        .stroke(lineWidth: 1)
                                                        .foregroundStyle(.tastysRed)
                                                        .frame(width: 5, height: 6)
                                                }
                                                VStack(spacing: 3){
                                                    Circle()
                                                        .stroke(lineWidth: 1)
                                                        .foregroundStyle(.tastysRed)
                                                        .frame(width: 6, height: 6)
                                                    
                                                    Circle()
                                                        .stroke(lineWidth: 1)
                                                        .foregroundStyle(.tastysRed)
                                                        .frame(width: 6, height: 6)
                                                }
                                            }
                                            
                                            Text("Showing All")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 18))
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.horizontal)
                                        
                                        Text("Showing All \(viewModel.searchText)")
                                            .foregroundStyle(.black)
                                            .opacity(0.5)
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .padding(.horizontal)
                                        
                                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                            ForEach(otherDishes) { dish in
                                                GeometryReader { geo in
                                                    NavigationLink {
                                                        FoodDetailView(
                                                            dishId: dish.id.uuidString,
                                                            showTabButtons: $showTabButtons
                                                        )
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
                                                        .environmentObject(homeVM)
                                                    }
                                                }
                                                .frame(height: 180)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Pagination stays at the very bottom (works for all sections)
                                if viewModel.hasMoreDishes {
                                    Color.clear
                                        .frame(height: 20)
                                        .onAppear {
                                            Task {
                                                await viewModel.loadMoreDishes(term: viewModel.searchText)
                                            }
                                        }
                                }
                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                }
                            }
                        }
                        
                    case "Restaurants":
                        // (unchanged - you only asked to update Dishes)
                        if viewModel.isLoading && viewModel.searchedRestaurants.isEmpty {
                                ForEach(0..<2, id: \.self) { _ in
                                    NewRestaurantCardSkeletonView()
                                }
                                .padding(.horizontal)
                        } else if viewModel.searchedRestaurants.isEmpty && !viewModel.searchText.isEmpty {
                            Text("No restaurants found")
                                .foregroundStyle(.gray)
                                .font(.system(size: 16))
                                .padding(.top, 50)
                            
                        } else if viewModel.searchedRestaurants.isEmpty && viewModel.searchText.isEmpty {
                            
                            VStack {
                                ForEach(leaderboardVM.topRestaurants) { topRestaurant in
                                    let restaurant = topRestaurant.toRestaurantDetails()
//                                    GeometryReader { geo in
                                        NavigationLink {
                                            RestaurantDetailView(
                                                restaurantId: restaurant.id.uuidString,
                                                dishImage: "",
                                                showTabButtons: $showTabButtons
                                            )
                                            .environmentObject(homeVM)
                                            
                                        } label: {
                                            NewRestaurantCardView(
                                                restaurant: restaurant,
                                                restaurantScore: Int(restaurant.rating ?? 0),
                                                showTabButtons: $showTabButtons
                                            )
                                            .environmentObject(homeVM)
                                        }
//                                    }
//                                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                                }
                            }
                            .padding(.horizontal)
                            
                        } else {
                            ForEach(viewModel.searchedRestaurants) { restaurant in
//                                GeometryReader { geo in
                                    NavigationLink {
                                        RestaurantDetailView(restaurantId: restaurant.id.uuidString, dishImage: "", showTabButtons: $showTabButtons)
                                            .environmentObject(homeVM)
                                    } label: {
                                        NewRestaurantCardView(
                                            restaurant: restaurant,
                                            restaurantScore: Int(restaurant.rating ?? 0), showTabButtons: $showTabButtons
                                        )
                                        .environmentObject(homeVM)
                                    }
//                                }
//                                .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                            }
                            .padding(.horizontal)
                            if viewModel.hasMoreRestaurants {
                                Color.clear
                                    .frame(height: 20)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadMoreRestaurants(term: viewModel.searchText)
                                        }
                                    }
                            }
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                            }
                        }
                        
                    case "Foodies":
                        // (unchanged)
                        if viewModel.isLoading && viewModel.searchedFoodies.isEmpty {
                            ForEach(0..<3) {_ in
                                FoodieCardSkeletonView()
                                    .padding(.top, 20)
                                    .padding(.horizontal, 10)
                            }
                        } else if viewModel.searchedFoodies.isEmpty && !viewModel.searchText.isEmpty {
                            Text("No foodies found")
                                .foregroundStyle(.gray)
                                .font(.system(size: 16))
                                .padding(.top, 50)
                            
                        } else if viewModel.searchedFoodies.isEmpty && viewModel.searchText.isEmpty {
                            
                            VStack(alignment: .leading){
                                
                                HStack(spacing: 3){
                                    Image("chefsKissIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 21)
                                    
                                    Text("Top Users")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                Text("Highest rated Rated users")
                                    .foregroundStyle(.black)
                                    .opacity(0.5)
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .padding(.horizontal)
                                
                                ForEach(leaderboardVM.topUsers) { topUser in
                                    let user = topUser.toUserProfile()
                                    NavigationLink{
                                        FriendProfileView(friendsUserId: user.user_id, showTabButtons: $showTabButtons)
                                            .environmentObject(homeVM)
                                        
                                    } label: {
                                        FoodieCardView(foodie: user, showTabButtons: $showTabButtons)
                                            .environmentObject(leaderboardVM)
                                            .environmentObject(homeVM)
                                            .environmentObject(viewModel)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal, 6)
                            
                        } else {
                            VStack(spacing: 15) {
                                ForEach(viewModel.searchedFoodies) { user in
                                    
                                    if user.user_id.lowercased() != homeVM.currentUser?.id.uuidString.lowercased() {
                                        NavigationLink {
                                            FriendProfileView(friendsUserId: user.user_id, showTabButtons: $showTabButtons)
                                                .environmentObject(homeVM)
                                        } label: {
                                            FoodieCardView(foodie: user, showTabButtons: $showTabButtons)
                                                .environmentObject(leaderboardVM)
                                                .environmentObject(homeVM)
                                                .environmentObject(viewModel)
                                            
                                        }
                                        .padding(.horizontal)
                                        
                                    } else {
                                        FoodieCardView(foodie: user, showTabButtons: $showTabButtons)
                                            .padding(.horizontal)
                                            .environmentObject(leaderboardVM)
                                            .environmentObject(homeVM)
                                            .environmentObject(viewModel)
                                    }
                                }
                            }
                            .padding(.top, 20)
                            .refreshable {
                                Task{
                                    await leaderboardVM.loadFor(option: selectedOption)
                                }
                            }
                            if viewModel.hasMoreFoodies {
                                Color.clear
                                    .frame(height: 20)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadMoreFoodies(term: viewModel.searchText)
                                        }
                                    }
                            }
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                            }
                        }
                    default:
                        EmptyView()
                    }
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                    }
                    .frame(height: 0)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .blur(radius: showLocationCard ? 7 : 0)
            .onTapGesture {
                if showLocationCard {
                    showLocationCard = false
                }
            }
            
            if showLocationCard {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showLocationCard = false
                    }
                VStack {
                    HStack {
                        Spacer()
                        SearchingView(searchText: $searchAddressText, isShowing: $showLocationCard)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            Haptics.prepare()
            Task{
                await leaderboardVM.loadFor(option: selectedOption)
//                print(leaderboardVM.topUsers.first?.userId ?? "nothing")
            }
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            Task {
                switch selectedOption {
                case "Dishes":
                    await viewModel.onSearchTextChanged(newValue)
                case "Restaurants":
                    await viewModel.searchRestaurants(term: newValue)
                case "Foodies":
                    await viewModel.searchFoodies(term: newValue)
                default:
                    break
                }
            }
        }
        .onChange(of: selectedOption) {
            if viewModel.searchText.isEmpty {
                Task {
                    await leaderboardVM.loadFor(option: selectedOption)
                }
            }
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            viewModel.clearResults()
            Task {
                switch newValue {
                case "Dishes":
                    await viewModel.searchDishes(term: viewModel.searchText)
                case "Restaurants":
                    await viewModel.searchRestaurants(term: viewModel.searchText)
                case "Foodies":
                    await viewModel.searchFoodies(term: viewModel.searchText)
                default:
                    break
                }
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
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

#Preview {
    SearchView(showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
}

