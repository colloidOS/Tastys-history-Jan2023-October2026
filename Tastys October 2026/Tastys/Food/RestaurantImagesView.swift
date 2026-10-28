//
//  RestaurantImagesView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/10/2026.
//

import SwiftUI

struct RestaurantImagesView: View {

    var restaurantId: String

    @Binding var showTabButtons: Bool
    @EnvironmentObject private var vm: HomeViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {

        ScrollView {

            if vm.isLoadingRestaurantImages && vm.restaurantImages.isEmpty {

                LazyVGrid(columns: columns, spacing: 10) {

                    ForEach(0..<6, id: \.self) { _ in

                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.12))
                            .aspectRatio(1, contentMode: .fill)
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

            } else if vm.restaurantImages.isEmpty {

                VStack(spacing: 12) {

                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)

                    Text("No photos yet")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Photos uploaded by the community will appear here.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
                .padding(.horizontal, 30)

            } else {

                LazyVGrid(columns: columns, spacing: 10) {

                    ForEach(
                        Array(vm.restaurantImages.enumerated()),
                        id: \.element.id
                    ) { index, item in

                        AsyncImage(url: URL(string: item.image)) { phase in

                            switch phase {

                            case .empty:

                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.gray.opacity(0.12))
                                    .shimmering()

                            case .success(let image):

                                image
                                    .resizable()
                                    .scaledToFill()

                            case .failure:

                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.gray.opacity(0.12))
                                    

                            @unknown default:

                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.gray.opacity(0.12))
                            }
                        }
                        .frame(height: 200)
                        .frame(maxWidth: (UIScreen.main.bounds.width - 34) / 2)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        .contentShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        .onAppear {

                            // Load the next page when we're
                            // close to the end of the current page.
                            if index >= vm.restaurantImages.count - 4 {

                                Task {
                                    await vm.loadMoreRestaurantImages(
                                        restaurantId: restaurantId
                                    )
                                }
                            }
                        }
                    }

                    // Loading indicator for the next page
                    if vm.isLoadingMoreRestaurantImages {

                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .gridCellColumns(2)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
        .task {
            await vm.loadRestaurantImages(
                restaurantId: restaurantId
            )
        }
        .toolbar {

            ToolbarItem(placement: .principal) {

                Text("Gallery")
                    .foregroundStyle(.black)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
            }
        }
    }
}


#Preview {
    RestaurantImagesView(restaurantId: "", showTabButtons: .constant(true))
}
