//
//  RestaurantDetailView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/12/2025.
//

import SwiftUI

struct RestaurantDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bottomColor: Color = .tastysRed
    @State private var dishScore = 98
    @State private var selectedFeed = 1
    @State private var showComment = false
    @State private var showRatingCard = false
    @State private var showRatingDetail = false
    @State private var showAddToPlate = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    @State private var isLoading = false
    var restaurantId: String
    let dishImage: String  // This is actually restaurantImage URL; kept as per original
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    @State private var dishes = ["All", "Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    let allowedCategories: [String] = [
        "Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak",
        "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian",
        "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean",
        "Japanese", "Korean", "Greek", "Spanish", "American"
    ]
    let defaultTopCategories = ["Burgers", "Pizza", "Sushi", "Dessert"]
    @State private var selectedDish = "All"
    @State private var visibleCategories: [String] = ["All", "Burgers", "Pizza", "Sushi"] // default fallback
    var filteredDishes: [Dish] {
        guard let dishes = vm.currentRestaurant?.topDishes else { return [] }
        
        if selectedDish == "All" {
            return dishes
        }
        
        return dishes.filter { $0.categories?.first == selectedDish }
    }
    
    @State private var dish: Dish?
    var body: some View {
        let restaurant = vm.currentRestaurant?.restaurant
        ZStack {
            Color.white
                .ignoresSafeArea()
            // Image outside the ScrollView to properly ignore safe area
            
//            if let error = vm.errorMessage {
//                PopUpView(error: error)
//            }
            
            
            // Your content in ScrollView
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 17) {
                    if let imageUrl = vm.currentRestaurant?.restaurant.image {

                        ZStack(alignment: .bottomTrailing) {

                            let userImages = vm.currentRestaurant?.userImages
                                .compactMap { $0.image } ?? []

                            if userImages.isEmpty {

                                // MARK: - Restaurant image only

                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    switch phase {

                                    case .empty:
                                        Color.gray
                                            .opacity(0.2)
                                            .shimmering()

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()

                                    case .failure:
                                        Image("logoImage")
                                            .resizable()
                                            .scaledToFill()

                                    @unknown default:
                                        Color.gray
                                            .opacity(0.2)
//                                            .shimmering()
                                    }
                                }
                                .frame(maxWidth: UIScreen.main.bounds.width - 30)
                                .frame(height: 250)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            } else if userImages.count == 1 {

                                // MARK: - Restaurant + 1 user image

                                HStack(spacing: 2) {

                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {

                                        case .empty:
                                            Color.gray
                                                .opacity(0.2)
                                                .shimmering()

                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()

                                        case .failure:
                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFill()

                                        @unknown default:
                                            Color.gray
                                                .opacity(0.2)
//                                                .shimmering()
                                        }
                                    }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                    .frame(height: 250)
                                    .clipped()

                                    AsyncImage(url: URL(string: userImages[0])) { phase in
                                        switch phase {

                                        case .empty:
                                            Color.gray
                                                .opacity(0.2)
                                                .shimmering()

                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()

                                        case .failure:
                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFill()

                                        @unknown default:
                                            Color.gray
                                                .opacity(0.2)
//                                                .shimmering()
                                        }
                                    }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                    .frame(height: 250)
                                    .clipped()
                                }
                                .frame(maxWidth: UIScreen.main.bounds.width - 32)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            } else {

                                // MARK: - Restaurant + first 2 user images

                                HStack(spacing: 2) {

                                    // First column
                                    VStack(spacing: 2) {

                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                            switch phase {

                                            case .empty:
                                                Color.gray
                                                    .opacity(0.2)
                                                    .shimmering()

                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()

                                            case .failure:
                                                Image("logoImage")
                                                    .resizable()
                                                    .scaledToFill()

                                            @unknown default:
                                                Color.gray
                                                    .opacity(0.2)
//                                                    .shimmering()
                                            }
                                        }
                                        .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                        .frame(height: 128)
                                        .clipped()

                                        AsyncImage(url: URL(string: userImages[0])) { phase in
                                            switch phase {

                                            case .empty:
                                                Color.gray
                                                    .opacity(0.2)
                                                    .shimmering()

                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()

                                            case .failure:
                                                Image("logoImage")
                                                    .resizable()
                                                    .scaledToFill()

                                            @unknown default:
                                                Color.gray
                                                    .opacity(0.2)
                                                    .shimmering()
                                            }
                                        }
                                        .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                        .frame(height: 124)
                                        .clipped()
                                    }

                                    // Second column
                                    AsyncImage(url: URL(string: userImages[1])) { phase in
                                        switch phase {

                                        case .empty:
                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFill()

                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()

                                        case .failure:
                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFill()

                                        @unknown default:
                                            Color.gray
                                                .shimmering()
                                        }
                                    }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                    .frame(height: 250)
                                    .clipped()
                                }
                                .frame(maxWidth: UIScreen.main.bounds.width - 32)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            // MARK: - All Photos button

                            if !userImages.isEmpty {

                                if #available(iOS 26.0, *) {

                                    NavigationLink {
                                        RestaurantImagesView(
                                            restaurantId: vm.currentRestaurant?.restaurant.id.uuidString ?? "",
                                            showTabButtons: $showTabButtons
                                        )
                                    } label: {
                                        Text("view Gallery")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 8)
                                    }
                                    .buttonStyle(.plain)
                                    .glassEffect(
                                        .regular
                                            .tint(.black.opacity(0.65))
                                            .interactive(),
                                        in: RoundedRectangle(cornerRadius: 20)
                                    )
                                    .padding(10)

                                } else {

                                    NavigationLink {
                                        RestaurantImagesView(
                                            restaurantId: vm.currentRestaurant?.restaurant.id.uuidString ?? "",
                                            showTabButtons: $showTabButtons
                                        )
                                    } label: {
                                        Text("view Gallery")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 8)
                                            .background {
                                                ZStack {

                                                    bottomColor
                                                        .clipShape(
                                                            RoundedRectangle(cornerRadius: 20)
                                                        )
                                                        .opacity(0.75)

                                                    RoundedRectangle(cornerRadius: 21)
                                                        .foregroundStyle(.black)
                                                        .opacity(0.75)
                                                        .blur(radius: 38)
                                                        .clipped()
                                                        .clipShape(Circle())

                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(lineWidth: 1.0)
                                                        .foregroundStyle(.white)
                                                        .opacity(0.1)
                                                }
                                            }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(10)
                                }
                            }
                        }
                    }  else {
                        
                        let userImages = vm.currentRestaurant?.userImages
                            .compactMap { $0.image } ?? []

                        if userImages.isEmpty {

                            Image("logoImage")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width - 30)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                        } else if userImages.count == 1 {

                            // MARK: - 1 user image

                            AsyncImage(url: URL(string: userImages[0])) { phase in
                                switch phase {

                                case .empty:
                                    Color.gray
                                        .opacity(0.3)
                                        .shimmering()

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()

                                case .failure:
                                    Image("logoImage")
                                        .resizable()
                                        .scaledToFill()

                                @unknown default:
                                    Color.gray
                                        .shimmering()
                                }
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width - 30)
                            .frame(height: 250)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        } else if userImages.count == 2 {

                            // MARK: - 2 user images

                            HStack(spacing: 2) {

                                AsyncImage(url: URL(string: userImages[0])) { phase in
                                    switch phase {

                                    case .empty:
                                        Color.gray
                                            .opacity(0.3)
                                            .shimmering()

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()

                                    case .failure:
                                        Image("logoImage")
                                            .resizable()
                                            .scaledToFill()

                                    @unknown default:
                                        Color.gray
                                            .shimmering()
                                    }
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                .frame(height: 250)
                                .clipped()

                                AsyncImage(url: URL(string: userImages[1])) { phase in
                                    switch phase {

                                    case .empty:
                                        Color.gray
                                            .opacity(0.3)
                                            .shimmering()

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()

                                    case .failure:
                                        Image("logoImage")
                                            .resizable()
                                            .scaledToFill()

                                    @unknown default:
                                        Color.gray
                                            .shimmering()
                                    }
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                .frame(height: 250)
                                .clipped()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        } else {

                            // MARK: - 3+ user images
                            // First column = images 1 & 2
                            // Second column = image 3

                            HStack(spacing: 3) {

                                VStack(spacing: 2) {

                                    AsyncImage(url: URL(string: userImages[0])) { phase in
                                        switch phase {

                                        case .empty:
                                            Color.gray
                                                .opacity(0.3)
                                                .shimmering()

                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()

                                        case .failure:
                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFill()

                                        @unknown default:
                                            Color.gray
                                                .shimmering()
                                        }
                                    }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                    .frame(height: 124)
                                    .clipped()

                                    AsyncImage(url: URL(string: userImages[1])) { phase in
                                        switch phase {

                                        case .empty:
                                            Color.gray
                                                .opacity(0.3)
                                                .shimmering()

                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()

                                        case .failure:
                                            Image("logoImage")
                                                .resizable()
                                                .scaledToFill()

                                        @unknown default:
                                            Color.gray
                                                .shimmering()
                                        }
                                    }
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                    .frame(height: 124)
                                    .clipped()
                                }

                                AsyncImage(url: URL(string: userImages[2])) { phase in
                                    switch phase {

                                    case .empty:
                                        Color.gray
                                            .opacity(0.3)
                                            .shimmering()

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()

                                    case .failure:
                                        Image("logoImage")
                                            .resizable()
                                            .scaledToFill()

                                    @unknown default:
                                        Color.gray
                                            .shimmering()
                                    }
                                }
                                .frame(maxWidth: (UIScreen.main.bounds.width - 32) / 2)
                                .frame(height: 250)
                                .clipped()
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width - 32)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    HStack{
//                        VStack(alignment: .leading){
                            
                            
                            Text(restaurant?.name ?? "Restaurant")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
//                        }
//                        
                        Spacer()
                        
                        Button{
                            Haptics.slide()
                            showRatingDetail.toggle()
                        } label: {
                            VStack(alignment: .center, spacing: 10){
                                
                                ReuseableScoreBorderView(score: Int(restaurant?.rating ?? 0))
                                //                            }
                                //                                .scaleEffect(0.8)
                                
                                
                                HStack{
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                    
                                    Text(formatRatingCount(restaurant?.totalRating ?? 0))
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                        .fontWeight(.semibold)
                                    
                                }
                            }
                            .padding(.bottom, 7)
                            .background {
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 20,
                                    bottomLeadingRadius: 10,
                                    bottomTrailingRadius: 10,
                                    topTrailingRadius: 20
                                )
                                .stroke(lineWidth: 0.7)
                                .foregroundStyle(.black)
                                .opacity(0.2)
                            }
                        }
                    }
                    
                    Text(restaurant?.description ?? "")
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .opacity(0.6)
                    
                    HStack(spacing: 0) {
                        Text("\(vm.currentRestaurant?.totalVisits ?? 0)")
                            .foregroundStyle(.black)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                        
                        Text(" People Visited")
                            .foregroundStyle(.black)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .opacity(0.5)
                        
                    }
                    
                    
                    HStack{
                        Button{
                            Haptics.slide()
                            if let telephone = vm.currentRestaurant?.restaurant.telephone,
                               let url = URL(string: "tel:\(telephone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack{
                                Image("callIcon")
                                    .renderingMode(.template)
                                    .foregroundStyle(.black)
                                    .opacity(0.6)
                                    
                                
                                Text("call now")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .opacity(0.5)
                            }
                            .padding(10)
//                            .padding(.horizontal, 10)
                            .background{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 0.6)
                                        .foregroundStyle(.black)
                                        .opacity(0.4)
                                }
                                
                            }
                        }
                        
                        Button{
                            Haptics.slide()
                            if let address = vm.currentRestaurant?.restaurant.address,
                               let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                               let url = URL(string: "maps://?q=\(encoded)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack{
                                Image("directionIcon")
                                    .renderingMode(.template)
                                    .foregroundStyle(.black)
                                    
                                
                                Text("Direction")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .opacity(0.5)
                            }
                            .padding(10)
//                            .padding(.horizontal, 10)
                            .background{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 0.6)
                                        .foregroundStyle(.black)
                                        .opacity(0.4)
                                }
                                
                            }
                        }
                        
                        Button{
                            if let website = restaurant?.website,
                               let encoded = website.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                            let url = URL(string: encoded) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack{
                                Image(systemName: "cart")
//                                            .renderingMode(.template)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 13))
                                    .opacity(0.5)
                                    
                                
                                Text("Order")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .opacity(0.5)
                            }
                            .padding(10)
//                            .padding(.horizontal, 10)
                            .background{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 0.6)
                                        .foregroundStyle(.black)
                                        .opacity(0.4)
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                    if let address = restaurant?.address {
                        
                        HStack{
                            Text("Located at")
                                .foregroundStyle(.availableGreen)
                                .font(.system(size: 11))
                                .fontWeight(.medium)
                            
                            Image("locationIcon")
                            
                            Text(address)
                                .foregroundStyle(.black)
                                .font(.system(size: 11))
                                .fontWeight(.semibold)
                            
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    ZStack {
                        Color.white
                            .ignoresSafeArea()
                        VStack {
                            
                            
                            
                            
                            
                            VStack(alignment: .leading){
                                Text("Must Order")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
//                                    .padding(.leading, 15)
                                
                                Text("Explore \(vm.currentRestaurant?.restaurant.name ?? "restaurant")'s top rated dishes")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 13))
                                    .fontWeight(.regular)
//                                    .padding(.leading, 15)
                                    .padding(.bottom, 10)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(visibleCategories, id: \.self) { category in
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    selectedDish = category
                                                }
                                            } label: {
                                                VStack(spacing: 6) {
                                                    
                                                    if category == "All" {
                                                        HStack(spacing: 3) {
                                                            VStack(spacing: 3) {
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(.black)
                                                                    .frame(width: 7, height: 7)
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(.black)
                                                                    .frame(width: 7, height: 7)
                                                            }
                                                            VStack(spacing: 3) {
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(.black)
                                                                    .frame(width: 7, height: 7)
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(.black)
                                                                    .frame(width: 7, height: 7)
                                                            }
                                                        }
                                                        .frame(width: 40, height: 40)
                                                    } else {
                                                        Image(category)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 40, height: 40)
                                                    }
                                                    
                                                    Text(category)
                                                        .foregroundStyle(.black)
                                                        .font(.system(size: 14, weight: .regular))
//                                                        .opacity(selectedDish == category ? 1 : 0.8)
                                                        .foregroundStyle(bottomColor)
                                                    
                                                    Rectangle()
                                                        .fill(selectedDish == category ? .black : Color.clear)
                                                        .frame(height: 2)
                                                        .animation(.easeInOut(duration: 0.2), value: selectedDish)
                                                }
                                            }
                                        }
                                    }
//                                    .padding(.horizontal, 15)
                                }
                                
                                if vm.isLoading && ((vm.currentRestaurant?.topDishes.isEmpty) != nil) {
                                    
                                    
                                    ScrollView(showsIndicators: false) {
                                        VStack {
                                            ForEach(0..<4) {_ in
                                                DishesRowSkeletonView()
                                            }
                                        }
                                    }
                                } else {
                                    if !filteredDishes.isEmpty {
                                        VStack {
//                                            HStack{
                                                ForEach(Array(filteredDishes.enumerated()), id: \.element.id) { index, dish in
                                                    VStack {
                                                        NavigationLink {
                                                            FoodDetailView(
                                                                dishId: dish.id.uuidString,
                                                                showTabButtons: $showTabButtons
                                                            )
                                                            .environmentObject(vm)
                                                            
                                                        } label: {
                                                            DishesRow(
                                                                dish: dish,
                                                                rank: index + 1, // 🔥 1-based ranking
                                                                onAdd: { dish in
//                                                                    Task{
//                                                                        await vm.addBookmarkedRestaurant(restaurantId: UUID(uuidString: restaurantId) ?? UUID())
//                                                                    }
                                                                    self.dish = dish
                                                                    showAddToPlate.toggle()
                                                                }
                                                            )
                                                            .environmentObject(vm)
                                                        }
                                                        if index != filteredDishes.count - 1 {
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
                                        .padding(.vertical, 15)
                                        .background {
                                            RoundedRectangle(cornerRadius: 24)
//                                                .stroke(lineWidth: 0.5)
                                                .foregroundStyle(bottomColor)
//                                                .shadow(color: .black.opacity(0.12), radius: 9)
                                        }
//                                        .padding(.horizontal, 16)
                                    }
                                    
                                }
                            }
                            .padding(.vertical, 20)
                            
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                            }
                            .frame(height: 0)
                        }
                        
                        
                        
                        
                        
                    }
                }
                .padding(.horizontal, 15)
                .offset(y: -55)
                
            }
            .blur(radius: showRatingDetail ? 7 : 0)
            .onTapGesture {
                if showRatingDetail {
                    showRatingDetail = false
                }
                
            }
            
            
            
            if showRatingDetail {
                if let restaurant = vm.currentRestaurant {
                    Color.black
                        .opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showRatingDetail = false
                        }
                    VStack{
                        HStack {
                            Spacer()
                            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentRestaurant?.restaurant.name ?? "", type: .restaurant(restaurant))
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
            if vm.isUpdateLoading {
                bottomColor
                    .opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
            }
            
        }
        .onAppear{
            vm.restaurantPosts.removeAll()
            Haptics.prepare()
            vm.CurrentRestaurantId = restaurantId
        }
        .onDisappear{
            vm.CurrentRestaurantId = nil
        }
        .task {
            isLoading = true
            print("restaurant's id: \(restaurantId)")
            print("user's id: \(vm.session?.user.id.uuidString ?? "no user id")")
            await vm.fetchRestaurantDetail(restaurantId: restaurantId, userId: vm.session?.user.id.uuidString)
            await extractBottomColor(from: vm.currentRestaurant?.restaurant.image ?? dishImage)
            await vm.loadRestaurantImages(restaurantId: restaurantId)
//            await vm.loadRestaurantPosts(restaurantId: restaurantId)
            isLoading = false
        }
        .sheet(isPresented: $showAddToPlate) {
            if let dish = dish {
                AddToPlateView(dishes: [dish])
                    .presentationDetents([.fraction(2.0 / 3.0)])
                    .environmentObject(vm)
            } else {
                // fallback – maybe empty view or error message
                Text("Dish not loaded yet")
                    .presentationDetents([.fraction(2.0 / 3.0)])
            }
        }
        .onChange(of: selectedFeed) { newValue in
            var sortBy: String?
            if newValue == 1 {
                sortBy = "recent"
            } else {
                sortBy = "popular"
            }
            Task {
                await vm.loadRestaurantPosts(
                    restaurantId: restaurantId,
                    sortBy: sortBy,
                    refresh: true,
                    filterHighRated: newValue == 2
                )
            }
        }
        .onChange(of: vm.currentRestaurant?.topDishes) { dishes in
            guard let dishes = dishes else { return }
            
            let top = topCategories(from: dishes)
            
            visibleCategories = ["All"] + top
        }
        .onChange(of: requireSignup) { oldValue, newValue in
            if newValue && !vm.isAuthenticated {
                print("does require sign up")
                dismiss()
            } else {
                print("does NOT require sign up")
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
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need to create an account to bookmark this restaurant.")
        }
//        .navigationBarBackButtonHidden()
        .toolbar {
            
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    Haptics.slide()
                    if !vm.isAuthenticated {
                        showAuthPopup = true
                    } else {
                        Task{
                            await vm.addBookmarkedRestaurant(restaurantId: UUID(uuidString: restaurantId) ?? UUID())
                        }
                    }
                } label: {
                    Image("bookmarkIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(width: 23, height: 23)
                }
                .buttonStyle(.plain)
            }
        }
//        .enableSwipeBack()
//        .sheet(isPresented: $showRatingDetail) {
//            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentRestaurant?.restaurant.name ?? "")
//                .presentationDetents([.large])
//                .presentationDragIndicator(.visible)
//        }
        
    }
    
    func formatRatingCount(_ count: Int) -> String {
        if count > 9_999 {
            return "\(count / 1_000)k+"
        }
        
        return "\(count)"
    }
    
    func topCategories(from dishes: [Dish], limit: Int = 4) -> [String] {
        var counts: [String: Int] = [:]
        
        for dish in dishes {
            if let category = dish.categories?.first,
               allowedCategories.contains(category) {
                counts[category, default: 0] += 1
            }
        }
        
        // Sorted categories from data
        var result = counts
            .sorted { $0.value > $1.value }
            .map { $0.key }
        
        // 🔥 If empty → return default immediately
        if result.isEmpty {
            return defaultTopCategories
        }
        
        // 🔥 Fill up to limit using defaults (no duplicates)
        for def in defaultTopCategories {
            if result.count >= limit { break }
            if !result.contains(def) {
                result.append(def)
            }
        }
        
        return Array(result.prefix(limit))
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
    
    private var emoji: String {
        switch vm.currentRestaurant?.restaurant.rating ?? 0 {
        case 0...10:
            return "😊"
        case 11...69:
            return "🤢"
        case 70...79:
            return "🙂"
        case 80...94:
            return "😋"
        case 95...100:
            return "🤤"
        default:
            return "🙂"
        }
    }
    private func extractBottomColor(from imageUrlString: String?) async {
        guard let urlString = imageUrlString,
              let url = URL(string: urlString),
              !urlString.isEmpty else {
            // Fallback color if no valid URL
            await MainActor.run {
                withAnimation {
                    bottomColor = .gray.opacity(0.7)
                }
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let uiImage = UIImage(data: data) else {
                print("Could not create UIImage from downloaded data")
                return
            }
            
            // Extract color from bottom ~30%
            let imageHeight = uiImage.size.height
            let bottomRect = CGRect(
                x: 0,
                y: imageHeight * 0.7,
                width: uiImage.size.width,
                height: imageHeight * 0.3
            )
            
            if let bottomColorUI = uiImage.dominantDarkColor(from: bottomRect) {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.bottomColor = Color(uiColor: bottomColorUI)
                    }
                }
            }
        } catch {
            print("Failed to download or process image: \(error.localizedDescription)")
            await MainActor.run {
                withAnimation {
                    bottomColor = .gray.opacity(0.7) // fallback
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurantId: "", dishImage: "dishImage", showTabButtons: .constant(true))
            .environmentObject(HomeViewModel())
    }
}



// MARK: - Restaurant Detail Skeleton View (for RestaurantDetailView loading state)




struct DishesRow: View {
    let dish: Dish
    let rank: Int
    let onAdd: (Dish) -> Void
    
    @EnvironmentObject private var vm: HomeViewModel
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @Environment(\.dismiss) private var dismiss
    @State private var message = "You need to create an account to bookmark this restaurant."
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(rank)")
                .font(.system(size: 32))
                .fontWeight(.heavy)
                .foregroundStyle(rankForeground(for: rank - 1)) // Adjust for 1-based
            
            AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.ashTastys
                        .clipShape(Circle())
                        .frame(width: 37, height: 37)
                }
            }
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 37, height: 37)
            
            VStack(alignment: .leading) {
                Text((dish.name).capitalized)
                    .foregroundStyle(.white)
                    .font(.system(size: 17))
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(dish.ratingCount ?? 1) rating\(dish.ratingCount ?? 1 > 1 ? "s" : "")")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Spacer()
            
            ReuseableScoreBorderView(score: Int(dish.rating ?? 50))
            
            Button {
                Haptics.slide()
                if !vm.isAuthenticated {
                    showAuthPopup = true
                } else {
                    onAdd(dish)
                }
            } label: {
                Image("bookmarkVector")
                    .renderingMode(.template)
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
                    .padding(10)
                    .background {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .opacity(0.05)
                            
                            Circle()
                                .stroke(lineWidth: 1.3)
                                .foregroundStyle(.white)
                                .opacity(0.1)
                            
                            Circle()
                                .foregroundStyle(.black)
                                .opacity(0.06)
                                .blur(radius: 2.1)
                                .shadow(color: .black.opacity(0.06), radius: 8.8, x: 0, y: 2)
                            
                        }
//                            .shadow(color: .black.opacity(0.13), radius: 8.8, x: 0, y: 2)
                    }
            }
            .buttonStyle(.plain)
        }
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                requireSignup = true
                dismiss()  // Pops back to HomeView, which will then pop to SignupView via .onChange
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(message)
        }
//        .padding(.horizontal, 14)
//        .padding(.vertical, 10)
//        .background {
//            RoundedRectangle(cornerRadius: 24)
//                .stroke(lineWidth: 0.5)
//                .foregroundStyle(.black.opacity(0.1))
//                .shadow(color: .black.opacity(0.12), radius: 9)
//        }
//        .padding(.horizontal, 14)
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
            return AnyShapeStyle(Color.white)
        }
    }
}




struct OldRestaurantDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bottomColor: Color = .tastysRed
    @State private var dishScore = 98
    @State private var selectedFeed = 1
    @State private var showComment = false
    @State private var showRatingCard = false
    @State private var showRatingDetail = false
    @State private var showAddToPlate = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    @State private var isLoading = false
    var restaurantId: String
    let dishImage: String  // This is actually restaurantImage URL; kept as per original
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    @State private var dishes = ["All", "Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    let allowedCategories: [String] = [
        "Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak",
        "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian",
        "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean",
        "Japanese", "Korean", "Greek", "Spanish", "American"
    ]
    let defaultTopCategories = ["Burgers", "Pizza", "Sushi", "Dessert"]
    @State private var selectedDish = "All"
    @State private var visibleCategories: [String] = ["All", "Burgers", "Pizza", "Sushi"] // default fallback
    var filteredDishes: [Dish] {
        guard let dishes = vm.currentRestaurant?.topDishes else { return [] }
        
        if selectedDish == "All" {
            return dishes
        }
        
        return dishes.filter { $0.categories?.first == selectedDish }
    }
    
    @State private var dish: Dish?
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            // Image outside the ScrollView to properly ignore safe area
            GeometryReader { geometry in
                AsyncImage(url: URL(string: vm.currentRestaurant?.restaurant.image ?? dishImage)) { phase in
                    switch phase {
                    case .empty:
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 400)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
//                        Color.gray
//                            .frame(width: geometry.size.width, height: 400)
//                            .clipped()
//                            .ignoresSafeArea(edges: .top)
//                            .shimmering()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 400)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                    case .failure:
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 400)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
//                        Color.gray
//                            .frame(width: geometry.size.width, height: 400)
//                            .clipped()
//                            .ignoresSafeArea(edges: .top)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
//            if let error = vm.errorMessage {
//                PopUpView(error: error)
//            }
            
            
            // Your content in ScrollView
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Add spacing at top if needed for content
                    Color.clear.frame(height: 150)
                    
//                    VStack(alignment: .leading){
//                        Text("Most popular")
//                            .foregroundStyle(.white)
//                            .font(.system(size: 17))
//                            .fontWeight(.medium)
//
//                        Text("Restaurant profile")
//                            .foregroundStyle(.white)
//                            .font(.system(size: 20))
//                            .fontWeight(.bold)
//
//                    }
//                        .padding(10)
//                        .padding(.horizontal, 10)
//                        .padding(.trailing, 10)
//                        .background{
//                            ZStack{
//                                RoundedRectangle(cornerRadius: 25.0)
//                                    .foregroundStyle(.black)
//                                    .opacity(0.75)
//                                RoundedRectangle(cornerRadius: 25.0)
//                                    .foregroundStyle(.black)
//                                    .opacity(0.75)
//                                    .blur(radius: 38)
//
//                                RoundedRectangle(cornerRadius: 25.0)
//                                    .stroke(lineWidth: 1.0)
//                                    .foregroundStyle(.white)
//                                    .opacity(0.1)
//                            }
//                        }
//                        .padding(.horizontal, 15)
                    
//                    Text(vm.currentRestaurant?.restaurant.address ?? "")
//                        .foregroundStyle(.white)
//                        .font(.system(size: 17))
//                        .fontWeight(.medium)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 8)
                    
                    HStack {
                        Text((vm.currentRestaurant?.restaurant.name ?? "restaurant").capitalized)
                            .foregroundStyle(bottomColor)
                            .font(.system(size: 28))
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        
                        Spacer()
                        
                        Button{
                            Haptics.slide()
                            if let address = vm.currentRestaurant?.restaurant.address,
                               let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                               let url = URL(string: "maps://?q=\(encoded)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image("mapIcon")
                                .renderingMode(.template)
                                .foregroundStyle(.white)
                                .padding(10)
                                .background{
                                    ZStack{
                                        bottomColor
                                            .clipShape(Circle())
                                            .opacity(0.75)
                                        Circle()
                                            .foregroundStyle(.black)
                                            .opacity(0.75)
                                            .blur(radius: 38)
                                            .clipped()
                                            .clipShape(Circle())
                                        
                                        Circle()
                                            .stroke(lineWidth: 1.0)
                                            .foregroundStyle(.white)
                                            .opacity(0.1)
                                    }
                                    
                            }
                        }
                        
                        Button{
                            Haptics.slide()
                            if let telephone = vm.currentRestaurant?.restaurant.telephone,
                               let url = URL(string: "tel:\(telephone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image(systemName: "phone")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .padding(10)
                                .background{
                                    ZStack{
                                        bottomColor
//                                            .opacity(0.5)
                                            .clipShape(Circle())
                                            .opacity(0.75)
                                        Circle()
                                            .foregroundStyle(.black)
                                            .opacity(0.75)
                                            .blur(radius: 38)
                                            .clipped()
                                            .clipShape(Circle())
                                        
                                        Circle()
                                            .stroke(lineWidth: 1.0)
                                            .foregroundStyle(.white)
                                            .opacity(0.1)
                                    }
                                    
                            }
                        }
                        
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background{
                        LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.5), Color.white.opacity(0.8), Color.white, Color.white], startPoint: .top, endPoint: .bottom)
                    }
                    ZStack {
                        Color.white
                            .ignoresSafeArea()
                        VStack {
                            
                            if let restaurantRating = vm.currentRestaurant?.restaurant.rating {
                                
                                if restaurantRating > 10 {
                                    NavigationLink{
                                        if let topDishId = vm.currentRestaurant?.topDishes.first?.id.uuidString {
                                            FoodDetailView(dishId: topDishId, showTabButtons: $showTabButtons)
                                                .environmentObject(vm)
                                        } else {
                                            EmptyView()
                                        }
                                    } label: {
                                        HStack {
                                            Image("chefsKissIcon")
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("THE SIGNATURE DISH")
                                                    .foregroundStyle(.ashTastys)
                                                //                                            .opacity(0.6)
                                                    .font(.system(size: 12.5))
                                                    .fontWeight(.medium)
                                                
                                                
                                                Text((vm.currentRestaurant?.topDishes.first?.name ?? "dish").capitalized)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 17))
                                                    .fontWeight(.medium)
                                                    .lineLimit(2)
                                                
                                            }
                                            Spacer()
                                            
                                            AsyncImage(url: URL(string: vm.currentRestaurant?.topDishes.first?.image ?? "")) { phase in
                                                switch phase {
                                                case .empty:
                                                    Color.gradTastys
                                                        .shimmering()
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(width: 94, height: 74)
                                                    
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(width: 94, height: 74)
                                                case .failure:
                                                    Color.gradTastys
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(width: 94, height: 74)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            //                                    Image(systemName: "chevron.right")
                                            //                                        .foregroundStyle(.white)
                                            //                                        .opacity(0.6)
                                            //                                        .font(.system(size: 18))
                                            //                                        .fontWeight(.semibold)
                                            
                                        }
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 12)
                                        .background{
                                            bottomColor
                                            //                                        .opacity(0.12)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        }
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                            
                            HStack{
                                HStack {
                                    
                                    Button{
                                        Haptics.slide()
                                        showRatingDetail.toggle()
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("RESTAURANT RATING")
                                                .foregroundStyle(.white)
                                                .opacity(0.6)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if let restaurantRating = vm.currentRestaurant?.restaurant.rating {
                                                HStack {
                                                    if restaurantRating < 11 {
                                                        Text("New")
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 15))
                                                            .fontWeight(.medium)
                                                    } else {
                                                        Text("Rated \(Int((restaurantRating)))%")
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 11))
                                                            .fontWeight(.medium)
                                                    }
                                                    Spacer()
                                                    Text(emoji)
                                                    
                                                }
                                            } else {
                                                HStack {
                                                    Text("New")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 15))
                                                        .fontWeight(.medium)
                                                    
                                                    Spacer()
                                                    Text("😊")
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 6)
                                    }
                                    Spacer()
                                    
                                    
                                }
                                .padding(.horizontal, 8)
                                //                  .padding(.vertical, 12)
                                .frame(height: 111)
                                .background{
                                    bottomColor
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                //                  .padding(.horizontal, 15)
                                //                  .padding(.vertical, 8)
                                
//                                Button{
//                                    Haptics.slide()
//                                    showRatingDetail.toggle()
//                                } label: {
                                    HStack {
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("TOTAL VISITS")
                                                .foregroundStyle(.white)
                                                .opacity(0.6)
                                                .font(.system(size: 14))
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text("\(vm.currentRestaurant?.totalVisits ?? 0) People Visited")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .fontWeight(.medium)
                                                
                                                Spacer()
                                                
//                                                Image(systemName: "chevron.right")
//                                                    .foregroundStyle(.white)
//                                                    .opacity(0.6)
//                                                    .font(.system(size: 18))
//                                                    .fontWeight(.semibold)
                                                
                                            }
                                            
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 6)
                                        Spacer()
                                        
                                        
                                    }
                                    .frame(height: 111)
                                    .padding(.horizontal, 8)
                                    //                  .padding(.vertical, 12)
                                    .background{
                                        bottomColor
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
//                                }
                                //                  .padding(.horizontal, 15)
                                //                  .padding(.vertical, 8)
                            }
                            .padding(.horizontal, 15)
                            
                            VStack(alignment: .leading){
                                Text("Must Order")
                                    .foregroundStyle(bottomColor)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .padding(.leading, 15)
                                
                                Text("Explore \(vm.currentRestaurant?.restaurant.name ?? "restaurant")'s top rated dishes")
                                    .foregroundStyle(bottomColor)
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .padding(.leading, 15)
                                    .padding(.bottom, 10)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(visibleCategories, id: \.self) { category in
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    selectedDish = category
                                                }
                                            } label: {
                                                VStack(spacing: 6) {
                                                    
                                                    if category == "All" {
                                                        HStack(spacing: 3) {
                                                            VStack(spacing: 3) {
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(bottomColor)
                                                                    .frame(width: 10, height: 10)
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(bottomColor)
                                                                    .frame(width: 10, height: 10)
                                                            }
                                                            VStack(spacing: 3) {
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(bottomColor)
                                                                    .frame(width: 10, height: 10)
                                                                Circle().stroke(lineWidth: 1)
                                                                    .foregroundStyle(bottomColor)
                                                                    .frame(width: 10, height: 10)
                                                            }
                                                        }
                                                        .frame(width: 50, height: 50)
                                                    } else {
                                                        Image(category)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 50, height: 50)
                                                    }
                                                    
                                                    Text(category)
                                                        .foregroundStyle(bottomColor)
                                                        .font(.system(size: 14, weight: .regular))
//                                                        .opacity(selectedDish == category ? 1 : 0.8)
                                                        .foregroundStyle(bottomColor)
                                                    
                                                    Rectangle()
                                                        .fill(selectedDish == category ? bottomColor : Color.clear)
                                                        .frame(height: 2)
                                                        .animation(.easeInOut(duration: 0.2), value: selectedDish)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                }
                                
                                if vm.isLoading && ((vm.currentRestaurant?.topDishes.isEmpty) != nil) {
                                    
                                    
                                    ScrollView(showsIndicators: false) {
                                        VStack {
                                            ForEach(0..<4) {_ in
                                                DishesRowSkeletonView()
                                            }
                                        }
                                    }
                                } else {
                                    if !filteredDishes.isEmpty {
                                        VStack {
//                                            HStack{
                                                ForEach(Array(filteredDishes.enumerated()), id: \.element.id) { index, dish in
                                                    VStack {
                                                        NavigationLink {
                                                            FoodDetailView(
                                                                dishId: dish.id.uuidString,
                                                                showTabButtons: $showTabButtons
                                                            )
                                                            .environmentObject(vm)
                                                            
                                                        } label: {
                                                            DishesRow(
                                                                dish: dish,
                                                                rank: index + 1, // 🔥 1-based ranking
                                                                onAdd: { dish in
//                                                                    Task{
//                                                                        await vm.addBookmarkedRestaurant(restaurantId: UUID(uuidString: restaurantId) ?? UUID())
//                                                                    }
                                                                    self.dish = dish
                                                                    showAddToPlate.toggle()
                                                                }
                                                            )
                                                            .environmentObject(vm)
                                                        }
                                                        if index != filteredDishes.count - 1 {
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
                                        .padding(.vertical, 15)
                                        .background {
                                            RoundedRectangle(cornerRadius: 24)
//                                                .stroke(lineWidth: 0.5)
                                                .foregroundStyle(bottomColor)
//                                                .shadow(color: .black.opacity(0.12), radius: 9)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    
                                }
                            }
                            .padding(.vertical, 20)
                            
                            
//                            HStack{
//                                Button{
//                                    Haptics.slide()
//                                    selectedFeed = 1
//                                } label: {
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 25.0)
//                                            .foregroundStyle(selectedFeed == 1 ? .white : .clear)
//                                            .frame(height: 32)
//                                        Text("Recently posted")
//                                            .foregroundStyle(selectedFeed == 1 ? bottomColor : .white)
//                                            .font(.system(size: 12))
//                                            .fontWeight(.medium)
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
//                                            .foregroundStyle(selectedFeed == 2 ? .white : .clear)
//                                            .frame(height: 32)
//                                        Text("Top Rated Posts")
//                                            .foregroundStyle(selectedFeed == 2 ? bottomColor : .white)
//                                            .font(.system(size: 12))
//                                            .fontWeight(.medium)
//                                    }
//
//                                }
//                                .buttonStyle(.plain)
//                            }
//                            .padding(.vertical, 2)
//                            .background{
//                                Color.white
//                                    .opacity(0.2)
//                                    .clipShape(RoundedRectangle(cornerRadius: 25))
//                                    .shadow(color: Color.black.opacity(0.1), radius: 2)
//                            }
//                            .padding(.horizontal, 15)
//
//
//                            if vm.isLoading && vm.restaurantPosts.isEmpty {
//                                ForEach(0..<2) {_ in
//                                    FeedCardSkeletonView()
//                                        .shimmering()
//                                }
//                            } else {
//                                ForEach(vm.restaurantPosts) { post in
//                                    FeedCardView(post: post, showTabButtons: $showTabButtons)
//                                        .padding(.horizontal, 15)
//                                        .environmentObject(vm)
//                                }
//                            }
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                            }
                            .frame(height: 0)
                        }
                        
                        
                        
                        
                        
                    }
                }
                
            }
            .blur(radius: showRatingDetail ? 7 : 0)
            .onTapGesture {
                if showRatingDetail {
                    showRatingDetail = false
                }
                
            }
            
            
            
            if showRatingDetail {
                if let restaurant = vm.currentRestaurant {
                    Color.black
                        .opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showRatingDetail = false
                        }
                    VStack{
                        HStack {
                            Spacer()
                            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentRestaurant?.restaurant.name ?? "", type: .restaurant(restaurant))
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
            if vm.isUpdateLoading {
                bottomColor
                    .opacity(0.5)
                    .ignoresSafeArea()
                ProgressView()
            }
            
        }
        .onAppear{
            vm.restaurantPosts.removeAll()
            Haptics.prepare()
            vm.CurrentRestaurantId = restaurantId
        }
        .onDisappear{
            vm.CurrentRestaurantId = nil
        }
        .task {
            isLoading = true
            print("restaurant's id: \(restaurantId)")
            print("user's id: \(vm.session?.user.id.uuidString ?? "no user id")")
            await vm.fetchRestaurantDetail(restaurantId: restaurantId, userId: vm.session?.user.id.uuidString)
            await extractBottomColor(from: vm.currentRestaurant?.restaurant.image ?? dishImage)
//            await vm.loadRestaurantPosts(restaurantId: restaurantId)
            isLoading = false
        }
        .sheet(isPresented: $showAddToPlate) {
            if let dish = dish {
                AddToPlateView(dishes: [dish])
                    .presentationDetents([.fraction(2.0 / 3.0)])
                    .environmentObject(vm)
            } else {
                // fallback – maybe empty view or error message
                Text("Dish not loaded yet")
                    .presentationDetents([.fraction(2.0 / 3.0)])
            }
        }
        .onChange(of: selectedFeed) { newValue in
            var sortBy: String?
            if newValue == 1 {
                sortBy = "recent"
            } else {
                sortBy = "popular"
            }
            Task {
                await vm.loadRestaurantPosts(
                    restaurantId: restaurantId,
                    sortBy: sortBy,
                    refresh: true,
                    filterHighRated: newValue == 2
                )
            }
        }
        .onChange(of: vm.currentRestaurant?.topDishes) { dishes in
            guard let dishes = dishes else { return }
            
            let top = topCategories(from: dishes)
            
            visibleCategories = ["All"] + top
        }
        .onChange(of: requireSignup) { oldValue, newValue in
            if newValue && !vm.isAuthenticated {
                print("does require sign up")
                dismiss()
            } else {
                print("does NOT require sign up")
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
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need to create an account to bookmark this restaurant.")
        }
//        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {

                Text("Restaurant profile")
                    .foregroundStyle(.white)
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background{
                        ZStack{
                            bottomColor
                                .opacity(0.75)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.black)
                                .opacity(0.75)
                                .blur(radius: 38)
                                .clipped()
                            
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(.white)
                                .opacity(0.1)
                        }
                    }
            }
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    Haptics.slide()
                    if !vm.isAuthenticated {
                        showAuthPopup = true
                    } else {
                        Task{
                            await vm.addBookmarkedRestaurant(restaurantId: UUID(uuidString: restaurantId) ?? UUID())
                        }
                    }
                } label: {
                    Image("bookmarkVector")
                        .renderingMode(.template)
                        .foregroundStyle(.black)
                        .frame(width: 30, height: 30)
//                        .font(.system(size: 22))
//                        .fontWeight(.bold)
//                        .padding()
//                        .clipShape(Circle())
//                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
//        .enableSwipeBack()
//        .sheet(isPresented: $showRatingDetail) {
//            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentRestaurant?.restaurant.name ?? "")
//                .presentationDetents([.large])
//                .presentationDragIndicator(.visible)
//        }
        
    }
    
    func topCategories(from dishes: [Dish], limit: Int = 4) -> [String] {
        var counts: [String: Int] = [:]
        
        for dish in dishes {
            if let category = dish.categories?.first,
               allowedCategories.contains(category) {
                counts[category, default: 0] += 1
            }
        }
        
        // Sorted categories from data
        var result = counts
            .sorted { $0.value > $1.value }
            .map { $0.key }
        
        // 🔥 If empty → return default immediately
        if result.isEmpty {
            return defaultTopCategories
        }
        
        // 🔥 Fill up to limit using defaults (no duplicates)
        for def in defaultTopCategories {
            if result.count >= limit { break }
            if !result.contains(def) {
                result.append(def)
            }
        }
        
        return Array(result.prefix(limit))
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
    
    private var emoji: String {
        switch vm.currentRestaurant?.restaurant.rating ?? 0 {
        case 0...10:
            return "😊"
        case 11...69:
            return "🤢"
        case 70...79:
            return "🙂"
        case 80...94:
            return "😋"
        case 95...100:
            return "🤤"
        default:
            return "🙂"
        }
    }
    private func extractBottomColor(from imageUrlString: String?) async {
        guard let urlString = imageUrlString,
              let url = URL(string: urlString),
              !urlString.isEmpty else {
            // Fallback color if no valid URL
            await MainActor.run {
                withAnimation {
                    bottomColor = .gray.opacity(0.7)
                }
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let uiImage = UIImage(data: data) else {
                print("Could not create UIImage from downloaded data")
                return
            }
            
            // Extract color from bottom ~30%
            let imageHeight = uiImage.size.height
            let bottomRect = CGRect(
                x: 0,
                y: imageHeight * 0.7,
                width: uiImage.size.width,
                height: imageHeight * 0.3
            )
            
            if let bottomColorUI = uiImage.dominantDarkColor(from: bottomRect) {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.bottomColor = Color(uiColor: bottomColorUI)
                    }
                }
            }
        } catch {
            print("Failed to download or process image: \(error.localizedDescription)")
            await MainActor.run {
                withAnimation {
                    bottomColor = .gray.opacity(0.7) // fallback
                }
            }
        }
    }
}
