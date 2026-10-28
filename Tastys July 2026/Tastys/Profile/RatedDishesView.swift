//
//  RatedDishesView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/01/2026.
//

import SwiftUI

struct RatedDishesView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @Binding var dishes: [Dish]
    
    // optional: keep your tap/long-press logic if you still want it
    @State private var showDishTap = false
    @State private var tapPosition: CGPoint = .zero
    @State private var rotation: Double = 0.0
    @State private var dish: Dish?
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(showsIndicators: true) {   // ← inner ScrollView — this is key
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(dishes) { dish in
                    NavigationLink {
                        FoodDetailView(dishId: dish.id.uuidString, showTabButtons: $showTabButtons)
                            .environmentObject(vm)
                    } label: {
                        DishCardView(
                            dish: dish,
                            restaurant: RestaurantDetails(
                                id: dish.restaurantId ?? UUID(),
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
                                avgRating: nil, totalRating: nil,
                                isBookmarked: false,
                                distanceKm: nil,
                                topDishes: nil 
                            ),
                            rating: Int(dish.rating ?? 0)
                        )
                    }
                }
                
            }
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
//            .padding(.bottom, 100)   // extra bottom padding so last card isn't cut off
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
        .navigationTitle("Rated Dishes")
        // .coordinateSpace(name: "topRated")   // only if you still need long-press positioning
    }
}

#Preview {
    RatedDishesView(dishes: .constant([]), showTabButtons: .constant(true))
}
