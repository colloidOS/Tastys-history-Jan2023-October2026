//
//  NewRestaurantCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/05/2026.
//

import SwiftUI

struct NewRestaurantCardView: View {
    let restaurant: RestaurantDetails
    let restaurantScore: Int
    @State private var bottomColor: Color = .tastysRed
    @State private var isBookmarked: Bool
    @Binding var showTabButtons: Bool
    @EnvironmentObject var viewModel: HomeViewModel

    init(
            restaurant: RestaurantDetails,
            restaurantScore: Int,
            showTabButtons: Binding<Bool>
        ) {
            self.restaurant = restaurant
            self.restaurantScore = restaurantScore
            _isBookmarked = State(initialValue: restaurant.isBookmarked ?? false)
            _showTabButtons = showTabButtons
//            self.showTabButtons = showTabButtons
        }

    var body: some View {
//        ZStack(alignment: .bottom) {
            
//            .overlay(alignment: .topTrailing) {
                
//            }

        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 12) {
                
                CachedAsyncImage(
                    urlString: restaurant.image,
                    onImageLoaded: { image in
                        updateBottomColor(from: image, key: restaurant.image ?? "")
                    }
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                } placeholder: {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                }
                .clipShape(Circle())
                .frame(width: 70, height: 70)
                .clipped()
                .onAppear {
                    Haptics.prepare()
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10){
                            Text((restaurant.name).capitalized)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .lineLimit(1)
                            
                            HStack{
                                
                                ReuseableScoreBorderView(score: restaurantScore)
                                
                                Text("•")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                
                                Text("\(restaurant.totalRating ?? 0) rating\(restaurant.totalRating ?? 0 > 1 ? "s" : "")")
                                    .foregroundStyle(.black)
                                //                        .opacity(0.5)
                                    .font(.system(size: 12))
                                    .fontWeight(.medium)
                                Spacer()
                                
                                
                            }
                            
                            
                            
                            
                            
                        }
                        Spacer()
                        
                        Button {
                            Haptics.slide()
                            
                            let restaurantId = restaurant.id
                            let previousValue = isBookmarked
                            
                            // Immediately update UI
                            isBookmarked.toggle()
                            
                            Task {
                                let success: Bool
                                
                                if isBookmarked {
                                    success = await viewModel.addBookmarkedRestaurant(
                                        restaurantId: restaurantId
                                    )
                                } else {
                                    success = await viewModel.removeBookmarkedRestaurant(
                                        restaurantId: restaurantId
                                    )
                                }
                                
                                // Revert UI if database operation failed
                                if !success {
                                    await MainActor.run {
                                        isBookmarked = previousValue
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                Image(isBookmarked
                                      ? "bookmarkFill"
                                      : "bookmarkVector")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(
                                    isBookmarked ? Color.tastysRed : Color.black
                                )
                                .font(.system(size: 25))
                                .padding(13)
                                .background {
                                    Circle()
                                        .foregroundStyle(.white)
                                        .shadow(color: .grayTastys, radius: 4)
                                    //                                    .frame(width: 35, height: 35)
                                }
                                .frame(width: 40, height: 50)
                            }
                            .frame(height: 50)
                        }
                        .buttonStyle(.plain)
                        .padding([.trailing, .top], 5)
                    }
                    
                    HStack{
                        if let distance = restaurant.distanceKm {
                            Text(formattedDistance(distance))
                                .foregroundStyle(.black)
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                            
                            Text("•")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        if let address = restaurant.address {
                            let addressWithoutZip = address
                                .split(separator: " ")
                                .dropLast()
                                .joined(separator: " ")

                            Text(addressWithoutZip)
                                .foregroundStyle(.black)
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
//                        }
                        
                    }
                }
                
//                Spacer()
                
                
            }
            
            VStack(alignment: .leading){
                Text("Top rated dishes")
                    .foregroundStyle(.black)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(restaurant.topDishes ?? []) { dish in
                            NavigationLink{
                                FoodDetailView(dishId: dish.id.uuidString, showTabButtons: $showTabButtons)
                            } label: {
                                let dishModel = Dish(
                                    id: dish.id,
                                    name: dish.name,
                                    description: nil,
                                    categories: nil,
                                    createdAt: nil,
                                    updatedAt: nil,
                                    image: dish.image,
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
                                    rating: Int(dish.rating ?? 50),
                                    size: 150
                                )
//                                    .environmentObject(viewModel)
                            }
                        }
                        
                    }
                }
//                    .background(Color.yellow)
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
//            .padding(.leading, 5)
            .background{
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
        }
            
            
//        }
//        .padding(.trailing, 5)
        .padding(.vertical, 14)
        .padding(.horizontal, 7)
        .padding(.leading, 5)
        .background{
            Color.ashTastys
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        
//        .frame(height: 200)
        .onAppear {
            Haptics.prepare()

        }

    }
    func formattedDistance(_ distanceKm: Double) -> String {
        if distanceKm < 1 {
            return "<1 km"
        }

        return String(format: "%.1f km", distanceKm)
    }

    /// Reuses the UIImage CachedAsyncImage already downloaded/cached — no second
    /// network fetch — and caches the resulting color per-URL.
    private func updateBottomColor(from image: UIImage, key: String) {
        guard !key.isEmpty else { return }
        Task {
            if let cached = await ImageCacheManager.shared.cachedColor(for: key) {
                await MainActor.run { bottomColor = cached }
                return
            }
            if let color = await Self.dominantBottomColor(from: image) {
                await MainActor.run { bottomColor = color }
                await ImageCacheManager.shared.setColor(color, for: key)
            }
        }
    }

    private static func dominantBottomColor(from image: UIImage) async -> Color? {
        await Task.detached(priority: .utility) {
            let imageHeight = image.size.height
            let bottomRect = CGRect(
                x: 0,
                y: imageHeight * 0.7,
                width: image.size.width,
                height: imageHeight * 0.3
            )
            guard let uiColor = image.dominantDarkColor(from: bottomRect) else { return nil }
            return Color(uiColor: uiColor)
        }.value
    }
}

#Preview {
    NewRestaurantCardView(restaurant: RestaurantDetails(id: UUID(), name: "vkgckuc", image: "", description: "", address: "", website: "", telephone: "", createdAt: Date(), updatedAt: Date(), rank: 0.0, rating: 0.0, avgRating: 0.0, totalRating: 10, isBookmarked: false, distanceKm: nil, topDishes: nil), restaurantScore: 50, showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
}


struct NewRestaurantCardSkeletonView: View {
    var body: some View {
        HStack(spacing: 12) {
            
            // MARK: - Image skeleton
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 167, height: 101)
                .shimmering()
            
            // MARK: - Text section
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    // Restaurant name skeleton
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 18)
                        .shimmering()
                    
                    Spacer()
                    
                    // Bookmark button skeleton
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 42, height: 42)
                        .shimmering()
                }
                
                // Rating row skeleton
                HStack(spacing: 10) {
                    
                    // Score badge skeleton
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 22)
                        .shimmering()
                    
                    // Rating text skeleton
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 90, height: 14)
                        .shimmering()
                }
            }
            
            Spacer()
        }
        .padding(.trailing, 10)
        .padding(.vertical, 5)
        .frame(height: 120)
    }
}


//extension Double {
//    var formattedDistance: String {
//        if self < 1 {
//            return "<1 km"
//        }
//
//        return String(format: "%.1f km", self)
//    }
//}



struct OldRestaurantCardView: View {
    let restaurant: RestaurantDetails
    let restaurantScore: Int
    @State private var bottomColor: Color = .tastysRed
    @State private var isBookmarked: Bool
    @EnvironmentObject var viewModel: HomeViewModel

    init(
            restaurant: RestaurantDetails,
            restaurantScore: Int
        ) {
            self.restaurant = restaurant
            self.restaurantScore = restaurantScore
            _isBookmarked = State(initialValue: restaurant.isBookmarked ?? false)
        }

    var body: some View {
        ZStack(alignment: .bottom) {
            CachedAsyncImage(
                urlString: restaurant.image,
                onImageLoaded: { image in
                    updateBottomColor(from: image, key: restaurant.image ?? "")
                }
            ) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
            } placeholder: {
                Image("logoImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(width: UIScreen.main.bounds.width - 40, height: 200)
            .clipped()
            .onAppear {
                Haptics.prepare()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    Haptics.slide()

                    let restaurantId = restaurant.id
                    let previousValue = isBookmarked

                    // Immediately update UI
                    isBookmarked.toggle()

                    Task {
                        let success: Bool

                        if isBookmarked {
                            success = await viewModel.addBookmarkedRestaurant(
                                restaurantId: restaurantId
                            )
                        } else {
                            success = await viewModel.removeBookmarkedRestaurant(
                                restaurantId: restaurantId
                            )
                        }

                        // Revert UI if database operation failed
                        if !success {
                            await MainActor.run {
                                isBookmarked = previousValue
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Image(isBookmarked
                              ? "bookmarkFill"
                              : "bookmarkVector")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                            .foregroundStyle(
//                                isBookmarked ?
                                Color.white
//                                    : Color.black
                            )
                            .font(.system(size: 25))
                            .padding(13)
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
                            .frame(width: 40, height: 50)
                    }
                    .frame(height: 50)
                }
                .buttonStyle(.plain)
                .padding([.trailing, .top], 5)
            }

            VStack(alignment: .leading, spacing: 0){

//                VStack{
//                    HStack{
//
//                        Spacer()
//                    }
//                    Spacer()
//                }
//                .padding([.top, .horizontal], 6)


                HStack{
                    Text((restaurant.name).capitalized)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text("•")
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                    
                    Text("\(restaurant.totalRating ?? 0) rating\(restaurant.totalRating ?? 0 > 1 ? "s" : "")")
                        .foregroundStyle(.white)
//                        .opacity(0.5)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                    Spacer()


                }

                HStack{
                    if let distance = restaurant.distanceKm {
                        Text(formattedDistance(distance))
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                            .fontWeight(.medium)

                        Text("•")
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                    }

                    if let address = restaurant.address {
                        Text(address)
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }

                }

               

            }
            .padding(.vertical)
            .padding(.horizontal, 8)
            .frame(width: UIScreen.main.bounds.width - 40)
            .background{
                bottomColor
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .overlay(alignment: .topLeading) {
                ReuseableScoreBorderView(score: restaurantScore)
                    .padding(3)
                    .background{
                        bottomColor
                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                            .scaleEffect(0.8)
                    }
                    .offset(y: -23)
            }
        }
        .padding(.trailing, 10)
        .padding(.vertical, 5)
        .frame(height: 200)
        .onAppear {
            Haptics.prepare()

        }

    }
    func formattedDistance(_ distanceKm: Double) -> String {
        if distanceKm < 1 {
            return "<1 km"
        }

        return String(format: "%.1f km", distanceKm)
    }

    /// Reuses the UIImage CachedAsyncImage already downloaded/cached — no second
    /// network fetch — and caches the resulting color per-URL.
    private func updateBottomColor(from image: UIImage, key: String) {
        guard !key.isEmpty else { return }
        Task {
            if let cached = await ImageCacheManager.shared.cachedColor(for: key) {
                await MainActor.run { bottomColor = cached }
                return
            }
            if let color = await Self.dominantBottomColor(from: image) {
                await MainActor.run { bottomColor = color }
                await ImageCacheManager.shared.setColor(color, for: key)
            }
        }
    }

    private static func dominantBottomColor(from image: UIImage) async -> Color? {
        await Task.detached(priority: .utility) {
            let imageHeight = image.size.height
            let bottomRect = CGRect(
                x: 0,
                y: imageHeight * 0.7,
                width: image.size.width,
                height: imageHeight * 0.3
            )
            guard let uiColor = image.dominantDarkColor(from: bottomRect) else { return nil }
            return Color(uiColor: uiColor)
        }.value
    }
}
