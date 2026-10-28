//
//  FoodCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 01/05/2026.
//

import SwiftUI

struct FoodCardView: View {
    let dish: Dish
    let restaurant: RestaurantDetails
    let rating: Int
    
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var bottomColor: Color = .gray
    @State private var dishScore: Int
    @State private var showAddToPlateSheet: Bool = false
    
    init(dish: Dish, restaurant: RestaurantDetails, rating: Int) {
        self.dish = dish
        self.restaurant = restaurant
        self.rating = rating
        _dishScore = State(initialValue: rating)
    }
    var body: some View {
        ZStack {
            VStack(spacing: 15){
                ZStack(alignment: .bottomLeading) {
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
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .frame(width: 133, height: 150)
                    
                    ReuseableScoreBorderView(score: rating)
                        .scaleEffect(0.85)
                        .padding([.leading, .bottom], 12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .frame(width: 139, height: 150)
                
                
                HStack{
                    VStack(alignment: .leading, spacing: 4) {
                        Text((dish.name).capitalized)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text((restaurant.name).capitalized)
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.5))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button{
                        Haptics.revealDone()
                        showAddToPlateSheet.toggle()
                    } label: {
                        ZStack{
//                            Circle()
//                                .foregroundStyle(.fakeWhite)
//                                .opacity(0.08)
//                                .blur(radius: 21.9)
                            
                            Circle()
//                                .stroke(lineWidth: 1.5)
                                .foregroundStyle(.ashTastys)
//                                .opacity(0.1)
                            
                            Image("bookmarkVector")
                                .renderingMode(.template)
                                .foregroundStyle(.black)
                            
                        }
                        .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    
                }
                
                
            }
        }
        .frame(width: 137)
        .onAppear {
            Haptics.prepare()
            
        }
        .sheet(isPresented: $showAddToPlateSheet) {
            AddToPlateView(dishes: [dish])
                .presentationDetents([.fraction(2.0 / 3.0)])
                .environmentObject(viewModel)
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
}

#Preview {
    FoodCardView(dish: Dish(id: UUID(), name: "", description: "", categories: [""], createdAt: Date(), updatedAt: Date(), image: "", restaurantId: UUID(), restaurantName: "", avgRating: 0.0, ratingCount: 1, rating: 0.0, sectionType: nil, tags: nil, diets: []), restaurant: RestaurantDetails(id: UUID(), name: "", image: "", description: "", address: "", website: "", telephone: "", createdAt: Date(), updatedAt: Date(), rank: 0.0, rating: 0.0, avgRating: 0.0, totalRating: nil, isBookmarked: false, distanceKm: nil, topDishes: nil), rating: 1)
}


struct FoodCardSkeletonView: View {
    var body: some View {
        VStack(spacing: 15) {
            
            // MARK: - Image section
            ZStack(alignment: .bottomLeading) {
                
                RoundedRectangle(cornerRadius: 21)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 135, height: 150)
                    .shimmering()
                
                // Score badge placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 45, height: 22)
                    .padding([.leading, .bottom], 12)
                    .shimmering()
            }
            .frame(width: 137, height: 150)
            
            
            // MARK: - Bottom section
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Dish name
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 90, height: 14)
                        .shimmering()
                    
                    // Restaurant name
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 71, height: 12)
                        .shimmering()
                }
                
                Spacer()
                
                // Bookmark button
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 34, height: 38)
                    .shimmering()
            }
        }
        .frame(width: 137)
    }
}
