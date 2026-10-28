//
//  ContentView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/01/2023.
//

import SwiftUI

struct ContentView: View {
    private let restaurants = SampleData.restaurants

    var body: some View {
        NavigationStack {
            List(restaurants) { restaurant in
                NavigationLink(value: restaurant) {
                    RestaurantRowView(restaurant: restaurant)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Tastys")
            .navigationDestination(for: Restaurant.self) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
    }
}

#Preview {
    ContentView()
}
