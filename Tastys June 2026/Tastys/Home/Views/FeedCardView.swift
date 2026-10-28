//
//  FeedCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/12/2025.
//

import SwiftUI
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct FeedCardView: View {
    let post: RatingPost
    @State private var showComment: Bool = false
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var currentIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var showAddToPlateSheet: Bool = false
    @State private var localEngagement: EngagementDetails
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    init(post: RatingPost, showTabButtons: Binding<Bool>) {
        self.post = post
        self._localEngagement = State(initialValue: post.engagement ?? EngagementDetails(
            likesCount: 0, dislikesCount: 0, commentsCount: 0,
            engagementScore: 0, userHasLiked: false, userHasDisliked: false
        ))
        self._showTabButtons = showTabButtons
    }
    
    var body: some View {
        if let dishes = post.dishes, !dishes.isEmpty {
            mainContent(dishes: dishes)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func mainContent(dishes: [DishRatingDetails]) -> some View {
        // ── Move all data preparation here ──
        let userName = [(post.user?.firstName ?? ""), (post.user?.lastName ?? "")]
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
            .isEmpty ? (post.user?.username ?? "Anonymous")
          : [(post.user?.firstName ?? ""), (post.user?.lastName ?? "")].joined(separator: " ")
        
        let restaurantName = post.restaurant?.name ?? "Unknown"
        let commentText = post.post.comment ?? ""
//        let averageScore = Int(round(Double(dishes.map(\.rating).reduce(0, +)) / Double(dishes.count)))
        let shares = post.post.shared
        
        let imagesWithDish: [(String, Int)] = dishes.enumerated().flatMap { index, dish in
            (dish.images ?? []).map { ($0, index) }
        }
        
        let hasImages = !imagesWithDish.isEmpty
        let currentDish = hasImages ? imagesWithDish[currentIndex].1 : 0
        
        let currentDishIndex = hasImages ? imagesWithDish[currentIndex].1 : 0
        
        let currentRating = dishes[currentDishIndex].rating
        
        VStack {
            
            if hasImages {
                ZStack {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<imagesWithDish.count, id: \.self) { i in
                            AsyncImage(url: URL(string: imagesWithDish[i].0)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: UIScreen.main.bounds.width - 40, height: 428)
                            .clipped()
                            .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width: UIScreen.main.bounds.width - 40, height: 428)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    VStack {
                        HStack {
                            if let userId = post.user?.id.uuidString {
                                if userId != viewModel.currentUser?.id.uuidString {
                                    NavigationLink{
                                        FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                            .environmentObject(viewModel)
                                    } label:{
                                        AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray
                                        }
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    }
                                } else {
                                    AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                }
                            } else {
                                AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading) {
                                
                                HStack(spacing: 0){
                                    if let userId = post.user?.id.uuidString {
                                        if userId != viewModel.currentUser?.id.uuidString {
                                            NavigationLink{
                                                FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                                    .environmentObject(viewModel)
//                                                    .env
                                            } label:{
                                                Text("\(userName) ")
                                                    .foregroundStyle(.filterWhite)
                                                    .font(.system(size: 14))
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                            }
                                        } else {
                                            Text("\(userName) ")
                                                .foregroundStyle(.filterWhite)
                                                .font(.system(size: 15))
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                        }
                                    } else {
                                        Text("\(userName) ")
                                            .foregroundStyle(.filterWhite)
                                            .font(.system(size: 14))
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                    }
                                    
                                    
//                                    +
                                    NavigationLink{
                                        RestaurantDetailView(restaurantId: post.restaurant?.id.uuidString ?? "", dishImage: "", showTabButtons: $showTabButtons)
                                            .environmentObject(viewModel)
                                    } label: {
                                        Text("ate at \((restaurantName).capitalized)")
                                            .foregroundStyle(.filterWhite)
                                            .font(.system(size: 14))
                                            .fontWeight(.regular)
                                            .lineLimit(1)
                                    }
                                }
                                
                                
                                let dishNamesString = dishes.map { $0.dish.name }.joined(separator: ", ")
                                Text((dishNamesString).capitalized)
                                    .foregroundStyle(.filterWhite)
                                    .opacity(0.5)
                                    .font(.system(size: 13))
                                    .fontWeight(.regular)
                            }
                            
                            Spacer()
                            
//                            Button {
//                                showRatingCard.toggle()
//                            } label: {
                            ReuseableScoreBorderView(score: currentRating)
//                            }
//                            .buttonStyle(.plain)
                        }
                        .padding([.vertical, .horizontal], 10)
                        .padding(.bottom)
                        .background {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .black.opacity(0.5), location: 0.0),
                                        .init(color: .black.opacity(0.15), location: 0.5),
                                        .init(color: .black.opacity(0.01), location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                
                                Color.black.opacity(0.3).blur(radius: 37.1)
                                Color.black.opacity(0.1).blur(radius: 40)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            ForEach(dishes.indices, id: \.self) { i in
                                Text((dishes[i].dish.name).capitalized)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background {
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundStyle(currentDish == i ? .white : .white.opacity(0.5))
                                    }
                            }
                        }
                        .padding([.vertical, .horizontal], 10)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 40, height: 428)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .onAppear {
                    if imagesWithDish.count > 1 {
                        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
                            withAnimation {
                                currentIndex = (currentIndex + 1) % imagesWithDish.count
                            }
                        }
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
                
                VStack(alignment: .leading) {
                    Text(commentText)
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                    
                    HStack(spacing: 10) {
                        // Likes
                        HStack(spacing: 3) {
                            Button {
                                Haptics.slide()
                                toggleLike()
                            } label: {
                                Image(systemName: localEngagement.userHasLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundStyle(localEngagement.userHasLiked ? .tastysRed : .black)
                            }
                            .buttonStyle(.plain)
                            Text("\(localEngagement.likesCount)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                        }
                        
                        // Dislikes
                        HStack(spacing: 2) {
                            Button {
                                Haptics.slide()
                                toggleDislike()
                            } label: {
                                Image(systemName: localEngagement.userHasDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .foregroundStyle(localEngagement.userHasDisliked ? .tastysRed : .black)
                            }
                            .buttonStyle(.plain)
                            Text("\(localEngagement.dislikesCount)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                        }
                        
                        // Comments
                        HStack(spacing: 2) {
                            Button {
                                Haptics.tick()
                                showComment.toggle()
                            } label: {
                                Image(systemName: "ellipsis.message.fill")
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                            Text("\(localEngagement.commentsCount)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                        }
                        
                        // Share
                        HStack(spacing: 2) {
//                            let dishName = dishes.first?.dish.name ?? ""
                                let shareMessage = "Checkout this Dish I rated on Tastys: https://tastysapp.com"
                                let shareURL = URL(string: "https://tastysapp.com")!
                            Button {
                                Haptics.slide()
                                        shareItems = [shareMessage, shareURL]
                                        showingShareSheet = true
                                    } label: {
                                        Image(systemName: "arrowshape.turn.up.right.fill")
                                            .foregroundStyle(.black)
                                    }
                                    .buttonStyle(.plain)
                                    .sheet(isPresented: $showingShareSheet) {
                                        ActivityView(activityItems: shareItems)
                                    }
                            
//                            Text("\(shares)")
//                                .foregroundStyle(.black)
//                                .font(.system(size: 15))
                        }
                        
                        Spacer()
                        
                        // Add to plate / save buttons (placeholders)
                        Button {
                            Haptics.slide()
                            viewModel.prefillRestaurant = post.restaurant
                            viewModel.prefillDishes = dishes.map { $0.dish }
                            viewModel.showPostView = true
                        } label: {
                            ZStack {
                                Circle().foregroundStyle(.white).frame(height: 40)
                                Circle().stroke(lineWidth: 1.3).foregroundStyle(.plateWhite).frame(height: 42)
                                Image(systemName: "plus")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        
                        Button {
                            Haptics.slide()
                            showAddToPlateSheet.toggle()
                        } label: {
                            ZStack {
                                Circle().foregroundStyle(.white).frame(height: 40)
                                Circle().stroke(lineWidth: 1.3).foregroundStyle(.plateWhite).frame(height: 40)
                                Text("🍽️")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
            } else {
                // No images version – same structure as before
                VStack(alignment: .leading) {
                    HStack {
                        if let userId = post.user?.id.uuidString {
                            if userId != viewModel.currentUser?.id.uuidString {
                                NavigationLink{
                                    FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                        .environmentObject(viewModel)
                                } label:{
                                    AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                }
                            } else {
                                AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            }
                        } else {
                            AsyncImage(url: URL(string: post.user?.avatar ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        }
                        
                        
                        
                        
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: 0){
                                if let userId = post.user?.id.uuidString {
                                    if userId != viewModel.currentUser?.id.uuidString {
                                        NavigationLink{
                                            FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                                .environmentObject(viewModel)
                                        } label:{
                                            Text("\(userName) ")
                                                .foregroundStyle(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                        }
                                    } else {
                                        Text("\(userName) ")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 14))
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                    }
                                } else {
                                    Text("\(userName) ")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                
                                
//                                    +
                                NavigationLink{
                                    RestaurantDetailView(restaurantId: post.restaurant?.id.uuidString ?? "", dishImage: "", showTabButtons: $showTabButtons)
                                        .environmentObject(viewModel)
                                } label: {
                                    Text("ate at \((restaurantName).capitalized)")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .lineLimit(1)
                                }
                            }
                            
                            let dishString = dishes.map { $0.dish.name }.joined(separator: ", ")
                            Text((dishString).capitalized)
                                .foregroundStyle(.black)
                                .opacity(0.5)
                                .font(.system(size: 13))
                                .fontWeight(.regular)
                        }
                        .padding(.horizontal, 8)
                        
                        Spacer()
                        
//                        Button { showRatingCard.toggle() } label: {
                        ReuseableScoreBorderView(score: dishes.first?.rating ?? 0)
//                        }
//                        .buttonStyle(.plain)
                    }
                    .padding(.bottom)
                    
                    Text(commentText)
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                    
                    // Same interaction row as above (likes, dislikes, comments, share, buttons)
                    HStack(spacing: 10) {
                        // Likes
                        HStack(spacing: 2) {
                            Button {
                                Haptics.slide()
                                toggleLike()
                            } label: {
                                Image(systemName: localEngagement.userHasLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundStyle(localEngagement.userHasLiked ? .tastysRed : .black)
                            }
                            .buttonStyle(.plain)
                            Text("\(localEngagement.likesCount)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                        }
                        
                        // Dislikes
                        HStack(spacing: 3) {
                            Button {
                                Haptics.slide()
                                toggleDislike()
                            } label: {
                                Image(systemName: localEngagement.userHasDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .foregroundStyle(localEngagement.userHasDisliked ? .tastysRed : .black)
                            }
                            .buttonStyle(.plain)
                            Text("\(localEngagement.dislikesCount)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                        }
                        
                        // Comments
                        HStack(spacing: 2) {
                            Button {
                                Haptics.tick()
                                showComment.toggle()
                            } label: {
                                Image(systemName: "ellipsis.message.fill")
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                            Text("\(localEngagement.commentsCount)")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                        }
                        
                        // Share
                        HStack(spacing: 2) {
                            let shareMessage = "Checkout this Dish I rated on Tastys: https://tastysapp.com"
                            let shareURL = URL(string: "https://tastysapp.com")!
                        Button {
                            Haptics.slide()
                                    shareItems = [shareMessage, shareURL]
                                    showingShareSheet = true
                                } label: {
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                        .foregroundStyle(.black)
                                }
                                .buttonStyle(.plain)
                                .sheet(isPresented: $showingShareSheet) {
                                    ActivityView(activityItems: shareItems)
                                }
//                            Text("\(shares)")
//                                .foregroundStyle(.black)
//                                .font(.system(size: 15))
                        }
                        
                        Spacer()
                        
                        // Add to plate / save buttons (placeholders)
                        Button {
                            Haptics.slide()
                            viewModel.prefillRestaurant = post.restaurant
                            viewModel.prefillDishes = dishes.map { $0.dish }
                            viewModel.showPostView = true
                        } label: {
                            ZStack {
                                Circle().foregroundStyle(.white).frame(height: 40)
                                Circle().stroke(lineWidth: 1.3).foregroundStyle(.plateWhite).frame(height: 38)
                                Image(systemName: "plus")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        
                        Button {
                            Haptics.slide()
                            showAddToPlateSheet.toggle()
                        } label: {
                            ZStack {
                                Circle().foregroundStyle(.white).frame(height: 40)
                                Circle().stroke(lineWidth: 1.3).foregroundStyle(.plateWhite).frame(height: 40)
                                Text("🍽️")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .padding(.leading, 4)
                    }
                }
                .padding([.vertical, .horizontal], 10)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, 20)
        .background {
            ZStack {
                Color.filterWhite.clipShape(RoundedRectangle(cornerRadius: 24))
                RoundedRectangle(cornerRadius: 24)
                    .stroke(lineWidth: 0.3)
                    .foregroundStyle(.black)
                    .opacity(0.09)
                    .shadow(color: .black.opacity(0.09), radius: 9, x: 0, y: 2)
            }
        }
        .onAppear{
            Haptics.prepare()
            Task{
                await viewModel.loadCurrentUser()
            }
        }
        .sheet(isPresented: $showComment) {
            CommentCardView(postId: post.id, showTabButtons: $showTabButtons)
                .presentationDetents([.fraction(2/3)/*, .fraction(3/3)*/])
                .environmentObject(viewModel)
        }
        .onChange(of: showComment) { oldValue, newValue in
            print("showComment changed → old: \(oldValue), new: \(newValue)")
            
            if !newValue {
                print("Comment sheet was dismissed — starting refresh for post \(post.id.uuidString)")
                
                Task { @MainActor in
                    print("Inside Task — will call getPostById")
                    
                    do {
                        print("Calling getPostById(postId: \(post.id.uuidString))")
                        let refreshedPost = try await viewModel.getPostById(postId: post.id)
                        
                        print("getPostById succeeded — new comments count = \(refreshedPost.engagement?.commentsCount ?? -1)")
                        
                        if let freshEngagement = refreshedPost.engagement {
                            print("Updating localEngagement → old count: \(localEngagement.commentsCount), new count: \(freshEngagement.commentsCount)")
                            localEngagement = freshEngagement
                        } else {
                            print("Warning: refreshedPost.engagement is nil")
                        }
                    } catch {
                        print("!!! getPostById FAILED: \(error.localizedDescription)")
//                        if let supabaseErr = error as? PostgrestError {
//                            print("Supabase error details → code: \(supabaseErr.code ?? "none"), message: \(supabaseErr.message ?? "no message")")
//                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddToPlateSheet) {
            AddToPlateView(dishes: dishes.map { $0.dish })
                .presentationDetents([.fraction(2.0 / 3.0)])
                .environmentObject(viewModel)
        }
        // .padding(.horizontal, 15)   // ← decide if you want this
    }
    
    private func toggleLike() {
        let previous = localEngagement
        if localEngagement.userHasLiked {
            localEngagement.userHasLiked = false
            localEngagement.likesCount -= 1
            if localEngagement.userHasDisliked {
                localEngagement.userHasDisliked = false
                localEngagement.dislikesCount -= 1
            }
        } else {
            localEngagement.userHasLiked = true
            localEngagement.likesCount += 1
            if localEngagement.userHasDisliked {
                localEngagement.userHasDisliked = false
                localEngagement.dislikesCount -= 1
            }
        }
        
        Task {
            do {
                try await viewModel.toggleReaction(for: post.id, isLike: true)
            } catch {
                localEngagement = previous
                // Optionally show error
            }
        }
    }
    
    private func toggleDislike() {
        let previous = localEngagement
        if localEngagement.userHasDisliked {
            localEngagement.userHasDisliked = false
            localEngagement.dislikesCount -= 1
            if localEngagement.userHasLiked {
                localEngagement.userHasLiked = false
                localEngagement.likesCount -= 1
            }
        } else {
            localEngagement.userHasDisliked = true
            localEngagement.dislikesCount += 1
            if localEngagement.userHasLiked {
                localEngagement.userHasLiked = false
                localEngagement.likesCount -= 1
            }
        }
        
        Task {
            do {
                try await viewModel.toggleReaction(for: post.id, isLike: false)
            } catch {
                localEngagement = previous
                // Optionally show error
            }
        }
    }
}

//#Preview {
//    FeedCardView(/*isImageIncluded: true, post: RatingPost, showComment: .constant(false), showRatingCard: .constant(true)*/)
//        .environmentObject(HomeViewModel())
//}



struct FeedCardSkeletonView: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.grayTastys.opacity(0.6))
                    .frame(width: UIScreen.main.bounds.width - 40, height: 428)
                
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.grayTastys.opacity(0.9))
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.grayTastys.opacity(0.9))
                                .frame(width: 150, height: 14)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.grayTastys.opacity(0.9))
                                .frame(width: 200, height: 13)
                        }
                        
                        Spacer()
                        
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(Color.grayTastys.opacity(0.3))
//                            .frame(width: 40, height: 40)
                    }
                    .padding([.vertical, .horizontal], 10)
                    .padding(.bottom)
                    
                    Spacer()
                    
                    HStack {
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.grayTastys.opacity(0.9))
                                .frame(width: 80, height: 28)
                        }
                    }
                    .padding([.vertical, .horizontal], 10)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 428)
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 15)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 250, height: 15)
                
                HStack(spacing: 10) {
                    ForEach(0..<4) { _ in
                        HStack(spacing: 2) {
                            Image(systemName: "hand.thumbsup")
                                .foregroundStyle(Color.gray.opacity(0.3))
                            Text("0")
                                .foregroundStyle(Color.gray.opacity(0.3))
                        }
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.grayTastys.opacity(0.9))
                        .frame(height: 38)
                    
                    Circle()
                        .fill(Color.grayTastys.opacity(0.9))
                        .frame(height: 40)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .padding(.top, 5)
        .padding(.bottom, 21)
        .background(
            ZStack {
                Color.white.clipShape(RoundedRectangle(cornerRadius: 24))
                RoundedRectangle(cornerRadius: 24)
                    .stroke(lineWidth: 0.3)
                    .foregroundStyle(.black)
                    .opacity(0.09)
                    .shadow(color: .black.opacity(0.09), radius: 9, x: 0, y: 2)
            }
        )
        .redacted(reason: .placeholder)
    }
}


import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let completion: UIActivityViewController.CompletionWithItemsHandler? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = completion
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
