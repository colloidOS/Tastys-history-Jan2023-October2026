//
//  NewFeedCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/09/2026.
//

import SwiftUI

struct NewFeedCardView: View {
    let post: RatingPost
    @Binding var showTabButtons: Bool
    @EnvironmentObject var viewModel: HomeViewModel
    init(post: RatingPost, showTabButtons: Binding<Bool>) {
        self.post = post
        self._showTabButtons = showTabButtons
    }
    @State private var showAddToPlateSheet: Bool = false
    var body: some View {
        let currentRating = post.dishes?.first?.rating ?? 70
        let dish = post.dishes?.first?.dish
        HStack(spacing: 7){
            if let imageURL = post.dishes?.first?.images?.first,
               !imageURL.isEmpty {

                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure(let error):
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                print("Image failed:", error)
                                print("URL:", imageURL)
                            }

                    case .empty:
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()

                    @unknown default:
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            } else if let dishImage = post.dishes?.first?.dish.image,
                      !dishImage.isEmpty {

                AsyncImage(url: URL(string: dishImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure(let error):
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                print("Dish image failed:", error)
                                print("URL:", dishImage)
                            }

                    case .empty:
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()

                    @unknown default:
                        Image("logoImage")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                
                Image("logoImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
            }
            
            VStack (alignment: .leading, spacing: 5){
                Text(dish?.name ?? "pizza ihedbh khdb")
                    .foregroundStyle(.black)
                    .font(.system(size: 11.5))
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(dish?.restaurantName ?? "pizza house")
                    .foregroundStyle(.black)
                    .font(.system(size: 10))
                    .fontWeight(.regular)
                    .opacity(0.5)
                    .lineLimit(1)
            }
//            .frame(maxWidth: 140)
//            .background(Color.yellow)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 5){
                
                
                rate(rating: currentRating)
                    .scaleEffect(0.8)
                    .offset(x: -8)
//                ReuseableScoreBorderView(score: currentRating)
//                    .scaleEffect(0.8)
                
                Text(post.post.comment ?? "kdnwqdjed")
                    .foregroundStyle(.black)
                    .fontWeight(.medium)
                    .font(Font.system(size: 10))
                    .opacity(0.5)
                    .lineLimit(1)
                
                
            }
            
//            Spacer()
            
            
            VStack(alignment: .trailing, spacing: 5){
                
                
                Text(timeAgo(from: post.post.createdAt ?? Date()))
                    .foregroundStyle(.black)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .opacity(0.5)
                
                Button {
                    Haptics.slide()
                    showAddToPlateSheet.toggle()
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

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background{
            Color.ashTastys
                .opacity(0.7)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding(.trailing, 12)
        .sheet(isPresented: $showAddToPlateSheet) {
            if let dish = post.dishes?.first?.dish {
                AddToPlateView(dishes: [dish])
                    .presentationDetents([.fraction(2.0 / 3.0)])
                    .environmentObject(viewModel)
            }
        }
    }
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func rate(rating: Int) -> some View {

        let content: (
            icon: String,
            title: String,
            bg: Color,
            stroke: Color
        ) = {

            switch rating {

            case 0...69:
                return (
                    "mehIcon",
                    "Meh",
                    .rating50,
                    .ratingStroke50
                )

            case 70...79:
                return (
                    "solidIcon",
                    "Solid",
                    .rating70,
                    .ratingStroke70
                )

            case 80...94:
                return (
                    "fireIcon",
                    "Fire",
                    .rating80,
                    .ratingStroke80
                )

            case 95...100:
                return (
                    "chefsKissIcon",
                    "Chef's Kiss",
                    .rating95,
                    .ratingStroke95
                )

            default:
                return (
                    "mehIcon",
                    "Meh",
                    .rating50,
                    .ratingStroke50
                )
            }
        }()

        return HStack(spacing: 6) {

            Image(content.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text(content.title)
                .foregroundStyle(rating >= 70 && rating < 80 ? .black : .white)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(content.bg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(content.stroke, lineWidth: 1)
        )
    }
}

#Preview {
    NewFeedCardView(post: RatingPost(id: UUID(), post: PostDetails(id: UUID(), comment: "", shared: 0, createdAt: Date(), updatedAt: Date(), tags: []), user: nil, restaurant: nil, dishes: [], engagement: nil, tags: nil), showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
}
