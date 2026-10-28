//
//  RestaurantListView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/08/2023.
//

import SwiftUI

struct RestaurantListView: View {
    @StateObject private var location = LocationManager()

    private var restaurants: [Restaurant] {
        SampleData.restaurants.sorted {
            ($0.distance(from: location.lastLocation) ?? .greatestFiniteMagnitude)
                < ($1.distance(from: location.lastLocation) ?? .greatestFiniteMagnitude)
        }
    }

    var body: some View {
        NavigationStack {
            List(restaurants) { restaurant in
                NavigationLink(value: restaurant) {
                    RestaurantRowView(restaurant: restaurant, distance: restaurant.distance(from: location.lastLocation))
                }
            }
            .listStyle(.plain)
            .navigationTitle("Tastys")
            .navigationDestination(for: Restaurant.self) { RestaurantDetailView(restaurant: $0) }
            .onAppear { location.requestPermission() }
        }
    }
}
