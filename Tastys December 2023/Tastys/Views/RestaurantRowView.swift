//
//  RestaurantRowView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 10/03/2023.
//

import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var favorites: FavoritesStore
    var distance: Double? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(restaurant.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(Theme.titleFont)
                Text(restaurant.cuisine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let distance {
                    Text(Measurement(value: distance, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            StarRatingView(rating: restaurant.rating, size: 12)

            Button {
                favorites.toggle(restaurant)
            } label: {
                Image(favorites.contains(restaurant) ? "bookmarkFill" : "bookmarkIcon")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    RestaurantRowView(restaurant: SampleData.restaurants[0])
        .environmentObject(FavoritesStore())
        .padding()
}
