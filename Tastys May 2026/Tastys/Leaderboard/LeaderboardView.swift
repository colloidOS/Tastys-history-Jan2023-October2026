//
//  LeaderboardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/12/2025.
//

import SwiftUI
import Supabase

struct LeaderboardView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = LeaderboardViewModel()
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var selectedDish: Dish?
    @State private var options = ["Top", "Trending", "Restaurants", "Foodies"]
    @State private var selectedOption = "Top"
    
    @Binding var showTabButtons: Bool  // ← add this binding
        
        @State private var lastOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            if let error = vm.errorMessage {
                PopUpView(error: error)
            }
            VStack {
                Text("Leaderboard")
                    .foregroundStyle(.black)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
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
                                    .padding(.horizontal, 17)
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
                    .padding(.horizontal, 12)
                }
                
//                ZStack {
//                    Color.white
                    
//                    VStack {
//                        podiumView
//                            .allowsHitTesting(true)
//                            .zIndex(1000)
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                        
//                        // MARK: TRAPEZOID
//                        HStack(spacing: -5) {
//                            TrapezoidView(position: 2, width: 124, trapHeight: 22, rectHeight: 138, bottomWidth: 124, topWidth: 90)
//                                .offset(y: 20)
//                            
//                            TrapezoidView(position: 1, width: 163, trapHeight: 30, rectHeight: 193, bottomWidth: 163, topWidth: 100)
//                                .zIndex(1)
//                            
//                            TrapezoidView(position: 3, width: 124, trapHeight: 22, rectHeight: 138, bottomWidth: 124, topWidth: 90)
//                                .offset(y: 40)
//                        }
//                        Spacer()
//                    }
                    
                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 0) {
                            podiumView
//                                .allowsHitTesting(true)
//                                .zIndex(1000)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                        
                        
                        
                        
                            // MARK: TRAPEZOID
//                            HStack(spacing: -5) {
//                                TrapezoidView(position: 2, width: 124, trapHeight: 22, rectHeight: 138, bottomWidth: 124, topWidth: 90)
//                                    .offset(y: 20)
//                                
//                                TrapezoidView(position: 1, width: 163, trapHeight: 30, rectHeight: 193, bottomWidth: 163, topWidth: 100)
//                                    .zIndex(1)
//                                
//                                TrapezoidView(position: 3, width: 124, trapHeight: 22, rectHeight: 138, bottomWidth: 124, topWidth: 90)
//                                    .offset(y: 40)
//                            }
                            
//                            LinearGradient(colors: [.clear, .white, .white], startPoint: .top, endPoint: .bottom)
//                                .frame(height: 40)
//                                .allowsHitTesting(false)
                            
                            listView
//                        }
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                        }
                        .frame(height: 0)
                    }
                    .refreshable {
                        Task{
                            await vm.loadFor(option: selectedOption)
                        }
                    }
//                }
                
                if vm.isLoading {
                    ProgressView()
                }
            }
        }
        .onAppear{
            Haptics.prepare()
            showTabButtons = true
            Task{
                await vm.loadFor(option: selectedOption)
            }
        }
        .sheet(item: $selectedDish) { dish in
            AddToPlateView(dishes: [dish])
                .presentationDetents([.fraction(2.0 / 3.0)])
        }
        .navigationBarBackButtonHidden()
        .onChange(of: selectedOption) { _ in
            Task {
                await vm.loadFor(option: selectedOption)
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
        .task {
            await vm.loadFor(option: selectedOption)
        }
    }
    
    @ViewBuilder
    private var podiumView: some View {
        switch selectedOption {
        case "Top":
            TopDishesPodium(dishes: Array(vm.topDishes.prefix(3)), showTabButtons: $showTabButtons)
                .environmentObject(homeVM)
        case "Trending":
            TrendingDishesPodium(dishes: Array(vm.trendingDishes.prefix(3)), showTabButtons: $showTabButtons)
                .environmentObject(homeVM)
        case "Restaurants":
            TopRestaurantsPodium(restaurants: Array(vm.topRestaurants.prefix(3)), showTabButtons: $showTabButtons)
                .environmentObject(homeVM)
        case "Foodies":
            TopUsersPodium(users: Array(vm.topUsers.prefix(3)), showTabButtons: $showTabButtons)
                .environmentObject(homeVM)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        ZStack{
            Color.white
            switch selectedOption {
            case "Top":
                VStack {
                    ForEach(Array(vm.topDishes.dropFirst(3).enumerated()), id: \.offset) { index, dish in
                        NavigationLink {
                            FoodDetailView(dishId: dish.id, showTabButtons: $showTabButtons)
                                .environmentObject(homeVM)
                        } label: {
                            TopDishesRow(dish: dish, rank: index + 4) { topDish in
                                selectedDish = dishFrom(topDish: topDish)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            case "Trending":
                VStack {
                    ForEach(Array(vm.trendingDishes.dropFirst(3).enumerated()), id: \.offset) { index, dish in
                        NavigationLink {
                            FoodDetailView(dishId: dish.id, showTabButtons: $showTabButtons)
                                .environmentObject(homeVM)
                        } label: {
                            TrendingDishesRow(dish: dish, rank: index + 4) { trendingDish in
                                selectedDish = dishFrom(trendingDish: trendingDish)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            case "Restaurants":
                VStack {
                    ForEach(Array(vm.topRestaurants.dropFirst(3).enumerated()), id: \.offset) { index, restaurant in
                        NavigationLink{
                            RestaurantDetailView(restaurantId: restaurant.id, dishImage: restaurant.restaurantImage ?? "", showTabButtons: $showTabButtons)
                                .environmentObject(homeVM)
                        } label: {
                            TopRestaurantsRow(restaurant: restaurant, rank: index + 4)
                        }
                    }
                }
                .padding(.bottom, 30)
            case "Foodies":
                VStack {
                    ForEach(Array(vm.topUsers.dropFirst(3).enumerated()), id: \.offset) { index, user in
                        if user.id != homeVM.currentUser?.id.uuidString {
                            NavigationLink{
                                FriendProfileView(friendsUserId: user.id, showTabButtons: $showTabButtons)
                                    .environmentObject(homeVM)
                            } label: {
                                TopUsersRow(user: user, rank: index + 4)
                            }
                        } else {
                            TopUsersRow(user: user, rank: index + 4)
                        }
                    }
                }
                .padding(.bottom, 30)
            default:
                EmptyView()
            }
        }
    }
    private func dishFrom(trendingDish: TrendingDish) -> Dish? {
        guard let id = UUID(uuidString: trendingDish.dishId),
              let restaurantId = UUID(uuidString: trendingDish.restaurantId ?? "") else { return nil }
        return Dish(
            id: id,
            name: trendingDish.dishName ?? "",
            description: trendingDish.dishDescription,
            categories: trendingDish.dishCategories,
            createdAt: nil,
            updatedAt: nil,
            image: trendingDish.dishImage,
            restaurantId: restaurantId,
            restaurantName: trendingDish.restaurantName,
            avgRating: trendingDish.dishRating,
            ratingCount: trendingDish.ratingCount,
            rating: trendingDish.dishRating,
            sectionType: nil,
            tags: nil,
            diets: []
        )
    }
    private func dishFrom(topDish: TopDish) -> Dish? {
        guard let id = UUID(uuidString: topDish.dishId),
              let restaurantId = UUID(uuidString: topDish.restaurantId) else { return nil }
        return Dish(
            id: id,
            name: topDish.dishName,
            description: topDish.dishDescription,
            categories: topDish.dishCategories,
            createdAt: nil,
            updatedAt: nil,
            image: topDish.dishImage,
            restaurantId: restaurantId,
            restaurantName: topDish.restaurantName,
            avgRating: topDish.rating,
            ratingCount: nil,
            rating: topDish.rating, sectionType: nil,
            tags: nil,
            diets: []
        )
    }

}

#Preview {
    LeaderboardView(showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
}
// MARK: - Podium Views

struct trophyImage: View {
    var position: Int
    var body: some View {
        Image("Medal\(position)")
            .resizable()
            .scaledToFit()
            .frame(width: 54, height: 54)
            .padding(.top, 20)
//            .overlay(alignment: .top) {
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(
//                        LinearGradient(colors: [position == 1 ? .tastysRed : .white, position == 1 ? .tastysRed : .white, .clear], startPoint: .top, endPoint: .bottom)
//                            
//                    )
//                    .opacity(0.5)
//                    .blur(radius: 9)
//                    .frame(width: 54, height: 10)
////                    .offset(y: -5)
//            }
    }
}

struct TopDishesPodium: View {
    let dishes: [TopDish]
    @Binding var showTabButtons: Bool
    @EnvironmentObject var homeVM: HomeViewModel
//    var position: Int = 1
    var body: some View {
        HStack {
            if let second = dishes[safe: 1] {
                NavigationLink {
                    FoodDetailView(dishId: second.id, showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 2)
                        VStack(spacing: 12)  {
                            podiumImage(url: second.dishImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 2)
                                        .offset(y: -45)
                                }
                            
                            Text((second.dishName).capitalized)
                                .lineLimit(2)
                                .podiumTitle()
                            
                            Text((second.restaurantName).capitalized)
                                .lineLimit(2)
                                .podiumSubtitle()
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(second.rating))
                                
                                Text("\(second.ratingCount ?? 1) Rating\( second.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
//                    .offset(y: 50)
                }
            }
            Spacer()
            if let first = dishes[safe: 0] {
                NavigationLink {
                    FoodDetailView(dishId: first.id, showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 1)
                        VStack(spacing: 12) {
                            podiumImage(url: first.dishImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 1)
                                        .offset(y: -45)
                                }
                            
                            Text((first.dishName).capitalized)
                                .podiumTitle()
                            
                            Text((first.restaurantName).capitalized)
                                .podiumSubtitle()
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(first.rating))
                                Text("\(first.ratingCount ?? 1) Rating\( first.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 7))
                                    .opacity(0.5)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            Spacer()
            if let third = dishes[safe: 2] {
                NavigationLink {
                    FoodDetailView(dishId: third.id, showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 3)
                        VStack (spacing: 12){
                            podiumImage(url: third.dishImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 3)
                                        .offset(y: -45)
                                }
                            
                            Text((third.dishName).capitalized)
                                .podiumTitle()
                            //                            .offset(x: 5)
                            
                            Text((third.restaurantName).capitalized)
                                .podiumSubtitle()
                            //                            .offset(x: 5)
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(third.rating))
                                
                                Text("\(third.ratingCount ?? 1) Rating\( third.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                            }
                            //                            .offset(x: 5)
                        }
                        .padding(.horizontal, 5)
                    }
//                    .offset(y: 70)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func podiumImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                ZStack {
                    Color.ashTastys.opacity(0.7)
                        .clipShape(Circle())
                        .frame(width: 75, height: 75)
                    
                    Image("defaultFood")
                        .resizable()
                        .scaledToFit()
                    
                }
            }
        }
        .scaledToFit()
        .clipShape(Circle())
        .frame(width: 75, height: 75)
//        .overlay(alignment: .top) {
//            Image("Medal\(position)")
//                .padding(.top, 20)
//                .overlay(alignment: .top) {
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: [position == 1 ? .tastysRed : .white, position == 1 ? .tastysRed : .white, .clear], startPoint: .top, endPoint: .bottom)
//                                
//                        )
//                        .blur(radius: 9)
//                        .opacity(0.7)
//                        .frame(width: position == 1 ? 122 : 84, height: 50)
//                        .offset(y: -13)
//                }
//        }
    }
}

struct TrendingDishesPodium: View {
    let dishes: [TrendingDish]
    @Binding var showTabButtons: Bool
    @EnvironmentObject var homeVM: HomeViewModel
        var body: some View {
        HStack {
            if let second = dishes[safe: 1] {
                NavigationLink {
                    FoodDetailView(dishId: second.id, showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 2)
                        VStack(spacing: 12)  {
                            podiumImage(url: second.dishImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 2)
                                        .offset(y: -45)
                                }
                            
                            Text((second.dishName ?? "").capitalized)
                                .podiumTitle()
                            
                            Text((second.restaurantName ?? "").capitalized)
                                .podiumSubtitle()
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(second.dishRating ?? 50))
                                
                                Text("\(second.ratingCount ?? 1) Rating\( second.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                                
                            }
                        }
                        .padding(.horizontal, 5)
                    }
//                    .offset(y: 50)
                }
            }
            Spacer()
            if let first = dishes[safe: 0] {
                NavigationLink {
                    FoodDetailView(dishId: first.id, showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 1)
                        VStack(spacing: 12)  {
                            podiumImage(url: first.dishImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 1)
                                        .offset(y: -45)
                                }
                            
                            Text((first.dishName ?? "").capitalized)
                                .podiumTitle()
                                .zIndex(1000)
                            
                            Text((first.restaurantName ?? "").capitalized)
                                .podiumSubtitle()
                                .zIndex(1000)
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(first.dishRating ?? 50))
                                    .zIndex(1000)
                                Text("\(first.ratingCount ?? 1) Rating\( first.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 7))
                                    .opacity(0.5)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            Spacer()
            if let third = dishes[safe: 2] {
                NavigationLink {
                    FoodDetailView(dishId: third.id, showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 3)
                        VStack(spacing: 10)  {
                            podiumImage(url: third.dishImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 3)
                                        .offset(y: -45)
                                }
                            
                            Text((third.dishName ?? "").capitalized)
                                .podiumTitle()
                                .zIndex(1000)
                            
                            Text((third.restaurantName ?? "").capitalized)
                                .podiumSubtitle()
                                .zIndex(1)
                            VStack{
                                if third.dishRating == 0 {
                                    ReuseableScoreBorderView(score: 50)
                                        .zIndex(1000)
                                } else {
                                    ReuseableScoreBorderView(score: Int(third.dishRating ?? 50))
                                        .zIndex(1000)
                                }
                                Text("\(third.ratingCount ?? 1) Rating\( third.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
//                    .offset(y: 70)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func podiumImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                ZStack {
                    Color.ashTastys.opacity(0.7)
                        .clipShape(Circle())
                        .frame(width: 75, height: 75)
                    
                    Image("defaultFood")
                        .resizable()
                        .scaledToFit()
                    
                }
            }
        }
        .scaledToFit()
        .clipShape(Circle())
        .frame(width: 75, height: 75)
    }
}

struct TopRestaurantsPodium: View {
    let restaurants: [TopRestaurant]
    @Binding var showTabButtons: Bool
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        HStack {
            if let second = restaurants[safe: 1] {
                NavigationLink{
                    RestaurantDetailView(restaurantId: second.id, dishImage: second.restaurantImage ?? "", showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 2)
                        VStack(spacing: 12)  {
                            podiumImage(url: second.restaurantImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 2)
                                        .offset(y: -45)
                                }
                            
                            Text((second.restaurantName).capitalized)
                                .podiumTitle()
                            
                            Text((second.restaurantAddress ?? "").capitalized)
                                .podiumSubtitle()
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(second.rating))
                                
                                Text("\(second.ratingCount ?? 1) Rating\( second.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                            }
                        }
                        .padding(.horizontal, 6)
                    }
//                    .offset(y: 50)
                }
            }
            Spacer()
            if let first = restaurants[safe: 0] {
                NavigationLink{
                    RestaurantDetailView(restaurantId: first.id, dishImage: first.restaurantImage ?? "", showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 1)
                        VStack(spacing: 12)  {
                            podiumImage(url: first.restaurantImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 1)
                                        .offset(y: -45)
                                }
                            
                            Text((first.restaurantName).capitalized)
                                .podiumTitle()
                            
                            Text((first.restaurantAddress ?? "").capitalized)
                                .podiumSubtitle()
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(first.rating))
                                
                                Text("\(first.ratingCount ?? 1) Rating\( first.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
            Spacer()
            if let third = restaurants[safe: 2] {
                NavigationLink{
                    RestaurantDetailView(restaurantId: third.id, dishImage: third.restaurantImage ?? "", showTabButtons: $showTabButtons)
                        .environmentObject(homeVM)
                } label: {
                    ZStack {
                        PodiumBackground(position: 3)
                        VStack(spacing: 12)  {
                            podiumImage(url: third.restaurantImage)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 3)
                                        .offset(y: -45)
                                }
                            
                            Text((third.restaurantName).capitalized)
                                .podiumTitle()
                            //                            .offset(x: 5)
                            
                            Text((third.restaurantAddress ?? "").capitalized)
                                .podiumSubtitle()
                            //                            .offset(x: 5)
                            
                            VStack {
                                ReuseableScoreBorderView(score: Int(third.rating))
                                
                                Text("\(third.ratingCount ?? 1) Rating\( third.ratingCount ?? 1 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .opacity(0.5)
                            }
                            //                            .offset(x: 5)
                        }
                        .padding(.horizontal, 6)
                    }
//                    .offset(y: 70)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func podiumImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                ZStack {
                    Color.ashTastys.opacity(0.7)
                        .clipShape(Circle())
                        .frame(width: 75, height: 75)
                    
                    Image("defaultFood")
                        .resizable()
                        .scaledToFit()
                    
                }
                
            }
        }
        .scaledToFit()
        .clipShape(Circle())
        .frame(width: 71, height: 75)
    }
}

struct TopUsersPodium: View {
    let users: [TopUser]
    @Binding var showTabButtons: Bool
    @EnvironmentObject var homeVM: HomeViewModel
    var body: some View {
        HStack {
            if let second = users[safe: 1] {
                if second.id != homeVM.currentUser?.id.uuidString {
                    NavigationLink{
                        FriendProfileView(friendsUserId: second.id, showTabButtons: $showTabButtons)
                            .environmentObject(homeVM)
                    } label: {
                        ZStack {
                            PodiumBackground(position: 2)
                            VStack(spacing: 15)  {
                                podiumImage(url: second.avatar)
                                    .overlay(alignment: .top) {
                                        trophyImage(position: 2)
                                            .offset(y: -45)
                                    }
                                
                                Text(("\(second.firstName) \(second.lastName)").capitalized)
                                    .podiumTitle()
                                
                                Text("@\(second.username)")
                                    .podiumSubtitle()
                                
                                
                                //                    ReuseableScoreBorderView(score: Int(second.communityScore ?? 50)) // Or community score if available
                            }
                            .padding(.horizontal, 5)
                        }
//                        .offset(x: 12, y: 50)
                    }
                } else {
                    ZStack {
                        PodiumBackground(position: 2)
                        VStack(spacing: 15)  {
                            podiumImage(url: second.avatar)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 2)
                                        .offset(y: -45)
                                }
                            
                            Text(("\(second.firstName) \(second.lastName)").capitalized)
                                .podiumTitle()
                            
                            Text("@\(second.username)")
                                .podiumSubtitle()
                            
                            //                    ReuseableScoreBorderView(score: Int(second.communityScore ?? 50)) // Or community score if available
                        }
                        .padding(.horizontal, 7)
                    }
//                    .offset(x: 12, y: 50)
                }
            }
            Spacer()
            if let first = users[safe: 0] {
                if first.id != homeVM.currentUser?.id.uuidString {
                    NavigationLink{
                        FriendProfileView(friendsUserId: first.id, showTabButtons: $showTabButtons)
                            .environmentObject(homeVM)
                    } label: {
                        ZStack {
                            PodiumBackground(position: 1)
                            VStack(spacing: 15)  {
                                podiumImage(url: first.avatar)
                                    .overlay(alignment: .top) {
                                        trophyImage(position: 1)
                                            .offset(y: -45)
                                    }
                                
                                Text(("\(first.firstName) \(first.lastName)").capitalized)
                                    .podiumTitle()
                                
                                Text("@\(first.username)")
                                    .podiumSubtitle()
                                
                                //                    ReuseableScoreBorderView(score: first.dishRatingCount)
                            }
                            .padding(.horizontal, 5)
                        }
//                        .offset(x: 2, y: 7)
                    }
                } else {
                    ZStack {
                        PodiumBackground(position: 1)
                        VStack(spacing: 15)  {
                            podiumImage(url: first.avatar)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 1)
                                        .offset(y: -45)
                                }
                            
                            Text(("\(first.firstName) \(first.lastName)").capitalized)
                                .podiumTitle()
                            
                            Text("@\(first.username)")
                                .podiumSubtitle()
                            
                            //                    ReuseableScoreBorderView(score: first.dishRatingCount)
                        }
                        .padding(.horizontal, 5)
                    }
//                    .offset(x: 2, y: 7)
                }
            }
            Spacer()
            if let third = users[safe: 2] {
                if third.id != homeVM.currentUser?.id.uuidString {
                    NavigationLink{
                        FriendProfileView(friendsUserId: third.id, showTabButtons: $showTabButtons)
                            .environmentObject(homeVM)
                    } label: {
                        ZStack {
                            PodiumBackground(position: 3)
                            VStack(spacing: 15)  {
                                podiumImage(url: third.avatar)
                                    .overlay(alignment: .top) {
                                        trophyImage(position: 3)
                                            .offset(y: -45)
                                    }
                                
                                Text(("\(third.firstName) \(third.lastName)").capitalized)
                                    .podiumTitle()
                                //                                .offset(x: 5)
                                
                                Text("@\(third.username)")
                                    .podiumSubtitle()
                                //                                .offset(x: 5)
                            }
                            .padding(.horizontal, 5)
                        }
//                        .offset(y: 60)
                    }
                } else {
                    ZStack {
                        PodiumBackground(position: 3)
                        VStack(spacing: 15)  {
                            podiumImage(url: third.avatar)
                                .overlay(alignment: .top) {
                                    trophyImage(position: 3)
                                        .offset(y: -45)
                                }
                            
                            Text(("\(third.firstName) \(third.lastName)").capitalized)
                                .podiumTitle()
                            //                            .offset(x: 5)
                            
                            Text("@\(third.username)")
                                .podiumSubtitle()
                            //                            .offset(x: 5)
                            
                        }
                        .padding(.horizontal, 5)
                    }
//                    .offset(y: 60)
                }
            }
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func podiumImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                ZStack {
                    Color.ashTastys.opacity(0.7)
                        .clipShape(Circle())
                        .frame(width: 75, height: 75)
                    
                    Image("defaultFood")
                        .resizable()
                        .scaledToFit()
                    
                }
            }
        }
        .scaledToFit()
        .clipShape(Circle())
        .frame(width: 75, height: 75)
    }
}

// MARK: - Helper Modifiers

extension View {
    func podiumBadge() -> some View {
        self
            .padding(7)
            .background {
                ZStack {
                    Circle()
                        .foregroundStyle(.fakeWhite)
                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 1.79)
                    
                    Circle()
                        .stroke(lineWidth: 1.0)
                        .foregroundStyle(.white)
                }
            }
    }
    
    func podiumTitle() -> some View {
        self
            .foregroundStyle(.black)
            .font(.system(size: 17))
            .fontWeight(.medium)
            .lineLimit(2)
            .lineSpacing(3)
    }
    
    func podiumSubtitle() -> some View {
        self
            .foregroundStyle(.black)
            .opacity(0.5)
            .font(.system(size: 13))
            .fontWeight(.medium)
            .lineLimit(3)
            .lineSpacing(3)
    }
}

// MARK: - Updated Row Views

struct TopDishesRow: View {
    let dish: TopDish
    let rank: Int
    let onAdd: (TopDish) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundStyle(rankForeground(for: rank - 1)) // Adjust for 1-based
            
            AsyncImage(url: URL(string: dish.dishImage ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Image("logoImage")
                        .resizable()
                    //                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 37, height: 37)
                }
            }
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 37, height: 37)
            
            VStack(alignment: .leading) {
                Text((dish.dishName).capitalized)
                    .foregroundStyle(.black)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text((dish.restaurantName).capitalized)
                    .foregroundStyle(.black.opacity(0.5))
                    .font(.system(size: 11))
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Spacer()
            
            ReuseableScoreBorderView(score: Int(dish.rating))
            
            Button {
                Haptics.slide()
                onAdd(dish)
            } label: {
                Image("bookmarkVector")
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .padding(10)
                    .background {
                        Circle()
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.13), radius: 8.8, x: 0, y: 2)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 0.5)
                .foregroundStyle(.black.opacity(0.1))
                .shadow(color: .black.opacity(0.12), radius: 9)
        }
        .padding(.horizontal, 14)
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
            return AnyShapeStyle(Color.black.opacity(0.2))
        }
    }
}

struct TrendingDishesRow: View {
    let dish: TrendingDish
    let rank: Int
    let onAdd: (TrendingDish) -> Void
    
    var body: some View {
        HStack(spacing: 9) {
            Text("\(rank)")
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundStyle(rankForeground(for: rank - 1))
            
            AsyncImage(url: URL(string: dish.dishImage ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Image("logoImage").resizable()
                }
            }
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 41, height: 37)
            
            VStack(alignment: .leading) {
                Text((dish.dishName ?? "").capitalized)
                    .foregroundStyle(.black)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text((dish.restaurantName ?? "").capitalized)
                    .foregroundStyle(.black.opacity(0.5))
                    .font(.system(size: 11))
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
            
            Spacer()
            
            stackedAvatars(users: dish.ratedBy)
            
            Text("+ \(dish.ratingCount ?? 1) rated \nthis dish")
                .foregroundStyle(.black.opacity(0.5))
                .font(.system(size: 11))
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
            
            Button {
                Haptics.slide()
                onAdd(dish)
            } label: {
                Image("bookmarkVector")
                    .foregroundStyle(.black)
                    .font(.system(size: 22))
                    .padding(10)
                    .background {
                        Circle()
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.13), radius: 8.8, x: 0, y: 2)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 0.5)
                .foregroundStyle(.black.opacity(0.1))
                .shadow(color: .black.opacity(0.12), radius: 9)
        }
        .padding(.horizontal, 14)
    }
    
    @ViewBuilder
    private func stackedAvatars(users: [TrendingUserDTO]) -> some View {
        let visibleUsers = Array(users.prefix(3))
        ZStack(alignment: .leading) {
            if visibleUsers.count >= 3 {
                avatarView(url: visibleUsers[2].avatar, offset: -16, zIndex: 1)
            }
            if visibleUsers.count >= 2 {
                avatarView(url: visibleUsers[1].avatar, offset: -8, zIndex: 2)
            }
            if visibleUsers.count >= 1 {
                avatarView(url: visibleUsers[0].avatar, offset: 0, zIndex: 3)
            }
        }
    }
    
    @ViewBuilder
    private func avatarView(url: String?, offset: CGFloat, zIndex: Double) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                Image("logoImage").resizable()
            }
        }
        .scaledToFit()
        .frame(height: 30)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(lineWidth: 1.7)
                .foregroundStyle(.white)
        }
        .offset(x: offset)
        .zIndex(zIndex)
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
            return AnyShapeStyle(Color.black.opacity(0.2))
        }
    }
}

struct TopRestaurantsRow: View {
    let restaurant: TopRestaurant
    let rank: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundStyle(rankForeground(for: rank - 1))
            
            AsyncImage(url: URL(string: restaurant.restaurantImage ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Image("logoImage").resizable()
                }
            }
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 38, height: 37)
            
            VStack(alignment: .leading) {
                Text((restaurant.restaurantName).capitalized)
                    .foregroundStyle(.black)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .lineLimit(3)
                
                if let categories = restaurant.restaurantDescription?.components(separatedBy: ", ").prefix(2) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            if category != "" {
                                Text(category)
                                    .foregroundStyle(.black.opacity(0.5))
                                    .font(.system(size: 11))
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(.fakeWhite)
                                    }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            
            ReuseableScoreBorderView(score: Int(restaurant.rating))
            
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 0.5)
                .foregroundStyle(.black.opacity(0.1))
                .shadow(color: .black.opacity(0.12), radius: 9)
        }
        .padding(.horizontal, 14)
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
            return AnyShapeStyle(Color.black.opacity(0.2))
        }
    }
}

struct TopUsersRow: View {
    let user: TopUser
    let rank: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundStyle(rankForeground(for: rank - 1))
            
            AsyncImage(url: URL(string: user.avatar ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Image("logoImage").resizable()
                }
            }
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 37, height: 37)
            
            VStack(alignment: .leading) {
                Text(("\(user.firstName) \(user.lastName)").capitalized)
                    .foregroundStyle(.black)
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("Rated \(user.dishRatingCount) Meals")
                    .foregroundStyle(.black.opacity(0.5))
                    .font(.system(size: 11))
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            stackedAvatars(restaurants: user.restaurants)
            
            Text("+ \(user.restaurantVisitedCount) restaurants visited")
                .font(.system(size: 9))
                .foregroundStyle(.black)
                .lineLimit(1)
                .padding(6)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 23)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.13), radius: 8.8, x: 0, y: 2)
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(lineWidth: 1.0)
                            .foregroundStyle(.white)
                    }
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 0.5)
                .foregroundStyle(.black.opacity(0.1))
                .shadow(color: .black.opacity(0.12), radius: 9)
        }
        .padding(.horizontal, 14)
    }
    
    @ViewBuilder
    private func stackedAvatars(restaurants: [SimpleRestaurant]) -> some View {
        let visible = Array(restaurants.prefix(3))
        ZStack(alignment: .leading) {
            if visible.count >= 3 {
                avatarView(url: visible[2].restaurantImage, offset: -20, zIndex: 1)
            }
            if visible.count >= 2 {
                avatarView(url: visible[1].restaurantImage, offset: -13, zIndex: 2)
            }
            if visible.count >= 1 {
                avatarView(url: visible[0].restaurantImage, offset: -5, zIndex: 3)
            }
        }
    }
    
    @ViewBuilder
    private func avatarView(url: String?, offset: CGFloat, zIndex: Double) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            if let image = phase.image {
                image.resizable()
            } else {
                Image("logoImage").resizable()
            }
        }
        .scaledToFit()
        .frame(height: 30)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(lineWidth: 1.7)
                .foregroundStyle(.white)
        }
        .offset(x: offset)
        .zIndex(zIndex)
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
            return AnyShapeStyle(Color.black.opacity(0.2))
        }
    }
}

// Safe array access
//extension Array {
//    subscript(safe index: Index) -> Element? {
//        indices.contains(index) ? self[index] : nil
//    }
//}


struct PodiumBackground: View {
    let position: Int // 1, 2, 3

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 23)
                .fill(gradient)
                .opacity(0.5)
            
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 1)
                .fill(
                    LinearGradient(colors: position == 1 ? [.tastysRed, .tastysRed, .white] : [.white], startPoint: .top, endPoint: .bottom)
                
                )
                .opacity(0.5)
        }
        .frame(height: 305)
        
    }

    private var gradient: LinearGradient {
        switch position {
        case 1:
            return LinearGradient(
                colors: [.barChart1, .barChart1, .white],
                startPoint: .top,
                endPoint: .bottom
            )
        case 2:
            return LinearGradient(
                colors: [.white, .white, .white],
                startPoint: .top,
                endPoint: .bottom
            )
        case 3:
            return LinearGradient(
                colors: [.white, .white, .white],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
        }
    }
}



struct Trapezoid: Shape {
    let bottomWidth: CGFloat
    let topWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let height: CGFloat = rect.height  // Use the view's height
        
        let inset = (bottomWidth - topWidth) / 2
        
        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: height))
        
        // Bottom right
        path.addLine(to: CGPoint(x: bottomWidth, y: height))
        
        // Top right
        path.addLine(to: CGPoint(x: bottomWidth - inset, y: 0))
        
        // Top left
        path.addLine(to: CGPoint(x: inset, y: 0))
        
        // Close back to bottom left
        path.closeSubpath()
        
        return path
    }
}

struct TrapezoidView: View {
    var position: Int
    var width: CGFloat
    var trapHeight: CGFloat
    var rectHeight: CGFloat
    var bottomWidth: CGFloat
    var topWidth: CGFloat
    var body: some View {
        ZStack {
            VStack(spacing: 1){
                
                Trapezoid(bottomWidth: bottomWidth, topWidth: topWidth)
                    .fill(
                        LinearGradient(colors: [position == 1 ? .trapFirst1 : position == 3 ? .trapThird1 : .trapWhite1, position == 1 ? .trapFirst2 : position == 3 ? .trapThird2 : .trapWhite2], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: width, height: trapHeight)
                
                Rectangle()
                    .fill(
                        LinearGradient(colors: [position == 1 ? .firstPlaceTastys : position == 3 ? .thirdPlaceTastys : .plateWhite, .white], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: width, height: rectHeight)
                
                
            }
            
            Image("Medal\(position)")
                .padding(.top, 20)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [position == 1 ? .firstPlaceTastys : position == 3 ? .thirdPlaceTastys : .plateWhite, position == 1 ? .firstPlaceTastys/*.opacity(0.8)*/ : position == 3 ? .thirdPlaceTastys/*.opacity(0.8)*/ : .plateWhite/*.opacity(0.95)*/], startPoint: .top, endPoint: .bottom)
                                
                        )
                        .blur(radius: 9)
//                        .opacity(0.6)
                        .frame(width: position == 1 ? 122 : 84, height: 50)
                        .offset(y: -13)
                }
            
            
            
            
            
//                .foregroundStyle(.black)
//                .opacity(0.2)
//                .font(.system(size: 49))
//                .fontWeight(.heavy)
            
        }
    }
}









