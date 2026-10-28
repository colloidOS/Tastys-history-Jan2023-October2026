//
//  FoodDetailView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/12/2025.
//

import SwiftUI


struct FoodDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bottomColor: Color = .tastysRed
    @State private var dishScore = 98
    @State private var selectedFeed = 1
    @State private var showComment = false
    @State private var showRatingCard = false
    @State private var showRatingDetail = false
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    @State private var showAddToPlate = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @State private var message = "You need to create an account first."
    var dishId: String
    @State private var isShowingRatingDetail = false
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    @State private var category = ["Burgers", "Sushi", "Pizza", "Ramen", "Indian", "Dessert", "Steak", "Coffee", "Thai", "Chinese", "French", "Mexican", "Italian", "Breakfast", "Barbeque", "Seafood", "Vietnamese", "Mediterranean", "Japanese", "Korean", "Greek", "Spanish", "American"]
    var body: some View {
        let dish = vm.currentDish?.dish
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            // Your content in ScrollView
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    
                    if let imageUrl = vm.currentDish?.dish.image {
                        ZStack(alignment: .bottomTrailing) {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray
                                        .opacity(0.3)
                                        .shimmering()

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: UIScreen.main.bounds.width - 30)
                                        .frame(height: 250)
                                        .clipped()

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
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            if vm.currentDish?.hasImages == true {
                                if #available(iOS 26.0, *) {
                                    NavigationLink {
                                        // Your All Photos destination
                                        FoodImagesView(dishId: vm.currentDish?.dish.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                    } label: {
                                        Text("All photos")
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
                                        // Your All Photos destination
                                        FoodImagesView(dishId: vm.currentDish?.dish.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                    } label: {
                                        Text("All photos")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 8)
                                            .background{
                                                ZStack{
                                                    bottomColor
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .opacity(0.75)
                                                    RoundedRectangle(cornerRadius: 20)
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
                    } else {
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    
                    HStack{
                        VStack(alignment: .leading){
                            if let selectedCategory {
                                HStack {
                                    Image(selectedCategory)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)

                                    Text(selectedCategory)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                }
                            }
                            
                            Text(dish?.name ?? "Dish")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                        }
                        
                        Spacer()
                        
                        Button{
                            Haptics.slide()
                            showRatingDetail.toggle()
                        } label: {
                            VStack(alignment: .center, spacing: 10){
                                ReuseableScoreBorderView(score: Int(dish?.rating ?? 0))
                                //                                .scaleEffect(0.8)
                                
                                
                                HStack{
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                    
                                    Text(formatRatingCount(vm.currentDish?.totalReviews ?? 0))
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
                    
                    Text(dish?.description ?? "")
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .opacity(0.6)
                    
                    
                    if let restaurantName = vm.currentDish?.restaurant.name {
                        NavigationLink{
                            RestaurantDetailView(restaurantId: vm.currentDish?.restaurant.id.uuidString ?? "", dishImage: vm.currentDish?.restaurant.image ?? "", showTabButtons: $showTabButtons)
                                .environmentObject(vm)
                        } label: {
                            HStack{
                                Text("Avalable at")
                                    .foregroundStyle(.availableGreen)
                                    .font(.system(size: 11))
                                    .fontWeight(.medium)
                                
                                Image("locationIcon")
                                
                                Text(restaurantName)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 11))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                //                            .renderingMode(.tem)
                            }
                        }
                    }
                    VStack{
                        if let tags = vm.currentDish?.dish.tags, !tags.isEmpty {
                            FlowLayout(spacing: 6, lineSpacing: 6) {
                                ForEach(tags.prefix(12), id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.black)
                                        .lineLimit(1)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.grayTastys.opacity(0.3))
                                                
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                        }
                        Divider()
                            
                    }
                    
                    
                    HStack{
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Reviews")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                            
                            
                            
                            HStack(alignment: .top){
                                VStack(spacing: 15) {
                                    Button{
                                        Haptics.slide()
                                        showRatingDetail.toggle()
                                    } label: {
                                        ReuseableScoreBorderView(score: Int(dish?.rating ?? 0))
                                            .scaleEffect(0.85)
                                    }
                                    
                                    Text("\(formatRatingCount(dish?.ratingCount ?? 0)) rating\(dish?.ratingCount ?? 0 > 1 ? "s" : "")")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                                        .opacity(0.6)
                                }
                                
                                Divider()
                                    .padding(.trailing, 5)
                                
                                VStack(spacing: 15) {
                                    HStack{
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 15))
                                        
                                        Text(formatRatingCount(vm.currentDish?.totalReviews ?? 0))
                                            .foregroundStyle(.black)
                                            .font(.system(size: 13))
                                            .fontWeight(.semibold)
                                        
                                    }
                                    .padding(8)
                                    .background{
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(lineWidth: 0.7)
                                            .foregroundStyle(.black)
                                            .opacity(0.3)
                                    }
                                    
                                    Text("visits")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                                        .opacity(0.6)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 5)
                                
                                Button{
                                    Haptics.slide()
                                    if let website = vm.currentDish?.restaurant.website,
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
                            
                        }
                        
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15){
                            if vm.isLoading && vm.dishPosts.isEmpty {
                                ForEach(0..<3) { _ in
                                    PlainFeedCardSkeletonView()
                                }
                            } else {
                                if !vm.dishPosts.isEmpty {
                                    
                                    ForEach(vm.dishPosts.filter {
                                        guard let comment = $0.post.comment else { return false }
                                        return !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    }) { post in
                                        PlainFeedCardView(post: post, showTabButtons: $showTabButtons)
                                            .environmentObject(vm)
//                                            .offset(x: -10)
                                    }
                                    
                                } else {
                                    
                                }
                                
                            }
                            
                        }
//                        .padding(.horizontal)
                    }
                    
                    Button {
                        Haptics.slide()
                        if !vm.isAuthenticated {
                            message = "You need to create an account to rate this dish"
                            showAuthPopup = true
                        } else {
                            if let singleDish = vm.currentDish?.dish {
                                vm.prefillRestaurant = vm.currentDish?.restaurant
                                vm.prefillDishes = [singleDish]
                                vm.showPostView = true
                            }
                        }
                    } label: {
                        HStack {
    //                        Image(systemName: "plus")
    //                            .font(.system(size: 20))
    //                            .foregroundStyle(.white)
    //                            .bold()
                            
                            Text("Rate this dish")
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.tastysRed)
                        }
//                        .padding(.horizontal, 25)
//                        .padding(.bottom, 70) // adjust for tab bar / safe area
                    }
                    
                    VStack {
                        
                        Divider()
                            .padding(.bottom, 10)
                            .padding(.top, 4)
                        
                        HStack{
                            VStack(alignment: .leading, spacing: 10) {
                                Text("What else you might like")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                
                                Text("More dish picks to explore next.")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 12))
                                    .fontWeight(.medium)
                                    .opacity(0.6)
                                
                            }
                            
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20){
                                if vm.isLoading && vm.currentDish?.relatedDishes.isEmpty == true {
                                    ForEach(0..<3) { _ in
                                        DishCardSkeletonView()
                                    }
                                } else {
                                    if let relatedDishes = vm.currentDish?.relatedDishes,
                                       !relatedDishes.isEmpty {

                                        ForEach(relatedDishes) { entry in
                                            NavigationLink{
                                                FoodDetailView(dishId: entry.dish.id.uuidString, showTabButtons: $showTabButtons)
                                                    .environmentObject(vm)
                                            } label: {
                                                DishCardView(
                                                    dish: entry.dish,
                                                    restaurant: entry.restaurant,
                                                    rating: Int(entry.dish.rating ?? 0)
                                                )
                                                .environmentObject(vm)
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    
                    
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 150)
                .offset(y: -55)
                
            }
            .blur(radius: showRatingDetail ? 7 : 0)
            .onTapGesture {
                if showRatingDetail {
                    showRatingDetail = false
                }
                
            }
            
            
            
            if showRatingDetail {
                if let dish = vm.currentDish {
                    Color.black
                        .opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showRatingDetail = false
                        }
                    VStack{
                        
                        HStack {
                            Spacer()
                            
                            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentDish?.dish.name ?? "", type: .dish(dish))
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
        }
//        .overlay(alignment: .bottom) {
//            if !showRatingDetail {
//                Button {
//                    Haptics.slide()
//                    if !vm.isAuthenticated {
//                        message = "You need to create an account to rate this dish"
//                        showAuthPopup = true
//                    } else {
//                        if let singleDish = vm.currentDish?.dish {
//                            vm.prefillRestaurant = vm.currentDish?.restaurant
//                            vm.prefillDishes = [singleDish]
//                            vm.showPostView = true
//                        }
//                    }
//                } label: {
//                    HStack {
////                        Image(systemName: "plus")
////                            .font(.system(size: 20))
////                            .foregroundStyle(.white)
////                            .bold()
//                        
//                        Text("Rate this dish")
//                            .foregroundStyle(.white)
//                            .font(.system(size: 16))
//                            .fontWeight(.semibold)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                    .background {
//                        RoundedRectangle(cornerRadius: 30)
//                            .foregroundStyle(.tastysRed)
//                    }
//                    .padding(.horizontal, 25)
//                    .padding(.bottom, 70) // adjust for tab bar / safe area
//                }
//                .zIndex(999)
//            }
//        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { currentOffset in
            let directionIsUp = currentOffset > lastOffset
            
            if abs(currentOffset - lastOffset) > 5 {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabButtons = directionIsUp
                }
            }
            
            lastOffset = currentOffset
        }
        .onChange(of: requireSignup) { oldValue, newValue in
            if newValue && !vm.isAuthenticated {
                print("does require sign up")
                dismiss()
            } else {
                print("does NOT require sign up")
            }
        }
        .onAppear{
            vm.currentDish = nil
            vm.dishPosts.removeAll()
            Haptics.prepare()
            print("dish's id: \(dishId)")
            vm.CurrentDishId = dishId
        }
        .onDisappear{
            vm.CurrentDishId = nil
        }
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(message)
        }
        
//        .navigationBarBackButtonHidden()
        .toolbar {
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button{
                    Haptics.slide()
                    if !vm.isAuthenticated {
                        message = "You need to create an account to add this dish to plates."
                        showAuthPopup = true
                    } else {
                        showAddToPlate.toggle()
                    }
                } label: {
                    
                    Image("bookmarkIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(width: 23, height: 23)
                    
//                        .padding(10)
                        
                }
            }
            
            
//            ToolbarItem(placement: .topBarTrailing) {
//                Button{
//                    showAddToPlate.toggle()
//                } label: {
//                    Image("bookmarkVector")
//                        .renderingMode(.template)
//                        .foregroundStyle(.white)
//                        .frame(width: 30, height: 30)
////                        .padding()
////                        .clipShape(Circle())
////                    .foregroundStyle(.white)
//                }
//                .buttonStyle(.plain)
//            }
        }
//        .enableSwipeBack()
//        .sheet(isPresented: $showRatingDetail) {
//            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentDish?.dish.name ?? "")
//                .presentationDetents([.large]) // Optional: allows dragging up/down
//                .presentationDragIndicator(.visible)    // Shows the drag handle
//        }
        .sheet(isPresented: $showAddToPlate) {
            if let dish = vm.currentSingleDish {
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
                await vm.loadDishPosts(
                    dishId: dishId,
                    sortBy: sortBy,
                    refresh: true,
                    filterHighRated: newValue == 2
                )
            }
        }
        .task {
            await vm.fetchDishDetail(dishId: dishId, userId: vm.session?.user.id.uuidString)
            await extractBottomColor(from: vm.currentDish?.dish.image)
            await vm.loadDishPosts(dishId: dishId, sortBy: "recent")
            if vm.currentDish?.hasImages == true {
                await vm.loadDishImages(dishId: dishId)
            }
            
        }
    }
    
    func formatRatingCount(_ count: Int) -> String {
        if count > 9_999 {
            return "\(count / 1_000)k+"
        }
        
        return "\(count)"
    }
    private var selectedCategory: String? {
        vm.currentDish?.dish.categories?.first { category.contains($0) }
    }
    
    private var emoji: String {
        switch vm.currentDish?.dish.rating ?? 50 {
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
        FoodDetailView(dishId: "", showTabButtons: .constant(true))
            .environmentObject(HomeViewModel())
    }
//    ContentView()
}



// MARK: - Dish Detail Skeleton View (for FoodDetailView loading state)

struct DishDetailSkeletonView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            // Placeholder for top image
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: geometry.size.width, height: 400)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 150)
                    
                    // "Most popular" placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 120, height: 20)
                        .cornerRadius(10)
                        .padding(10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(25)
                        .padding(.horizontal, 15)
                    
                    // Dish name + plus button placeholder
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 200, height: 35)
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.3))
                    
                    ZStack {
                        Color.gray.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack {
                            // Restaurant section placeholder
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(height: 41)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 100, height: 12)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 150, height: 17)
                                }
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 20, height: 20)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            
                            // Two cards: Meal Rating and Total Reviews placeholders
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 111)
                                    .cornerRadius(16)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 111)
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 15)
                            
                            // Related Dishes section
                            VStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 150, height: 16)
                                    .padding(.leading, 15)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<6) { _ in
                                            DishCardSkeletonView()
                                        }
                                    }
                                    .padding(.leading, 15)
                                }
                            }
                            .padding(.vertical, 10)
                            
                            // Feed selector buttons placeholder
                            HStack {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 32)
                                
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 32)
                            }
                            .padding(.horizontal, 15)
                            
                            // Feed posts placeholders
                            ForEach(0..<3) { _ in
                                FeedCardSkeletonView()
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()  // Assuming you have this modifier
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            x += size.width + spacing
            usedWidth = max(usedWidth, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: usedWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct OldFoodDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bottomColor: Color = .tastysRed
    @State private var dishScore = 98
    @State private var selectedFeed = 1
    @State private var showComment = false
    @State private var showRatingCard = false
    @State private var showRatingDetail = false
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    @State private var showAddToPlate = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @State private var message = "You need to create an account first."
    var dishId: String
    @State private var isShowingRatingDetail = false
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            // Image outside the ScrollView to properly ignore safe area
            GeometryReader { geometry in
                if let imageUrl = vm.currentDish?.dish.image {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Image("logoImage")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: 400)
                                .clipped()
                                .ignoresSafeArea(edges: .top)
//                            Color.gray
//                                .frame(width: geometry.size.width, height: 400)
//                                .clipped()
//                                .ignoresSafeArea(edges: .top)
//                                .shimmering()
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
//                            Color.gray
//                                .frame(width: geometry.size.width, height: 400)
//                                .clipped()
//                                .ignoresSafeArea(edges: .top)
                        @unknown default:
                            Color.gray
                                .frame(width: geometry.size.width, height: 400)
                                .clipped()
                                .ignoresSafeArea(edges: .top)
                                .shimmering()
                        }
                    }
                }
            }
            
            // Your content in ScrollView
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Add spacing at top if needed for content
                    Color.clear.frame(height: 150)
                    
                    HStack {
                        Text((vm.currentDish?.dish.name ?? "").capitalized)
                            .foregroundStyle(bottomColor)
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        
                        Spacer()
                        Button{
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
                            NavigationLink{
                                RestaurantDetailView(restaurantId: vm.currentDish?.restaurant.id.uuidString ?? "", dishImage: vm.currentDish?.restaurant.image ?? "", showTabButtons: $showTabButtons)
                                    .environmentObject(vm)
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: vm.currentDish?.restaurant.image ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            Color.gradTastys
                                                .clipShape(Circle())
                                                .frame(width: 41, height: 41)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(Circle())
                                                .frame(height: 41)
                                        case .failure:
                                            Color.gradTastys
                                                .clipShape(Circle())
                                                .frame(width: 41, height: 41)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("RESTAURANT")
                                            .foregroundStyle(.white)
                                            .opacity(0.6)
                                            .font(.system(size: 12.5))
                                            .fontWeight(.medium)
                                        
                                        Text((vm.currentDish?.restaurant.name ?? "").capitalized)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 17))
                                            .fontWeight(.medium)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white)
                                        .opacity(0.6)
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                    
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 12)
                                .background{
                                    bottomColor
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                            }
                            
                            HStack{
                                Button{
                                    Haptics.slide()
                                    showRatingDetail.toggle()
                                } label: {
                                    HStack {
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("DISH RATING")
                                                .foregroundStyle(.white)
                                                .opacity(0.6)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            if let dishRating = vm.currentDish?.dish.rating {
                                                HStack {
                                                    if dishRating < 11 {
                                                        Text("New")
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 19))
                                                            .fontWeight(.medium)
                                                    } else {
                                                        Text("\(Int(dishRating))%")
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 19))
                                                            .fontWeight(.medium)
                                                    }
                                                    
                                                    Spacer()
                                                    Text(emoji)
                                                        .font(.system(size: 25))
                                                    
                                                    
                                                }
                                            } else {
                                                HStack {
                                                    Text("New")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 19))
                                                        .fontWeight(.medium)
                                                    
                                                    Spacer()
                                                    Text("😊")
                                                        .font(.system(size: 25))
                                                    
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 6)
                                        Spacer()
                                        
                                        
                                    }
                                    .padding(.horizontal, 8)
                                    //                  .padding(.vertical, 12)
                                    .frame(height: 111)
                                    .background{
                                        bottomColor
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                }
//                                .padding(.horizontal, 15)
//                                .padding(.vertical, 8)
                                
//                                Button{
//                                    Haptics.slide()
//                                    showRatingDetail.toggle()
//                                } label: {
                                    HStack {
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("TOTAL REVIEWS")
                                                .foregroundStyle(.white)
                                                .opacity(0.6)
                                                .font(.system(size: 14))
                                                .fontWeight(.medium)
                                            
                                                Spacer()
                                            
                                            HStack {
                                                Text("\(vm.currentDish?.totalReviews ?? 0) People Visited")
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
//                                .padding(.horizontal, 15)
//                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal, 15)
                            
                            
                            
                            
                            
                            VStack{
                                
                                
                                
                                if let tags = vm.currentDish?.dish.tags {
                                    if !tags.isEmpty{
                                        HStack{
                                            Text("About this dish")
                                                .foregroundStyle(bottomColor)
                                                .font(.system(size: 20))
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        
                                        LazyVGrid(columns: columns, spacing: 6) {
                                            ForEach(tags.prefix(12), id: \.self) { tag in
                                                Text(tag)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundStyle(.black)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.vertical, 6)
                                                    .padding(.horizontal, 10)
                                                //                                                .frame(maxWidth: .infinity)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .fill(Color.grayTastys)
                                                    )
                                            }
                                        }
                                        .padding(.horizontal, 15)
                                        .padding(.bottom, 10)
                                    }
                                }
                                
                                
                                
                                let commentedPosts = vm.dishPosts.filter {
                                    guard let comment = $0.post.comment else { return false }
                                    
                                    return !comment
                                        .trimmingCharacters(in: .whitespacesAndNewlines)
                                        .isEmpty
                                }

                                if !commentedPosts.isEmpty {
                                    HStack {
                                        Text("What people are saying")
                                            .foregroundStyle(bottomColor)
                                            .font(.system(size: 20))
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                        
                                    
                                }
                               
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20){
                                        if vm.isLoading && vm.dishPosts.isEmpty {
                                            ForEach(0..<3) { _ in
                                                PlainFeedCardSkeletonView()
                                            }
                                        } else {
                                            if !vm.dishPosts.isEmpty {
                                                
                                                ForEach(vm.dishPosts.filter {
                                                    guard let comment = $0.post.comment else { return false }
                                                    return !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                }) { post in
                                                    PlainFeedCardView(post: post, showTabButtons: $showTabButtons)
                                                        .environmentObject(vm)
                                                        .offset(x: -10)
                                                }
                                                
                                            } else {
                                                HStack {
                                                    Spacer()
                                                    Text("No post yet🤧")
                                                        .foregroundStyle(bottomColor)
                                                        .font(.system(size: 15))
                                                    Spacer()
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                                
                            }
                            .padding(.bottom, 110)
                            .padding(.top, 20)
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
                if let dish = vm.currentDish {
                    Color.black
                        .opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showRatingDetail = false
                        }
                    VStack{
                        
                        HStack {
                            Spacer()
                            
                            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentDish?.dish.name ?? "", type: .dish(dish))
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !showRatingDetail {
                Button {
                    Haptics.slide()
                    if !vm.isAuthenticated {
                        message = "You need to create an account to rate this dish"
                        showAuthPopup = true
                    } else {
                        if let singleDish = vm.currentDish?.dish {
                            vm.prefillRestaurant = vm.currentDish?.restaurant
                            vm.prefillDishes = [singleDish]
                            vm.showPostView = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .bold()
                        
                        Text("Rate this dish")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundStyle(.tastysRed)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 70) // adjust for tab bar / safe area
                }
                .zIndex(999)
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
        .onChange(of: requireSignup) { oldValue, newValue in
            if newValue && !vm.isAuthenticated {
                print("does require sign up")
                dismiss()
            } else {
                print("does NOT require sign up")
            }
        }
        .onAppear{
            vm.currentDish = nil
            vm.dishPosts.removeAll()
            Haptics.prepare()
            print("dish's id: \(dishId)")
            vm.CurrentDishId = dishId
        }
        .onDisappear{
            vm.CurrentDishId = nil
        }
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(message)
        }
        
//        .navigationBarBackButtonHidden()
        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
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
//                .buttonStyle(.plain)
//            }
            
            
            ToolbarItem(placement: .principal) {
                Text("Meal profile")
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
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
            }
            
            
//            ToolbarItem(placement: .topBarTrailing) {
//                Button{
//                    showAddToPlate.toggle()
//                } label: {
//                    Image("bookmarkVector")
//                        .renderingMode(.template)
//                        .foregroundStyle(.white)
//                        .frame(width: 30, height: 30)
////                        .padding()
////                        .clipShape(Circle())
////                    .foregroundStyle(.white)
//                }
//                .buttonStyle(.plain)
//            }
        }
//        .enableSwipeBack()
//        .sheet(isPresented: $showRatingDetail) {
//            RatingDetailView(isShowing: $showRatingDetail, name: vm.currentDish?.dish.name ?? "")
//                .presentationDetents([.large]) // Optional: allows dragging up/down
//                .presentationDragIndicator(.visible)    // Shows the drag handle
//        }
        .sheet(isPresented: $showAddToPlate) {
            if let dish = vm.currentSingleDish {
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
                await vm.loadDishPosts(
                    dishId: dishId,
                    sortBy: sortBy,
                    refresh: true,
                    filterHighRated: newValue == 2
                )
            }
        }
        .task {
            await vm.fetchDishDetail(dishId: dishId, userId: vm.session?.user.id.uuidString)
            await extractBottomColor(from: vm.currentDish?.dish.image)
            await vm.loadDishPosts(dishId: dishId, sortBy: "recent")
        }
    }
    
    private var emoji: String {
        switch vm.currentDish?.dish.rating ?? 50 {
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
