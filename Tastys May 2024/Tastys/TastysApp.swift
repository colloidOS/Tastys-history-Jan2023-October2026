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
    @StateObject private var plates = PlateStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favorites)
                .environmentObject(plates)
                .tint(.tastysRed)
        }
    }
}
