//
//  RatingDetailView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 25/12/2025.
//

import SwiftUI

struct RatingDetailView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var isShowing: Bool
    var name: String
    let type: RatingDetailType
    private let ratingMap: [Int: (label: String, color: Color)] = [
        50: ("Meh", .rating50),
        70: ("It's Fine", .rating70),
        80: ("Worth It", .rating80),
        95: ("Chefs Kiss", .rating95)
    ]
    
    private var orderedRatings: [Int] {
        [50, 70, 80, 95]
    }
    
    private var ratingBreakdown: [String: RatingBucket] {
        switch type {
        case .dish(let dish):
            return dish.ratingBreakdown ?? [:]

        case .restaurant(let restaurant):
            return restaurant.ratingBreakdown
        }
    }
    
    private var reviewers: [ReviewerWithRating] {
        vm.currentDish?.reviewers ?? []
    }
    
    private var totalReviews: Int {
        switch type {
        case .dish(let dish):
            return dish.totalReviews

        case .restaurant(let restaurant):
            return restaurant.totalVisits
        }
    }
    
    private var followersRated: [ReviewerUser] {
        switch type {
        case .dish(let dish):
            return dish.followersRated

        case .restaurant(let restaurant):
            return restaurant.followersRated
        }
    }
    
    private var topUsers: [Any] {
        switch type {
        case .dish(let dish):
            return dish.topUsers

        case .restaurant(let restaurant):
            return restaurant.topUsers
        }
    }
    
    private var mealRating: Int {
        vm.currentDish?.mealRating ?? 50
    }
    
    private var ratingBuckets: [Int: [ReviewerWithRating]] {
        var buckets: [Int: [ReviewerWithRating]] = [:]
        for rating in orderedRatings {
            buckets[rating] = []
        }
        for reviewer in reviewers {
            if ratingMap.keys.contains(reviewer.rating) {
                buckets[reviewer.rating]?.append(reviewer)
            }
        }
        return buckets
    }
    
    private var counts: [Int] {
        orderedRatings.map { rating in
            ratingBreakdown[String(rating)]?.count ?? 0
        }
    }
    
    private var total: Double {
        Double(totalReviews)
    }
    
    private var percentages: [Double] {
        counts.map {
            totalReviews > 0
                ? Double($0) / Double(totalReviews) * 100
                : 0
        }
    }
    
    private var dishTopUsers: [TopUserWithRating] {
        if case let .dish(dish) = type {
            return dish.topUsers
        }
        return []
    }

    private var restaurantTopUsers: [TopUserAtPlace] {
        if case let .restaurant(restaurant) = type {
            return restaurant.topUsers
        }
        return []
    }
    
    private var averageScore: Int {
        switch type {
        case .dish(let dish):
            guard dish.totalReviews > 0 else {
                return 0
            }

            let weightedSum = orderedRatings.reduce(0) { result, rating in
                result + rating * (dish.ratingBreakdown?[String(rating)]?.count ?? 0)
            }

            return weightedSum / dish.totalReviews

        case .restaurant(let restaurant):
            return Int(restaurant.restaurant.rating ?? 0)
        }
    }
    
    private var bucketLabels: [String] {
        orderedRatings.map { ratingMap[$0]?.label ?? "" }
    }
    
    private var bucketColors: [Color] {
        orderedRatings.map { ratingMap[$0]?.color ?? .gray }
    }
    
    private var bucketUsers: [[ReviewerWithRating]] {
        orderedRatings.map { ratingBuckets[$0] ?? [] }
    }
    
    @ViewBuilder
    private func stackedAvatars<T: Identifiable>(users: [T], isMembers: Bool = true, avatarKeyPath: KeyPath<T, String?>) -> some View where T.ID == String {
        let visibleUsers = Array(users.prefix(3))
        ZStack(alignment: .leading) {
            if visibleUsers.count >= 3 {
                avatarView(url: visibleUsers[2][keyPath: avatarKeyPath], offset: -20, zIndex: 1)
            }
            if visibleUsers.count >= 2 {
                avatarView(url: visibleUsers[1][keyPath: avatarKeyPath], offset: -13, zIndex: 2)
            }
            if visibleUsers.count >= 1 {
                avatarView(url: visibleUsers[0][keyPath: avatarKeyPath], offset: -5, zIndex: 3)
            }
            if users.count > 3 {
                Text("+\(users.count - 3)\(isMembers ? " members" : "")")
                    .font(.system(size: 9))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .padding(8)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 23)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.08), radius: 8.8, x: 0, y: 2)
                            RoundedRectangle(cornerRadius: 23)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(.white)
                        }
                    }
                    .zIndex(4)
            }
        }
    }
    
    @ViewBuilder
    private func avatarView(url: String?, offset: CGFloat, zIndex: Double) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
            case .failure, .empty:
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundStyle(.gray)
            @unknown default:
                EmptyView()
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
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    
                    VStack {
                        
                        ZStack {
                            HalfStrokedCircleView(
                                percentages: percentages,
                                colors: bucketColors
                            )
                            .frame(height: 240)
                            .overlay(alignment: .topLeading) {
                                Button{
                                    isShowing = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 20))
                                        .fontWeight(.semibold)
                                }
                                .offset(y: 45)
                            }
                            //                        .padding(.top)
                            
                            VStack(spacing: 10) {
                                VStack {
                                    Text(emoji)
                                        .font(.system(size: 23))
                                        .id(emoji)
                                    
                                    
                                    Text("\(averageScore)%")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 40))
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text((name).capitalized)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                        .lineLimit(3)
                                    
                                    Text("Tasty's score")
                                        .foregroundStyle(.black)
                                        .opacity(0.5)
                                        .font(.system(size: 14.5))
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        
                        VStack {
                            Divider()
                                .padding(.bottom)
                            
                            ForEach(0..<orderedRatings.count, id: \.self) { index in
                                HStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundStyle(bucketColors[index])
                                        .frame(width: 23, height: 23)
                                    
                                    Text(bucketLabels[index])
                                        .foregroundStyle(.black)
                                        .opacity(0.5)
                                        .font(.system(size: 16.5))
                                        .fontWeight(.medium)
                                    
                                    Text("\(Int(percentages[index]))%")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 16.5))
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    stackedAvatars(users: bucketUsers[index], isMembers: true, avatarKeyPath: \.avatar)
                                }
                            }
                        }
                        .offset(y: -60)
                    }
                    .frame(height: 341)
                    .padding(.top)
                    .padding(.horizontal)
                    .background {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.fakeWhite)
                    }
                    .padding(.horizontal)
                    .frame(height: 340)
                    
                    if vm.isAuthenticated {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(followersRated.count) FOLLOWERS ATE AT THIS")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
                            
                            stackedAvatars(users: followersRated, isMembers: false, avatarKeyPath: \.avatar)
                                .padding(.leading, 20)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundStyle(.fakeWhite)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                    }
                    
                    HStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOP 5 USERS ATE THIS")
                                    .foregroundStyle(.black)
                                    .opacity(0.6)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                switch type {
                                case .dish:
                                    stackedAvatars(
                                        users: dishTopUsers,
                                        isMembers: false,
                                        avatarKeyPath: \.avatar
                                    )
                                    .padding(.leading, 20)
                                    
                                case .restaurant:
                                    stackedAvatars(
                                        users: restaurantTopUsers,
                                        isMembers: false,
                                        avatarKeyPath: \.avatar
                                    )
                                    .padding(.leading, 20)
                                }
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 4)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 111)
                        .background {
                            Color.fakeWhite
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 6)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("TOTAL REVIEWS")
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        
                        stackedAvatars(users: reviewers, isMembers: false, avatarKeyPath: \.avatar)
                            .padding(.leading, 20)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.fakeWhite)
                    }
                    .padding(.horizontal)
                }
                .padding(12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    private var emoji: String {
        switch averageScore {
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
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    RatingBreakdownView(isShowing: .constant(true), dishId: "")
        .environmentObject(HomeViewModel())
}


struct RatingBreakdownView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var isShowing: Bool
    var dishId: String
    private let ratingMap: [Int: (label: String, color: Color)] = [
        50: ("Meh", .rating50),
        70: ("Solid", .rating70),
        80: ("Fire", .rating80),
        95: ("Chefs Kiss", .rating95)
    ]
    
    private let ratingMaps: [Int: (label: String, image: String)] = [
        50: ("Meh", "mehIcon"),
        70: ("Solid", "solidIcon"),
        80: ("Fire", "fireIcon"),
        95: ("Chefs Kiss", "chefsKissIcon")
    ]
    
    private var orderedRatings: [Int] {
        [50, 70, 80, 95]
    }
    
    private var reviewers: [ReviewerWithRating] {
        vm.currentDish?.reviewers ?? []
    }
    
    private var totalReviews: Int {
        vm.currentDish?.totalReviews ?? 0
    }
    
    private var followersRated: [ReviewerUser] {
        vm.currentDish?.followersRated ?? []
    }
    
    private var topUsers: [TopUserWithRating] {
        vm.currentDish?.topUsers ?? []
    }
    
    private var mealRating: Int {
        vm.currentDish?.mealRating ?? 50
    }
    
    private var ratingBuckets: [Int: [ReviewerWithRating]] {
        var buckets: [Int: [ReviewerWithRating]] = [:]
        for rating in orderedRatings {
            buckets[rating] = []
        }
        for reviewer in reviewers {
            if ratingMap.keys.contains(reviewer.rating) {
                buckets[reviewer.rating]?.append(reviewer)
            }
        }
        return buckets
    }
    
    private var counts: [Int] {
        orderedRatings.map { ratingBuckets[$0]?.count ?? 0 }
    }
    
    private var total: Double {
        Double(totalReviews)
    }
    
    private var percentages: [Double] {
        counts.map { total > 0 ? (Double($0) / total) * 100 : 0 }
    }
    
    private var averageScore: Int {
        if total > 0 {
            let sum = reviewers.reduce(0) { $0 + $1.rating }
            return Int(Double(sum) / total)
        }
        return 0
    }
    
    private var bucketLabels: [String] {
        orderedRatings.map { ratingMap[$0]?.label ?? "" }
    }
    
    private var bucketImage: [String] {
        orderedRatings.map { ratingMaps[$0]?.image ?? "chefsKissIcon" }
    }
    
    private var bucketColors: [Color] {
        orderedRatings.map { ratingMap[$0]?.color ?? .gray }
    }
    
    private var bucketUsers: [[ReviewerWithRating]] {
        orderedRatings.map { ratingBuckets[$0] ?? [] }
    }
    
    @ViewBuilder
    private func stackedAvatars<T: Identifiable>(users: [T], isMembers: Bool = true, avatarKeyPath: KeyPath<T, String?>) -> some View where T.ID == String {
        let visibleUsers = Array(users.prefix(3))
        ZStack(alignment: .leading) {
            if visibleUsers.count >= 3 {
                avatarView(url: visibleUsers[2][keyPath: avatarKeyPath], offset: -20, zIndex: 1)
            }
            if visibleUsers.count >= 2 {
                avatarView(url: visibleUsers[1][keyPath: avatarKeyPath], offset: -13, zIndex: 2)
            }
            if visibleUsers.count >= 1 {
                avatarView(url: visibleUsers[0][keyPath: avatarKeyPath], offset: -5, zIndex: 3)
            }
            if users.count > 3 {
                Text("+\(users.count - 3)\(isMembers ? " members" : "")")
                    .font(.system(size: 9))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .padding(8)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.08), radius: 8.8, x: 0, y: 2)
                            RoundedRectangle(cornerRadius: 23)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(.white)
                        }
                    }
                    .zIndex(4)
            }
        }
    }
    
    @ViewBuilder
    private func avatarView(url: String?, offset: CGFloat, zIndex: Double) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
            case .failure, .empty:
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundStyle(.gray)
            @unknown default:
                EmptyView()
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
    
    var body: some View {
        ZStack {
//            Color.white
//                .ignoresSafeArea()
            VStack {
                
                VStack {
                    
                    ZStack {
                        HalfStrokedCircleView(
                            percentages: percentages,
                            colors: bucketColors
                        )
                        .frame(height: 244)
                        .overlay(alignment: .topLeading) {
                            Button{
                                isShowing = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .background{
                                        Circle()
                                            .foregroundStyle(.ashTastys)
                                            .frame(width: 40, height: 40)
                                    }
                            }
                            .padding(.leading)
//                            .offset(y: 45)
                        }
                        .overlay(alignment: .top) {
                            Text("Tastys Score")
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                            
                        }
//                        .padding(.top)
                        
                        VStack(spacing: 12) {
                            VStack {
                                Image(emoji)
                                    .resizable()
                                    .scaledToFit()
//                                    .font(.system(size: 23))
                                    .id(emoji)
                                    .frame(width: 40, height: 50)
                            
                            
                            Text("\(averageScore)%")
                                .foregroundStyle(.black)
                                .font(.system(size: 41))
                                .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text((vm.currentDish?.dish.name ?? "").capitalized)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                
                                Text("Tasty's score")
                                    .foregroundStyle(.black)
                                    .opacity(0.5)
                                    .font(.system(size: 14.5))
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    VStack {
                        Divider()
                            .padding(.bottom)
                        
                        ForEach(0..<orderedRatings.count, id: \.self) { index in
                            HStack {
                                Image(bucketImage[index])
                                    .resizable()
                                    .scaledToFit()
//                                    .font(.system(size: 23))
                                    .id(bucketImage[index])
                                    .frame(width: 28, height: 30)
                                
                                Text(bucketLabels[index])
                                    .foregroundStyle(.black)
                                    .opacity(0.5)
                                    .font(.system(size: 16.5))
                                    .fontWeight(.medium)
                                
                                Text("\(Int(percentages[index]))%")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16.5))
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                stackedAvatars(users: bucketUsers[index], isMembers: true, avatarKeyPath: \.avatar)
                            }
                        }
                    }
                    .offset(y: -20)
                }
                .frame(height: 440)
                .padding(.top)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.12), radius: 53, x: 0, y: 24)
                }
                .padding(.horizontal)
                .frame(height: 450)
                
                
            }
            .padding(12)
            
            if vm.isLoading {
                Color.white.opacity(0.3)
//                    .ignoresSafeArea()
                    .frame(height: 440)
                    .padding(.top)
                    .padding(.horizontal)
                    .background {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.12), radius: 53, x: 0, y: 24)
                    }
                    .padding(.horizontal)
                    .frame(height: 450)
                
                ProgressView()
                
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .task {
            await vm.fetchDishDetail(dishId: dishId, userId: vm.session?.user.id.uuidString)
        }
    }
    private var emoji: String {
        switch averageScore {
        case 0...69:
            return "mehIcon"
        case 70...79:
            return "solidIcon"
        case 80...94:
            return "fireIcon"
        case 95...100:
            return "chefsKissIcon"
        default:
            return "chefsKissIcon"
        }
    }
}
