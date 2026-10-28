//
//  RestaurantDetailView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/04/2023.
//

import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant

    var body: some View {
        List {
            Section {
                Image(restaurant.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .listRowInsets(EdgeInsets())

                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.cuisine)
                        .foregroundStyle(.secondary)
                    Text(restaurant.address)
                        .font(.footnote)
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
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(restaurant: SampleData.restaurants[0])
    }
}
