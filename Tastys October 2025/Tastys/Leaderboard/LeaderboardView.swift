//
//  LeaderboardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/06/2024.
//

import SwiftUI

struct LeaderboardEntry: Identifiable, Hashable, Decodable {
    var id: String
    var dishName: String
    var restaurantName: String
    var score: Double
    var imageName: String

    enum CodingKeys: String, CodingKey {
        case id = "dish_id"
        case dishName = "dish_name"
        case restaurantName = "restaurant_name"
        case score
        case imageName = "image_name"
    }

    static func local(from restaurants: [Restaurant]) -> [LeaderboardEntry] {
        restaurants
            .flatMap { r in r.dishes.map { (r, $0) } }
            .map { LeaderboardEntry(id: "\($0.1.id)", dishName: $0.1.name, restaurantName: $0.0.name,
                                    score: $0.1.averageRating * 2, imageName: $0.1.imageName) }
            .sorted { $0.score > $1.score }
    }
}

struct LeaderboardView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var entries: [LeaderboardEntry] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(entries.prefix(50).enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: 12) {
                        if index < 3 {
                            Image("Medal\(index + 1)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        } else {
                            Text("\(index + 1)")
                                .font(.headline)
                                .frame(width: 28)
                        }
                        Image(entry.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading) {
                            Text(entry.dishName).font(.headline)
                            Text(entry.restaurantName).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.1f", entry.score))
                            .font(.headline)
                            .foregroundStyle(index == 0 ? Color.firstPlaceTastys : .primary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Leaderboard")
            .task {
                entries = (try? await SupabaseAPIClient().fetchLeaderboard())
                    ?? LeaderboardEntry.local(from: viewModel.restaurants)
            }
        }
    }
}
