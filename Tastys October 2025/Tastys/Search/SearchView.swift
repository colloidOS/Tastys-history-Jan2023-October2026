//
//  SearchView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/07/2023.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var query = ""
    @State private var selectedCuisine: String?
    @State private var selectedDiets: Set<Diet> = []

    private var results: [Restaurant] {
        viewModel.restaurants.filter { restaurant in
            (query.isEmpty || restaurant.name.localizedCaseInsensitiveContains(query)
                || restaurant.dishes.contains { $0.name.localizedCaseInsensitiveContains(query) })
            && (selectedCuisine == nil || restaurant.cuisine == selectedCuisine)
            && selectedDiets.isSubset(of: Set(restaurant.diets))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SampleData.cuisines, id: \.self) { cuisine in
                            chip(cuisine, icon: cuisine, isOn: selectedCuisine == cuisine) {
                                selectedCuisine = selectedCuisine == cuisine ? nil : cuisine
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Diet.allCases) { diet in
                            chip(diet.title, icon: diet.iconName, isOn: selectedDiets.contains(diet)) {
                                if selectedDiets.contains(diet) { selectedDiets.remove(diet) } else { selectedDiets.insert(diet) }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                List(results) { restaurant in
                    NavigationLink(value: restaurant) {
                        RestaurantRowView(restaurant: restaurant)
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if results.isEmpty {
                        ContentUnavailableView.search(text: query)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Dishes or restaurants")
            .navigationDestination(for: Restaurant.self) { RestaurantDetailView(restaurant: $0) }
        }
    }

    private func chip(_ title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isOn ? Color.tastysRed : Color.grayTastys.opacity(0.15), in: Capsule())
            .foregroundStyle(isOn ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
