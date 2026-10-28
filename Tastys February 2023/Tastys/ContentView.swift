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
                HStack {
                        Text(restaurant.name)
                        Spacer()
                        Text(String(format: "%.1f", restaurant.rating))
                            .foregroundStyle(.secondary)
                    }
            }
            .listStyle(.plain)
            .navigationTitle("Tastys")
        }
    }
}

#Preview {
    ContentView()
}
