//
//  RestaurantListView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/08/2023.
//

import SwiftUI

struct RestaurantListView: View {

    private var restaurants: [Restaurant] {
        SampleData.restaurants
    }

    var body: some View {
        NavigationStack {
            List(restaurants) { restaurant in
                NavigationLink(value: restaurant) {
                    RestaurantRowView(restaurant: restaurant)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Tastys")
            .navigationDestination(for: Restaurant.self) { RestaurantDetailView(restaurant: $0) }
        }
    }
}
