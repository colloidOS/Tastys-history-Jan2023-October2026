//
//  TastysApp.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 26/01/2023.
//

import SwiftUI

@main
struct TastysApp: App {
    @StateObject private var favorites = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favorites)
                .tint(.tastysRed)
        }
    }
}
