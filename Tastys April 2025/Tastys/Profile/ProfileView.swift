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
    @AppStorage("displayName") private var displayName = ""
    @AppStorage("foodProfile") private var foodProfileRaw = FoodProfile.adventurous.rawValue
    @EnvironmentObject private var auth: AuthService
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showEdit = false

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
                            Text(profileVM.profile?.displayName ?? displayName)
                                .font(.title2.bold())
                            if let profile = FoodProfile(rawValue: foodProfileRaw) {
                                FoodProfileBadge(profile: profile)
                            }
                        }
                    }
                }

                Section("Your plate") {
                    NavigationLink("View plate") { YourPlateView() }
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

                Section {
                    Button(role: .destructive) {
                        Task { await auth.signOut() }
                    } label: {
                        Label("Log out", image: "logoutIcon")
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                Button { showEdit = true } label: { Image("pencilIcon") }
            }
            .sheet(isPresented: $showEdit) {
                EditProfileView(viewModel: profileVM)
            }
            .task { await profileVM.load() }
        }
    }
}
