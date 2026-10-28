//
//  ContentView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/01/2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        Group {
            if !auth.isSignedIn {
                NavigationStack { SignInView() }
            } else if !hasOnboarded {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
        .task { await auth.restoreSession() }
        .animation(.easeInOut, value: hasOnboarded)
    }
}

#Preview {
    ContentView()
        .environmentObject(FavoritesStore())
        .environmentObject(PlateStore())
        .environmentObject(AuthService())
}
