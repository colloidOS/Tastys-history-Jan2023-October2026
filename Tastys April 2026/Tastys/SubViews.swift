//
//  SubViews.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/12/2025.
//

import SwiftUI
import SafariServices

struct SubViews: View {
    var body: some View {
        ZStack{
            HalfStrokedCircleView(
                percentages: [15, 20, 45, 20],
                colors: [.red, .orange, .green, .blue]
            )
            .frame(height: 120)

        }
    }
}

#Preview {
//    SubViews()
    NavigationStack {
        VStack{
//            SearchDishesView()
            PopUpView(error: "fvghbhg")
            ReuseableScoreBorderView(score: 0)
        }
        
    }
//    ReuseableScoreBorderView(score: 80)

    
}


struct ReuseableScoreBorderView: View {
    var score: Int

    private var style: (bg: Color, stroke: Color) {
        switch score {
        case 0...10:
            return (.rating95, .ratingStroke95)
        case 11...69:
            return (.rating50, .ratingStroke50)
        case 70...79:
            return (.rating70, .ratingStroke70)
        case 80...94:
            return (.rating80, .ratingStroke80)
        case 95...100:
            return (.rating95, .ratingStroke95)
        default:
            return (.rating50, .ratingStroke50)
        }
    }

    private var emoji: String {
        switch score {
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

    var body: some View {
        HStack(spacing: 2) {
            Text(emoji)
                .font(.system(size: 14))
            
            if score < 11 {
                Text("New")
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
            } else {
                Text("\(score)%")
                    .foregroundStyle((score >= 70 && score <= 79) ? .black : .white)
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, score < 11 ? 15 : 10)
        .padding(.vertical, 8)
        .background(style.bg)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(style.stroke, lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}




struct ArcSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}


struct HalfStrokedCircleView: View {
    let percentages: [Double]   // must sum to 100
    let colors: [Color]

    private let lineWidth: CGFloat = 10
    private let spacing: CGFloat = 26   // 👈 your spacing

    var body: some View {
        GeometryReader { geo in
            let radius = geo.size.width / 2
            let totalAngle = 180.0
            let startBase = -180.0

            // Convert spacing (points) → degrees
            let gapAngle = Double(spacing / radius) * (180 / .pi)

            ZStack {
                ForEach(percentages.indices, id: \.self) { index in
                    let usedBefore = percentages.prefix(index).reduce(0, +)
                    let startAngle =
                        startBase
                        + totalAngle * usedBefore / 100
                        + gapAngle / 2

                    let segmentAngle =
                        totalAngle * percentages[index] / 100
                        - gapAngle

                    ArcSegment(
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(startAngle + max(segmentAngle, 0))
                    )
                    .stroke(
                        colors[index],
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                }
            }
        }
        .aspectRatio(2, contentMode: .fit)
    }
}


struct ErrorWithTryAgainView: View {
    @Binding var errorMessage: String?
    let retryAction: () -> Void
    
//    init(errorMessage: String?, retryAction: @escaping () -> Void = {}) {
//        self.errorMessage = errorMessage
//        self.retryAction = retryAction
//    }
    
    var body: some View {
        if let err = errorMessage {
            VStack {
                HStack(spacing: 20){
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                    
                    Button{
                        retryAction()
                    } label:{
                        Image(systemName: "arrow.trianglehead.counterclockwise")
                            .foregroundStyle(.white)
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .background{
                                Circle()
                                    .foregroundStyle(.tastysRed)
                                    .frame(width: 25, height: 25)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Button{
//                        errorMessage = nil
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                    }
                    .padding(5)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 25)
                .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                .transition(.move(edge: .top).combined(with: .opacity))
            Spacer()
            }
            .zIndex(1)
        }
    }
}

struct PopUpView: View {
    var error: String
    var body: some View {
        VStack {
            Text(error)
                .foregroundStyle(.white)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .padding(.vertical, 11)
                .padding(.horizontal, 25)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.tastysRed)
                )
                .shadow(
                    color: .black.opacity(0.12),
                    radius: 28,
                    x: 0,
                    y: 3.95
                )
            Spacer()
        }
        .zIndex(2)
    }
}





struct ProfileTabAvatar: View {
    let avatarURL: String
    let isSelected: Bool

    var body: some View {
        Group {
            if let url = URL(string: avatarURL), !avatarURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure(_):
                        fallbackIcon

                    case .empty:
                        ShimmerAvatar()

                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .frame(width: 35, height: 35)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(isSelected ? Color.tastysRed : Color.clear, lineWidth: 2)
        )
    }

    private var fallbackIcon: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(.gray.opacity(0.9))
    }
}


struct ShimmerAvatar: View {
    var body: some View {
        Circle()
            .fill(Color.grayTastys.opacity(0.6))
            .shimmering()
    }
}


struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safari = SFSafariViewController(url: url)
        safari.preferredControlTintColor = UIColor(named: "tastysRed") // optional
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}


struct WebLink: Identifiable {
    let id = UUID()
    let url: URL
}





struct PreviousDishCardView: View {
    let dish: Dish
    let restaurant: RestaurantDetails
    let rating: Int
    
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var bottomColor: Color = .tastysRed
    @State private var dishScore: Int
    @State private var showAddToPlateSheet: Bool = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    init(dish: Dish, restaurant: RestaurantDetails, rating: Int) {
        self.dish = dish
        self.restaurant = restaurant
        self.rating = rating
        _dishScore = State(initialValue: rating)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(width: 177, height: 224)
            .onAppear {
                Haptics.prepare()
                if let imageUrl = dish.image {
                    extractBottomColor(from: imageUrl)
                }
            }
            VStack{
                HStack{
                    
                    Spacer()
                }
                Spacer()
            }
            .padding([.top, .horizontal], 6)
            // Text with extracted bottom color and gradient fade
            VStack {
                HStack {
                    Button{
                        Haptics.revealDone()
                        viewModel.currentDish = nil
                        viewModel.breakdownDishId = dish.id.uuidString
                        withAnimation(.easeInOut) {
                            viewModel.showRatingBreakdown.toggle()
                        }
                    } label: {
                        ReuseableScoreBorderView(score: rating)
                            .scaleEffect(0.8)
                            .offset(y: 20)
                    }
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text((dish.name).capitalized)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text((restaurant.name).capitalized)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button{
                        Haptics.revealDone()
                        if !viewModel.isAuthenticated {
                            showAuthPopup = true
                        } else {
                            showAddToPlateSheet.toggle()
                        }
                    } label: {
                        Image("bookmarkVector")
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
                        .frame(height: 38)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom)
                .padding(.horizontal, 8)
                .frame(width: 177)
                .background(
                    ZStack {
                        // Base solid layer with gradient fade
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: bottomColor.opacity(0.05), location: 0.0),
                                .init(color: bottomColor.opacity(0.85), location: 0.5),
                                .init(color: bottomColor.opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Background blur layer
                        bottomColor
                            .opacity(0.7)
                            .blur(radius: 37.1)
                        
                        // Additional layer blur for depth
                        bottomColor
                            .opacity(0.5)
                            .blur(radius: 40)
                    }
                )
                .padding(.top)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .shadow(radius: 4)
        .frame(width: 177, height: 224)
        .sheet(isPresented: $showAddToPlateSheet) {
            AddToPlateView(dishes: [dish])
                .presentationDetents([.fraction(2.0 / 3.0)])
                .environmentObject(viewModel)
        }
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need to create an account to add this dish to plates.")
        }
    }
    private var emoji: String {
        switch rating {
        case 0...69:
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
    private func extractBottomColor(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    let imageHeight = uiImage.size.height
                    let bottomRect = CGRect(x: 0,
                                            y: imageHeight * 0.7,
                                            width: uiImage.size.width,
                                            height: imageHeight * 0.3)
                    
                    if let bottomUIColor = uiImage.dominantDarkColor(from: bottomRect) {
                        await MainActor.run {
                            bottomColor = Color(uiColor: bottomUIColor)
                        }
                    }
                }
            } catch {
                print("Error extracting color: \(error)")
            }
        }
    }
}


struct PreviousNewRestaurantCardView: View {
    let restaurant: RestaurantDetails
    let restaurantScore: Int
    @State private var bottomColor: Color = .gray
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
        HStack{
            AsyncImage(url: URL(string: restaurant.image ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 167, height: 101)
                } else if phase.error != nil {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 167, height: 101)
                } else {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 167, height: 101)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(width: 167, height: 101)
            .clipped()
            
            VStack(alignment: .leading, spacing: 0){
                HStack{
                    Text((restaurant.name).capitalized)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
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
                            Circle()
                                .foregroundStyle(.gray)
                                .opacity(0.28)
                                .blur(radius: 3.1)

                            Circle()
                                .foregroundStyle(.filterWhite)

                            Image(isBookmarked
                                  ? "bookmarkFill"
                                  : "bookmarkVector")
                            .renderingMode(.template)
                                .foregroundStyle(
                                    isBookmarked
                                        ? Color.tastysRed
                                        : Color.black
                                )
                                .font(.system(size: 25))
                        }
                        .frame(height: 42)
                    }
                    .buttonStyle(.plain)
                }
                
                HStack{
                    if let distance = restaurant.distanceKm {
                        Text(formattedDistance(distance))
                            .foregroundStyle(.black)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                        
                        Text("•")
                                .foregroundStyle(.black)
                                .font(.system(size: 13))
                                .fontWeight(.medium)
                    }
                    
                    if let address = restaurant.address {
                        Text(address)
                            .foregroundStyle(.black)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                }
                
                HStack{
                    ReuseableScoreBorderView(score: restaurantScore)
                    
                    Text("\(restaurant.totalRating ?? 0) rating\(restaurant.totalRating ?? 0 > 1 ? "s" : "")")
                        .foregroundStyle(.black)
//                        .opacity(0.5)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                }
                
            }
        }
        .padding(.trailing, 10)
        .padding(.vertical, 5)
        .frame(height: 120)
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


}



struct NewFoodieCardView: View {
    let foodie: UserProfile
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    @StateObject private var profileVM = ProfileViewModel(userId: "")
    
    @State private var isFollowing: Bool = false
    @State private var isLoading: Bool = false
    @Binding var showTabButtons: Bool
    @State private var bottomColor: Color = .gray.opacity(0.8)
    var body: some View {
        ZStack{
            VStack(spacing: 15){
                HStack{
                    CachedAsyncImage( urlString: foodie.avatar, onImageLoaded: { image in
                        updateBottomColor(from: image, key: foodie.avatar ?? "")
                        
                    } ) { image in image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 67, height: 67)
                    } placeholder: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .opacity(0.3)
                            Image(systemName: "person")
                                .foregroundStyle(.gray)
                                .font(.system(size: 30))
                        }
                        .frame(width: 67, height: 67)
                    }
                    .clipShape(Circle())
                    .frame(width: 67, height: 67)
                    .clipped()
                    
                    
                    VStack(alignment: .leading){
                        HStack {
                            Text(("\(foodie.first_name) \(foodie.last_name)").capitalized)
                                .foregroundStyle(.white)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .offset(y: foodie.user_id.lowercased() != viewModel.currentUser?.id.uuidString.lowercased() ? 8 : 0)
                            
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
                                            .font(.system(size: 14))
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
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(isFollowing ? Color.white : Color.tastysRed)
                                    )
                                }
                                .disabled(isLoading)
                                .animation(.easeInOut(duration: 0.2), value: isFollowing)
                                .animation(.easeInOut(duration: 0.2), value: isLoading)
                                .offset(y: -4)
                            }
                        }
                        
                        HStack {
                            Text("@\(foodie.username)")
                                .foregroundStyle(.white)
                                .font(.system(size: 17))
                                .fontWeight(.medium)
                                .lineLimit(1)
//                                .opacity(0.5)
                            
//                            Text("•")
//                                    .foregroundStyle(.white)
//                                    .font(.system(size: 30))
//                                    .fontWeight(.medium)
//
//                            Text("\(formattedRating(foodie.average_rating ?? 0))% average rating")
//                                .foregroundStyle(.white)
//                                .font(.system(size: 15))
//                                .fontWeight(.medium)
//                                .lineLimit(1)
//                                .opacity(0.5)
                            
                            
                        }
                        
                        HStack{
                            Text("\(foodie.followers_count ?? 0) followers")
                                .foregroundStyle(.white)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .lineLimit(1)
//                                .opacity(0.5)
                            
                            Text("•")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30))
                                    .fontWeight(.medium)
                            
                            Text("\(foodie.totalDishesRated ?? 0 >= 1 ? "\(foodie.totalDishesRated ?? 0)" : "no") dish\(foodie.totalDishesRated ?? 0 > 1 ? "es" : "") rated")
                                .foregroundStyle(.white)
                                .font(.system(size: 13))
                                .fontWeight(.medium)
                                .lineLimit(1)
//                                .opacity(0.5)
                        }
                        
                        
                    }
                    
                    Spacer()
                    
                    

                 }
                .padding([.top], 20)
                .padding([.horizontal, .bottom], 12)
                
                
//                VStack(alignment: .leading){
//
//                    Text("Top Dishes")
//                        .foregroundStyle(.black)
//                        .font(.system(size: 15))
//                        .fontWeight(.medium)
//
//                    HStack(spacing: 10){
//                        ForEach(foodie.topDishes ?? [], id: \.dishId) { dish in
//                            NavigationLink {
//                                FoodDetailView(dishId: dish.dishId, showTabButtons: $showTabButtons)
//                                    .environmentObject(viewModel)
//                            } label: {
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
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                                    .clipped()
//
////                                    Text(dish.dishName)
////                                        .foregroundStyle(.black)
////                                        .font(.system(size: 11))
////                                        .fontWeight(.regular)
////                                        .lineLimit(2)
//
//                                }
//                            }
//
//                        }
//
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
//                    }
//
//
//                }
//                .padding(.vertical, 12)
////                .padding(.top, 10)
//                .padding(.horizontal, 15)
//                .background{
//                    RoundedRectangle(cornerRadius: 14)
//                        .foregroundStyle(.white)
//                }
            }
        }
        .padding(5)
        .background{
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(bottomColor)
        }
        .onAppear {
            isFollowing = foodie.isFollowing ?? false
            print(viewModel.currentUser?.id.uuidString ?? "nothing for current user")
        }
    }
    private func formattedRating(_ rating: Double) -> String {
        

        return String(format: "%.0f", rating)
    }
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



struct OldPlainFeedCardView: View {
    let post: RatingPost
    @Binding var showTabButtons: Bool
    @EnvironmentObject var viewModel: HomeViewModel
    init(post: RatingPost, showTabButtons: Binding<Bool>) {
        self.post = post
        self._showTabButtons = showTabButtons
    }
    var body: some View {
        let currentRating = post.dishes?.first?.rating ?? 50
        let userName = [(post.user?.firstName ?? ""), (post.user?.lastName ?? "")]
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
            .isEmpty ? (post.user?.username ?? "Anonymous")
          : [(post.user?.firstName ?? ""), (post.user?.lastName ?? "")].joined(separator: " ")
        ZStack{
            VStack(spacing: 20){
                HStack(spacing: 15){
                    if let userId = post.user?.id.uuidString {
                        if userId != viewModel.currentUser?.id.uuidString {
                            NavigationLink{
                                FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                    .environmentObject(viewModel)
                            } label:{
                                AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ZStack {
                                        Image("logoImage")
                                            .resizable()
                                            .scaledToFill()
//                                        Color.gray
//                                            .opacity(0.4)
//
//                                        Image(systemName: "person")
//                                            .foregroundStyle(.black)
//                                            .font(.system(size: 20))
                                    }
//                                        .shimmering()
                                }
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                            }
                        } else {
                            AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Image("logoImage")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                        }
                    } else {
                        AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image("logoImage")
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading){
                        if let userId = post.user?.id.uuidString {
                            if userId != viewModel.currentUser?.id.uuidString {
                                NavigationLink{
                                    FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                        .environmentObject(viewModel)
                                } label:{
                                    Text("\(userName)")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                
                            } else {
                                
                                Text("\(userName)")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                
                            }
                            
                        } else {
                            Text("anonymous")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        
                        rate(rating: currentRating)
                    }
                    
                    Spacer()
                    
                }
                
                
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(height: 2)
                
                
                HStack {
                    VStack(alignment: .leading, spacing: 5){
                        
                        
                        Text(timeAgo(from: post.post.createdAt ?? Date()))
                            .foregroundStyle(.black)
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                        
                        Text(post.post.comment ?? "")
                            .foregroundStyle(.black)
                            .fontWeight(.medium)
                            .font(Font.system(size: 14))
                            .opacity(0.4)
                            .lineLimit(2)
                        
                        
                    }
                    
                    Spacer()
                }
                
            }
            .padding(20)
            .background {
                Color.filterWhite
                    .frame(width: 270, height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .frame(width: 270, height: 210)
            
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func rate(rating: Int) -> some View {
        let content: (String, String) = {
            switch rating {
            case 0...69:
                return ("mehIcon", "Meh")
            case 70...79:
                return ("solidIcon", "Solid")
            case 80...94:
                return ("fireIcon", "Fire")
            case 95...100:
                return ("chefsKissIcon", "Chef's Kiss")
            default:
                return ("solidIcon", "Solid")
            }
        }()

        return HStack(spacing: 6) {
            Image(content.0)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text(content.1)
                .foregroundStyle(.tastysRed)
                .font(.system(size: 15))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.rateTastys)
        )
    }
}
