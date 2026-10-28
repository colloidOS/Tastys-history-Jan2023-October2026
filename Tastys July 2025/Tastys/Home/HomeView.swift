//
//  HomeView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/02/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @StateObject private var location = LocationManager()
    @State private var showNewPost = false

    private var nearby: [Restaurant] {
        viewModel.restaurants.sorted {
            ($0.distance(from: location.lastLocation) ?? .greatestFiniteMagnitude)
                < ($1.distance(from: location.lastLocation) ?? .greatestFiniteMagnitude)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("From your friends") {
                    ForEach(viewModel.feed) { post in
                        FeedCardView(post: post)
                            .listRowSeparator(.hidden)
                    }
                }

                Section("Near you") {
                    ForEach(nearby) { restaurant in
                        NavigationLink(value: restaurant) {
                            RestaurantRowView(restaurant: restaurant, distance: restaurant.distance(from: location.lastLocation))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .overlay {
                if viewModel.isLoading && viewModel.restaurants.isEmpty {
                    ProgressView()
                } else if let message = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Couldn't load", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") { Task { await viewModel.load() } }
                    }
                }
            }
            .navigationTitle("Tastys")
            .navigationDestination(for: Restaurant.self) { RestaurantDetailView(restaurant: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNewPost = true } label: { Image("plus") }
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
            .refreshable { await viewModel.load() }
            .task {
                location.requestPermission()
                if viewModel.restaurants.isEmpty { await viewModel.load() }
            }
        }
    }
}
