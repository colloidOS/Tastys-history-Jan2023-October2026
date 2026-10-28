//
//  HomeView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 10/12/2025.
//

import SwiftUI
import MapKit


struct HomeView: View {
    @State private var searchText = ""
    @State private var diets = ["Halal", "Vegan", "Vegetarian", "Gluten-free", "Diary Free", "Keto", "Paleo"]
    @AppStorage("selectedDietFilter") private var selectedDiet = "Halal"
    @State private var showAllDiets = false
    @State private var dietDropDownHeight = 20.0
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    @State private var dishes = ["All", "Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    @State private var selectedDish = "All"
    @AppStorage("selectedDish") private var faveDish = ""
    @State private var showAllDishes = false
    
    // Visible dishes (up to Mexican + See all + Recommend)
    var visibleDishes: [String] {
        if let mexicanIndex = dishes.firstIndex(of: "Mexican") {
            return Array(dishes.prefix(through: mexicanIndex))
        }
        return dishes
    }
    @State private var dropDownHeight = 20.0
    
    @State private var showComment = false
    @State private var showLocationCard = false
    @State private var showRatingCard = false
    @State private var searchAddressText = ""
    
    @StateObject private var locManager = LocationManager()
    @AppStorage("hasAskedLocation") private var hasAskedLocation = false
    @AppStorage("userLocation") private var userLocation = "New York"
    
    @State private var showDishTap = false
    @State private var tapPosition: CGPoint = .zero
    @State private var rotation: Double = 0.0
    @State private var dish: Dish?
    
    @State private var selectedCardIndex: Int? = nil
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var showTabButtons: Bool
    @State private var lastOffset: CGFloat = 0
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @Environment(\.dismiss) private var dismiss
    
    @State private var showFullTopRated = false
    @State private var showFullFeed = false
    @State private var showRecommendSheet = false
    @FocusState private var isTextFieldFocused: Bool
    private var isDefaultFilter: Bool {
        searchText.isEmpty && selectedDish == "All" && selectedDiet.isEmpty
    }
    
    private var filteredTopRatedDishes: [Dish] {
        vm.topRatedDishes.filter { dish in
            let lowerSearch = searchText.lowercased()

            let matchesSearch =
                searchText.isEmpty ||
                dish.name.lowercased().contains(lowerSearch) ||
                (dish.description?.lowercased().contains(lowerSearch) ?? false) ||
                (dish.restaurantName?.lowercased().contains(lowerSearch) ?? false)

            let matchesDiet =
                selectedDiet.isEmpty ||
                (dish.diets?.contains {
                    $0.lowercased() == selectedDiet.lowercased()
                } ?? false)

            return matchesSearch && matchesDiet
        }
    }

    private var filteredTrendingDishes: [Dish] {
        vm.trendingDishes.filter { dish in
            let lowerSearch = searchText.lowercased()

            let matchesSearch =
                searchText.isEmpty ||
                dish.name.lowercased().contains(lowerSearch) ||
                (dish.description?.lowercased().contains(lowerSearch) ?? false) ||
                (dish.restaurantName?.lowercased().contains(lowerSearch) ?? false)

            let matchesDiet =
                selectedDiet.isEmpty ||
                (dish.diets?.contains {
                    $0.lowercased() == selectedDiet.lowercased()
                } ?? false)

            return matchesSearch && matchesDiet
        }
    }
    @State private var topRatedPage = 1
    @State private var trendingPage = 1

    private let pageSize = 20

    @State private var isLoadingMoreTopRated = false
    @State private var isLoadingMoreTrending = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                Color.white
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        HStack(spacing: 11) {
                            Image("logo")
                            
                            Spacer()
                            
                            Button {
                                Haptics.slide()
                                showLocationCard = true
                            } label: {
                                VStack {
                                    Text("Location")
                                        .foregroundStyle(.black)
                                        .opacity(0.4)
                                        .font(.system(size: 12))
                                    
                                    HStack {
//                                        Image(systemName: "location.fill")
//                                            .foregroundStyle(.tastysRed)
//                                            .font(.system(size: 18))
//                                            .rotationEffect(Angle(degrees: -90))
                                        
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
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            if !vm.isAuthenticated {
                                Button{
                                    guestRouter.goToSignup()
                                } label:{
                                        
                                    Text("Sign up")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.black)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 14)
                                        .background{
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundStyle(.white)
                                        }
                                }
                                
                            } else {
                                NavigationLink {
                                    NotificationsView()
                                        .environmentObject(vm)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.white)
                                            .frame(height: 47)
                                        
                                        ZStack(alignment: .topTrailing) {
                                            
                                            Image(systemName: "bell")
                                                .font(.system(size: 18))
                                                .foregroundStyle(.black)
                                            
                                            if vm.unreadNotificationCount > 0 {
                                                
                                                Circle()
                                                    .fill(.tastysRed)
                                                    .frame(width: 12, height: 12)
                                                    .offset(x: -1, y: -3)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 15))
                                
                                
                                ZStack(alignment: .leading) {
                                    TextField("", text: $searchText)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14))
                                        .focused($isTextFieldFocused)
                                    
                                    if searchText.isEmpty {
                                        Text("search for dishes and restaurants")
                                            .foregroundStyle(.black)
                                            .opacity(0.4)
                                            .font(.system(size: 14))
                                            .lineLimit(1)
                                    }
                                    
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background {
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            }
                            Button {
                                Haptics.slide()
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    dropDownHeight = 0.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showAllDishes = false
                                }
                                showAllDiets = true
                                withAnimation(.linear(duration: 0.5)) {
                                    dietDropDownHeight = 350.0
                                    
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(selectedDiet.isEmpty ? "plateUsername" : selectedDiet)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                    Text(selectedDiet.isEmpty ? "All" : selectedDiet)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.black)
                                        .opacity(0.4)
                                        .font(.system(size: 13))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background {
                                    Color.white
                                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                }
                            }
                            .buttonStyle(.plain)
                            
                        }
                        
                        
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background {
                        Color.homeHeader
                            .ignoresSafeArea(edges: [.top, .horizontal])
                    }
                    
                    ScrollView(showsIndicators: false) {
                        HStack {
                            Text("What are you craving?")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .opacity(0.5)
                                .offset(y: 5)
                            
                            Spacer()
                        }
                        .padding([.leading, .top], 15)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                // Show visible dishes
                                ForEach(visibleDishes, id: \.self) { dish in
                                    Button {
                                        Haptics.slide()
                                        withAnimation {
                                            selectedDish = dish
                                        }

                                        topRatedPage = 1
                                        trendingPage = 1

                                        Task {
                                            await vm.getTrendingDishesNearUser(
                                                limit: pageSize,
                                                category: dish == "All" ? nil : dish
                                            )
                                            
                                            await vm.getTopRatedDishesNearUser(
                                                limit: pageSize,
                                                category: dish == "All" ? nil : dish
                                            )
                                            
                                        }
                                        if dish != "All" {
                                            faveDish = dish
                                        }
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            dropDownHeight = 0.0
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showAllDishes = false
                                        }
                                    } label: {
                                        VStack(spacing: 10) {
                                            ZStack {
//                                                Circle()
//                                                    .foregroundStyle(selectedDish == dish ? Color.selectedDish : Color.filterWhite)
//                                                    .frame(height: 63)
                                                
                                                if  dish == "All" {
                                                    HStack(spacing: 3) {
                                                        VStack(spacing: 3) {
                                                            Circle().stroke(lineWidth: 1.5)
                                                                .foregroundStyle(.black)
                                                                .frame(width: 9, height: 10)
                                                            Circle().stroke(lineWidth: 1.5)
                                                                .foregroundStyle(.black)
                                                                .frame(width: 10, height: 10)
                                                        }
                                                        VStack(spacing: 3) {
                                                            Circle().stroke(lineWidth: 1.5)
                                                                .foregroundStyle(.black)
                                                                .frame(width: 10, height: 10)
                                                            Circle().stroke(lineWidth: 1.5)
                                                                .foregroundStyle(.black)
                                                                .frame(width: 14, height: 10)
                                                        }
                                                    }
                                                    .frame(width: 40, height: 40)
                                                } else {
                                                    Image(dish)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                }
                                            }
                                            
                                            Text(dish)
                                                .foregroundStyle(.black)
                                                .font(.system(size: 13))
                                                .opacity(selectedDish == dish ? 1 : 0.5)
                                            
                                            Rectangle()
                                                .foregroundStyle(.tastysRed)
                                                .frame(/*width: 50, */height: 2)
                                                .opacity(selectedDish == dish ? 1 : 0)
                                            
                                            
                                        }
                                        .padding(.horizontal, 6)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // See all button
                                Button {
                                    Haptics.slide()
                                    showAllDishes.toggle()
                                    
                                    withAnimation(.linear(duration: 0.5)) {
                                        dropDownHeight = 500.0
                                    }
                                } label: {
                                    VStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .foregroundStyle(Color.filterWhite)
                                                .frame(height: 63)
                                            
                                            Image("See all")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 35, height: 35)
                                        }
                                        
                                        Text("See all")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                        
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                // Recommend NavigationLink
                                Button {
                                    showRecommendSheet.toggle()
                                } label: {
                                    VStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .foregroundStyle(Color.filterWhite)
                                                .frame(height: 63)
                                            
                                            Image(systemName: "plus")
                                                .foregroundStyle(.tastysRed)
                                                .font(.system(size: 25))
                                        }
                                        
                                        Text("Recommend")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                        
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        }
                        
                        
                        
                        
                        VStack {
                            HStack(spacing: 2) {
                                Image("fireIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 27, height: 27)
                                
                                Text("Trending right now")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            
                            
                            HStack {
                                Text("Dishes people cant stop ordering")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .opacity(0.5)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                        
                        if vm.isLoadingCategory && vm.trendingDishes.isEmpty{
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(0..<2, id: \.self) { _ in
                                        DishCardSkeletonView()
                                            .shimmering()
                                            .frame(width: 180, height: 180)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            if filteredTrendingDishes.isEmpty {
                                VStack {
                                    Text("No trending dishes found")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 15))
                                        .italic()
                                        .padding(.vertical, 30)
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack {
                                        ForEach(Array(filteredTrendingDishes.enumerated()), id: \.element.id) { index, dish in
                                            GeometryReader { cardGeo in
                                                NavigationLink{
                                                    FoodDetailView(dishId: dish.id.uuidString, showTabButtons: $showTabButtons)
                                                        .environmentObject(vm)
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
                                                    
                                                    .environmentObject(vm)
                                                    
                                                }
                                                .gesture(
                                                    LongPressGesture(minimumDuration: 1.5)
                                                        .onEnded { _ in
                                                            let center = cardGeo.frame(in: .named("home")).midX
                                                            let midY = cardGeo.frame(in: .named("home")).midY
                                                            tapPosition = CGPoint(x: center, y: midY)
                                                            rotation = 0
                                                            self.dish = dish
                                                            showDishTap = true
                                                            withAnimation(.spring(duration: 0.5)) {
                                                                tapPosition = CGPoint(
                                                                    x: geo.size.width / 2,
                                                                    y: geo.size.height / 2
                                                                )
                                                                rotation = -5
                                                            }
                                                        }
                                                        .exclusively(before:
                                                                        TapGesture()
                                                            .onEnded {
                                                                selectedCardIndex = index
                                                            }
                                                                    )
                                                )
                                                
                                            }
                                            .frame(width: 180, height: 180)
                                            .onAppear {
                                                guard dish.id == filteredTrendingDishes.last?.id else { return }
                                                guard !isLoadingMoreTrending else { return }
                                                
                                                isLoadingMoreTrending = true
                                                trendingPage += 1
                                                
                                                Task {
                                                    await vm.getTrendingDishesNearUser(
                                                        limit: trendingPage * pageSize,
                                                        category: selectedDish == "All" ? nil : selectedDish
                                                    )
                                                    
                                                    isLoadingMoreTrending = false
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .scrollDismissesKeyboard(.interactively)
                                
                            }
                            
                        }
                        
                        
                        VStack(spacing: 20) {
                            VStack {
                                HStack(spacing: 2) {
                                    Image("starImage")
                                    
                                    Text("Highest rated near you")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    
                                }
                                HStack {
                                    Text("Top dishes loved by the Tasty’s communities")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .opacity(0.5)
                                    
                                    Spacer()
                                }
                                
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 20)
                            
                            if vm.isLoadingCategory && vm.topRatedDishes.isEmpty {
                                
                                
                                ScrollView(showsIndicators: false) {
                                    VStack {
                                        ForEach(0..<4) {_ in
                                            DishesRowSkeletonView()
                                        }
                                    }
                                }
                            } else {
                                if filteredTopRatedDishes.isEmpty {
                                    VStack {
                                        Text("No top dishes found")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 15))
                                            .italic()
                                            .padding(.vertical, 32)
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    LazyVStack {
//                                            HStack{
                                        ForEach(Array(filteredTopRatedDishes.enumerated()), id: \.element.id) { index, dish in
                                                VStack {
                                                    NavigationLink {
                                                        FoodDetailView(
                                                            dishId: dish.id.uuidString,
                                                            showTabButtons: $showTabButtons
                                                        )
                                                        .environmentObject(vm)
                                                        
                                                    } label: {
                                                        TopDishRow(
                                                            dish: dish,
                                                            rank: index + 1
                                                        )
                                                        .environmentObject(vm)
                                                    }
                                                    .onAppear {
                                                        guard dish.id == filteredTopRatedDishes.last?.id else { return }
                                                        guard !isLoadingMoreTopRated else { return }

                                                        isLoadingMoreTopRated = true
                                                        topRatedPage += 1

                                                        Task {
                                                            await vm.getTopRatedDishesNearUser(
                                                                limit: topRatedPage * pageSize,
                                                                category: selectedDish == "All" ? nil : selectedDish
                                                            )

                                                            isLoadingMoreTopRated = false
                                                        }
                                                    }
                                                    if index != vm.topRatedDishes.count - 1 {
                                                                Divider()
                                                                    .frame(height: 1)
                                                                    .background(Color.white)
                                                                    .padding(.horizontal, 10)
                                                            }
                                                }
//                                                    if vm.currentRestaurant?.topDishes.last {
                                                    
//                                                    }
                                            }
//                                            }
//                                            .padding(.leading, 15)
                                        
                                    }
                                    .padding(.horizontal, 14)
                                }
                                    
//                                    .padding(.vertical, 15)
//                                    .background {
//                                        RoundedRectangle(cornerRadius: 24)
////                                                .stroke(lineWidth: 0.5)
//                                            .foregroundStyle(.white)
////                                                .shadow(color: .black.opacity(0.12), radius: 9)
//                                    }
//                                    .padding(.horizontal, 16)
//                                }
                                
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                        if vm.isAuthenticated {
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                            }
                            .frame(height: 0)
                        }
                        
                    }
                    .refreshable {
                        topRatedPage = 1
                        trendingPage = 1

                        isLoadingMoreTopRated = false
                        isLoadingMoreTrending = false

                        let category = selectedDish == "All" ? nil : selectedDish

                        await vm.getTrendingDishesNearUser(
                            limit: pageSize,
                            category: category
                        )

                        await vm.getTopRatedDishesNearUser(
                            limit: pageSize,
                            category: category
                        )

                        await vm.getNotifications()

                        showFullTopRated = false
                        showFullFeed = false
                    }
//                    .gesture(
//                        DragGesture()
//                            .onEnded { value in
//                                let screenWidth = geo.size.width
//                                let fromLeftEdge = value.startLocation.x < screenWidth * 0.15
//                                let draggedRightEnough = value.translation.width > screenWidth * 0.25
//                                let mostlyHorizontal = abs(value.translation.height) < 30
//                                
//                                if fromLeftEdge && draggedRightEnough && mostlyHorizontal {
//                                    if showFullTopRated || showFullFeed {
//                                        Haptics.slide() // optional feedback
//                                        withAnimation(.easeInOut(duration: 0.4)) {
//                                            showFullTopRated = false
//                                            showFullFeed = false
//                                        }
//                                    }
//                                }
//                            }
//                    )
                }
                .blur(radius: showLocationCard || showRatingCard || showDishTap ? 7 : 0)
                .onTapGesture {
                    if showLocationCard || showRatingCard {
                        showLocationCard = false
                        showRatingCard = false
                    }
                }
                
                
                
                if showRatingCard {
                    VStack {
                        
                        HStack {
                            Spacer()
                            RatingPopUpView(isShowing: $showRatingCard)
                            Spacer()
                        }
                        
                        Spacer()
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
                
                if showAllDiets {
                    Color.black
                        .opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissDiets()
                        }
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            if !selectedDiet.isEmpty {
                                Button{
                                    Haptics.slide()
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedDiet = ""
                                        dietDropDownHeight = 0.0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAllDiets = false
                                    }
                                } label: {
                                    HStack(spacing: 15) {
                                        Image("plateUsername")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                        
                                        VStack(alignment: .leading) {
                                            Text("All")
                                                .foregroundStyle(selectedDiet == "" ? .white : .black)
                                                .font(.system(size: 15))
                                            
                                            Text("207+ Restaurants")
                                                .foregroundStyle(selectedDiet == "" ? .white : .black)
                                                .opacity(0.5)
                                                .font(.system(size: 10))
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundStyle(selectedDiet == "" ? Color.selectedDish : Color.filterWhite)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            ForEach(diets.filter { $0 != selectedDiet }, id: \.self) { diet in
                                Button {
                                    Haptics.slide()
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedDiet = diet
                                        dietDropDownHeight = 0.0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAllDiets = false
                                    }
                                } label: {
                                    HStack(spacing: 15) {
                                        Image(diet)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                        
                                        VStack(alignment: .leading) {
                                            Text(diet)
                                                .foregroundStyle(selectedDiet == diet ? .white : .black)
                                                .font(.system(size: 15))
                                            
                                            Text("207+ Restaurants")
                                                .foregroundStyle(selectedDiet == diet ? .white : .black)
                                                .opacity(0.5)
                                                .font(.system(size: 10))
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 23)
                                            .foregroundStyle(selectedDiet == diet ? Color.selectedDish : Color.filterWhite)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .zIndex(1)
                    .frame(maxHeight: dietDropDownHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .padding(.horizontal)
                    .offset(y: 100)
                    .scrollDismissesKeyboard(.interactively)
                    
                }
                
                // Dropdown for all dishes
                if showAllDishes {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            // All at the top
                            Button {
                                Haptics.slide()
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    selectedDish = "All"

                                    topRatedPage = 1
                                    trendingPage = 1

                                    Task {
                                        await vm.getTrendingDishesNearUser(
                                            limit: pageSize,
                                            category: nil
                                        )
                                        
                                        await vm.getTopRatedDishesNearUser(
                                            limit: pageSize,
                                            category: nil
                                        )
                                        
                                    }
                                    dropDownHeight = 0.0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showAllDishes = false
                                }
                            } label: {
                                HStack(spacing: 15) {
                                    ZStack {
                                        
                                        Image("plateUsername")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                    VStack (alignment: .leading) {
                                        Text("Showing All")
                                            .foregroundStyle(selectedDish == "All" ? .white : .black)
                                            .font(.system(size: 15))
                                        
                                        Text("207+ Restaurants")
                                            .foregroundStyle(selectedDish == "All" ? .white : .black)
                                            .opacity(0.5)
                                            .font(.system(size: 10))
                                    }
                                    
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundStyle(selectedDish == "All" ? Color.selectedDish : Color.filterWhite)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            // All other dishes
                            ForEach(dishes.filter { $0 != "All" }, id: \.self) { dish in
                                Button {
                                    Haptics.slide()
                                    
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        selectedDish = dish

                                        topRatedPage = 1
                                        trendingPage = 1

                                        Task {
                                            await vm.getTrendingDishesNearUser(
                                                limit: pageSize,
                                                category: dish == "All" ? nil : dish
                                            )
                                            
                                            await vm.getTopRatedDishesNearUser(
                                                limit: pageSize,
                                                category: dish == "All" ? nil : dish
                                            )

                                            
                                        }
                                        dropDownHeight = 0.0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAllDishes = false
                                    }
                                } label: {
                                    HStack(spacing: 15) {
                                        ZStack {
                                            
                                            Image(dish)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(dish)
                                                .foregroundStyle(selectedDish == dish ? .white : .black)
                                                .font(.system(size: 15))
                                            
                                            Text("207+ Restaurants")
                                                .foregroundStyle(selectedDish == dish ? .white : .black)
                                                .opacity(0.5)
                                                .font(.system(size: 10))
                                        }
                                        
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundStyle(selectedDish == dish ? Color.selectedDish : Color.filterWhite)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Recommend at the bottom
                            Button {
                                showRecommendSheet.toggle()
                            } label: {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(Color.filterWhite)
                                            .frame(height: 50)
                                        
                                        Image(systemName: "plus")
                                            .foregroundStyle(.tastysRed)
                                            .font(.system(size: 20))
                                    }
                                    
                                    Text("Recommend")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 15))
                                    
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                    }
                    .zIndex(1.0)
                    .frame(maxHeight: dropDownHeight)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .padding(.horizontal)
                    .offset(y: 150)
                    .scrollDismissesKeyboard(.interactively)
                }
                
                if showDishTap {
                    Color.black
                        .opacity(0.9)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDishTap = false
                        }
                    if let dishTap = dish {
                        DishCardTapView(dish: dishTap, restaurant:
                                            RestaurantDetails(
                                                id: dishTap.restaurantId ?? UUID(),
                                                name: dishTap.restaurantName ?? "",
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
                                       rating: Int(dishTap.rating ?? 50))
                            .position(tapPosition)
                            .rotationEffect(.degrees(rotation))
                    }
                    
                }
                
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { currentOffset in
                // currentOffset decreases when scrolling down, increases when scrolling up
                let directionIsUp = currentOffset > lastOffset
                
                // Only react if there's meaningful movement (avoids jitter at top/bottom)
                if abs(currentOffset - lastOffset) > 5 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showTabButtons = directionIsUp  // show when up, hide when down
                    }
                }
                
                lastOffset = currentOffset
            }
            .coordinateSpace(name: "home")
            .navigationBarBackButtonHidden()
            .onAppear {
                Haptics.prepare()
                Task {
                    await vm.getTrendingDishesNearUser(
                        limit: pageSize,
                        category: nil
                    )
                    
                    await vm.getTopRatedDishesNearUser(
                        limit: pageSize,
                        category: nil
                    )
                    await vm.getNotifications()

//                    await vm.loadFeedPosts()
                }
                selectedDiet = ""
                if !hasAskedLocation {
                    locManager.requestAuthorization()
                    hasAskedLocation = true
                }
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                    locManager.startUpdating()
                } else {
                    userLocation = "New York"
                }
            }
            .onChange(of: locManager.address) { oldValue, newValue in
                if let new = newValue {
                    userLocation = new
                }
            }
            .onChange(of: requireSignup) { oldValue, newValue in
                if newValue && !vm.isAuthenticated {
                    print("does require sign up")
                    dismiss()
//                    requireSignup = false
                } else {
                    print("does NOT require sign up")
                }
            }
            
            .sheet(isPresented: $showRecommendSheet) {
                RecommendFilterView()
                    .environmentObject(vm)
                    .presentationDetents([.fraction(1/2)])
            }
            
        }
    }
    
    private func dismissDiets() {
        Haptics.slide()
        withAnimation(.easeInOut(duration: 0.5)) {
            dietDropDownHeight = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showAllDiets = false
        }
    }
}



#Preview {
    NavigationStack {
        HomeView(showTabButtons: .constant(true))
            .environmentObject(HomeViewModel())
//        RestaurantDetailView(dishImage: "dishImage")
    }
}



struct TopDishRow: View {
    let dish: Dish
    let rank: Int
//    let onAdd: (Dish) -> Void
    @EnvironmentObject var vm: HomeViewModel
    @State private var showAddToPlate = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @Environment(\.dismiss) private var dismiss
    @State private var message = "You need to create an account first."
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    var body: some View {
        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: rank < 10 ? 30 : rank > 9 && rank < 100 ? 25 : 15))
                .fontWeight(rank > 99 ? .bold : .heavy )
                .foregroundStyle(rankForeground(for: rank - 1))
//                .frame(width: 40, height: 20, alignment: .leading)
            
            AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 35, height: 35)
                }
            }
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: 35, height: 35)
            
            VStack(alignment: .leading) {
                Text((dish.name).capitalized)
                    .foregroundStyle(.black)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(dish.ratingCount ?? 1) rating\(dish.ratingCount ?? 1 > 1 ? "s" : "")")
                    .foregroundStyle(.black.opacity(0.6))
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button{
                Haptics.revealDone()
                vm.currentDish = nil
                vm.breakdownDishId = dish.id.uuidString
                withAnimation(.easeInOut) {
                    vm.showRatingBreakdown.toggle()
                }
            } label: {
                ReuseableScoreBorderView(score: Int(dish.rating ?? 50))
                    .scaleEffect(0.88)
            }
            
            Button {
                Haptics.slide()
                if !vm.isAuthenticated {
                    message = "You need to create an account to add this dish to plates."
                    showAuthPopup = true
                } else {
                    showAddToPlate.toggle()
                }
            } label: {
                Image("bookmarkVector")
                    .renderingMode(.template)
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
//                    .padding(10)
                    .background {
                        Circle()
                            .foregroundStyle(.white)
                            .shadow(color: .grayTastys, radius: 4)
                            .frame(width: 35, height: 35)
                    }
            }
            .frame(width: 35, height: 35)
            .buttonStyle(.plain)
            
            Button {
                Haptics.slide()
                if !vm.isAuthenticated {
                    message = "You need to create an account to rate this dish"
                    showAuthPopup = true
                } else {
                    //                if let singleDish = dish {
                    vm.prefillRestaurant = RestaurantDetails(id: dish.restaurantId ?? UUID(),
                                                             name: dish.restaurantName ?? "",
                                                             image: nil, description: nil,
                                                             address: nil, website: nil,
                                                             telephone: nil,
                                                             createdAt: nil,
                                                             updatedAt: nil,
                                                             rank: nil,
                                                             rating: nil,
                                                             avgRating: nil,
                                                             totalRating: nil,
                                                             isBookmarked: false,
                                                             distanceKm: nil,
                                                             topDishes: nil)
                    vm.prefillDishes = [dish]
                    vm.showPostView = true
                    //                }
                }
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(.tastysRed)
                        .bold()
                    
                    
                }
//                .padding(12)
                .background {
                    Circle()
                        .foregroundStyle(.white)
                        .shadow(color: .grayTastys, radius: 4)
                        .frame(width: 35, height: 35)
                }
//                .padding(.horizontal, 10)
//                .padding(.bottom, 70) // adjust for tab bar / safe area
            }
            .frame(width: 35, height: 35)
            
            
        }
        .sheet(isPresented: $showAddToPlate) {
//            if let dish = dish {
                AddToPlateView(dishes: [dish])
                    .presentationDetents([.fraction(2.0 / 3.0)])
                    .environmentObject(vm)
//            } else {
//                // fallback – maybe empty view or error message
//                Text("Dish not loaded yet")
//                    .presentationDetents([.fraction(2.0 / 3.0)])
//            }
        }
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(message)
        }

    }
    
    private func rankForeground(for index: Int) -> AnyShapeStyle {
        switch index {
        case 0:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.first1, .first2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case 1:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.second1, .second2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case 2:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.third1, .third2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyShapeStyle(Color.black.opacity(0.4))
        }
    }
}
