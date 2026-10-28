//
//  MainTabView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/08/2023.
//

import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable { case home, search }

    @State private var selection: Tab = .home

    var body: some View {
        TabView(selection: $selection) {
            RestaurantListView()
                .tabItem {
                    Label("Home", image: selection == .home ? "homeButtonFilled" : "homeButton")
                }
                .tag(Tab.home)
            SearchView()
                .tabItem {
                    Label("Search", image: selection == .search ? "searchButtonFilled" : "searchButton")
                }
                .tag(Tab.search)
        }
    }
}

#Preview {
    MainTabView()
}
