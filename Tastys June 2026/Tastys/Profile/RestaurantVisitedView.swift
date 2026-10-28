//
//  RestaurantVisitedView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/01/2026.
//

import SwiftUI

struct RestaurantVisitedView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject private var vm: ProfileViewModel
    var restaurants: [RestaurantDetails]
    var userId: String
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(Array(restaurants.enumerated()), id: \.element.id) { index, restaurant in
//                            GeometryReader { cardGeo in
                                NavigationLink {
                                    RestaurantDetailView(restaurantId: restaurant.id.uuidString, dishImage: restaurant.image ?? "", showTabButtons: $showTabButtons)
                                        .environmentObject(homeVM)
                                } label: {
                                    RestaurantCardView(
                                        restaurant: restaurant,
                                        restaurantScore: Int(restaurant.rating ?? 0)
                                    )
                                    .environmentObject(homeVM)
                                }
                                
//                            }
                            .frame(height: 224)
                        }
                        
                    }
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                    }
                    .frame(height: 1)
                    .padding(.horizontal)
                }
                .refreshable {
                    Task{
                        await vm.getUserVisitedRestaurants(p_user_id: userId)
                        await vm.getFriendVisitedRestaurants(p_user_id: userId)
                    }
                }
                
                
            }
            .task {
                await vm.getUserVisitedRestaurants(p_user_id: userId)
                await vm.getFriendVisitedRestaurants(p_user_id: userId)
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
            .navigationTitle("Restaurants Visited")
        }
    }
}
#Preview {
    RestaurantVisitedView(restaurants: [], userId: "", showTabButtons: .constant(true))
}
