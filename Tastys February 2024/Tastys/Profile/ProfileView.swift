//
//  ProfileView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 18/10/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image("dp1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Foodie")
                                .font(.title2.bold())
                        }
                    }
                }

                Section("Bookmarked") {
                    let saved = viewModel.restaurants.filter(favorites.contains)
                    if saved.isEmpty {
                        Text("Nothing bookmarked yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(saved) { RestaurantRowView(restaurant: $0) }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
