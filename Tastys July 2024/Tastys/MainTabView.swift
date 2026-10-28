//
//  MainTabView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/08/2023.
//

import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable { case home, search, leaderboard, profile }

    @State private var selection: Tab = .home
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("Home", image: selection == .home ? "homeButtonFilled" : "homeButton")
                }
                .tag(Tab.home)
            SearchView()
                .tabItem {
                    Label("Search", image: selection == .search ? "searchButtonFilled" : "searchButton")
                }
                .tag(Tab.search)
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", image: selection == .leaderboard ? "leaderboardButtonFilled" : "leaderboardButton")
                }
                .tag(Tab.leaderboard)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
        .environmentObject(homeViewModel)
    }
}

#Preview {
    MainTabView()
        .environmentObject(FavoritesStore())
        .environmentObject(PlateStore())
}
