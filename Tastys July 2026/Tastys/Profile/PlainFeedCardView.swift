//
//  PlainFeedCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 01/05/2026.
//

import SwiftUI

struct PlainFeedCardView: View {
    let post: RatingPost
    @Binding var showTabButtons: Bool
    @EnvironmentObject var viewModel: HomeViewModel
    init(post: RatingPost, showTabButtons: Binding<Bool>) {
        self.post = post
        self._showTabButtons = showTabButtons
    }
    var body: some View {
        let currentRating = post.dishes?.first?.rating ?? 50
        let userName: String = {
            if let firstName = post.user?.firstName,
               !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return firstName
            }

            if let lastName = post.user?.lastName,
               !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return lastName
            }

            if let username = post.user?.username,
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return username
            }

            return "Anonymous"
        }()
        ZStack(alignment: .top){
            VStack(spacing: 24){
                HStack(spacing: 8){
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
                                .frame(width: 28, height: 30)
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
                            .frame(width: 31, height: 30)
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
                        .frame(width: 32, height: 30)
                        .clipShape(Circle())
                    }
                    
                    HStack(spacing: 5){
                        if let userId = post.user?.id.uuidString {
                            if userId != viewModel.currentUser?.id.uuidString {
                                NavigationLink{
                                    FriendProfileView(friendsUserId: post.user?.id.uuidString ?? "", showTabButtons: $showTabButtons)
                                        .environmentObject(viewModel)
                                } label:{
                                    Text("\(userName)")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 12))
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                
                            } else {
                                
                                Text("\(userName)")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 12))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                
                            }
                            
                        } else {
                            Text("anonymous")
                                .foregroundStyle(.black)
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        
                        Text("•")
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                    
                    Text(timeAgo(from: post.post.createdAt ?? Date()))
                        .foregroundStyle(.black)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .opacity(0.6)
                        
                        
                    }
                    
                    Spacer()
                    
                    ReuseableScoreBorderView(score: currentRating)
                        .scaleEffect(0.86)
                    
                }
                
                
                
                
                
                HStack {
                    VStack(alignment: .leading, spacing: 5){
                        
                        
                        
                        
                        Text("“\(post.post.comment ?? "")”")
                            .foregroundStyle(.black)
                            .fontWeight(.medium)
                            .font(Font.system(size: 14))
                            .opacity(0.4)
                            .lineLimit(4)
                        
                        
                    }
                    
                    Spacer()
                }
                
               Spacer()
            }
            .padding(.top, 8)
            
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background {
            Color.rectTastys
                .frame(height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay{
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.trapWhite1)
                }
        }
        .frame(height: 126)
//        .padding(.horizontal, 20)
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

        return HStack(spacing: 7) {
            Image(content.0)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text(content.1)
                .foregroundStyle(.tastysRed)
                .font(.system(size: 15))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.rateTastys)
        )
    }
}

#Preview {
    PlainFeedCardView(post: RatingPost(id: UUID(), post: PostDetails(id: UUID(), comment: "", shared: 0, createdAt: Date(), updatedAt: Date(), tags: []), user: nil, restaurant: nil, dishes: [], engagement: nil, tags: nil), showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
}


struct PlainFeedCardSkeletonView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Top row (user info)
            HStack(spacing: 15) {
                
                // Avatar
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .shimmering()
                
                // Name + rating
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Name
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 14)
                        .shimmering()
                    
                    // Rating badge
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 20)
                        .shimmering()
                }
                
                Spacer()
            }
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 2)
                .shimmering()
            
            // MARK: - Content section
            VStack(alignment: .leading, spacing: 10) {
                
                // Time
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 12)
                    .shimmering()
                
                // Comment line 1
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 176, height: 14)
                    .shimmering()
                
                // Comment line 2 (shorter)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 14)
                    .shimmering()
            }
            
            Spacer()
        }
        .padding(20)
        .frame(width: 272, height: 210)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.08))
        )
    }
}
