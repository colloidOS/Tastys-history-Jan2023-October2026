//
//  RestaurantDetailView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/04/2023.
//

import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var dishToRate: Dish?
    @EnvironmentObject private var plates: PlateStore

    var body: some View {
        List {
            Section {
                Image(restaurant.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .listRowInsets(EdgeInsets())

                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.cuisine)
                        .foregroundStyle(.secondary)
                    Text(restaurant.address)
                        .font(.footnote)
                    StarRatingView(rating: restaurant.rating, size: 14)
                }
            }

            Section("Dishes") {
                ForEach(restaurant.dishes) { dish in
                    HStack {
                        Image(dish.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading) {
                            Text(dish.name)
                            Text(dish.formattedPrice)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            StarRatingView(rating: dish.averageRating, size: 10)
                            Text("\(dish.ratingsCount) ratings")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button("Rate") { dishToRate = dish }
                            .tint(.tastysRed)
                        Button("Add to plate") { plates.add(dish, from: restaurant) }
                            .tint(.green)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $dishToRate) { dish in
            RateDishView(dish: dish, restaurant: restaurant)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: SampleData.restaurants[0])
            .environmentObject(PlateStore())
    }
}
