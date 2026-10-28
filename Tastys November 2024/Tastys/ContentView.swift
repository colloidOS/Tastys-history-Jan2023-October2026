//
//  ContentView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/01/2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        Group {
            if !hasOnboarded {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: hasOnboarded)
    }
}

#Preview {
    ContentView()
        .environmentObject(FavoritesStore())
        .environmentObject(PlateStore())
}
