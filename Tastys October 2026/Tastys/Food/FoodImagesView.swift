//
//  FoodImagesView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/10/2026.
//

import SwiftUI
import Helpers


struct FoodImagesView: View {

    var dishId: String

    @Binding var showTabButtons: Bool
    @EnvironmentObject private var vm: HomeViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {

        ScrollView {

            if vm.isLoadingDishImages && vm.dishImages.isEmpty {

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.12))
                            .aspectRatio(1, contentMode: .fill)
                            .shimmering()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

            } else if vm.dishImages.isEmpty {

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
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
                .padding(.horizontal, 30)

            } else {

                LazyVGrid(columns: columns, spacing: 10) {

                    ForEach(Array(vm.dishImages.enumerated()), id: \.element.id) { index, item in

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
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.secondary)
                                    }

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

                            // Start loading the next page when
                            // we get close to the end.
                            if index >= vm.dishImages.count - 4 {
                                Task {
                                    await vm.loadMoreDishImages(dishId: dishId)
                                }
                            }
                        }
                    }

                    // Loading indicator for the next page
                    if vm.isLoadingMoreDishImages {

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
            await vm.loadDishImages(dishId: dishId)
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
    FoodImagesView(dishId: "", showTabButtons: .constant(true))
}


@MainActor
extension HomeViewModel {

    func loadDishImages(dishId: String) async {

        guard !isLoadingDishImages else {
            return
        }

        isLoadingDishImages = true
        dishImagesOffset = 0

        let params: [String: AnyJSON] = [
            "p_dish_id": .string(dishId),
            "p_limit": .integer(dishImagesLimit),
            "p_offset": .integer(0)
        ]

        let result: DishImagesResponse? = try? await supabase
            .rpc(
                "get_dish_images",
                params: params
            )
            .single()
            .execute()
            .value

        if let response = result {

            dishImages = response.images
            dishImagesTotal = response.total
            dishImagesHasMore = response.hasMore
            dishImagesOffset = response.images.count
            isLoadingDishImages = false

        } else {

            isLoadingDishImages = false
            print("Error loading dish images: request failed")
        }
    }


    func loadMoreDishImages(dishId: String) async {

        guard !isLoadingMoreDishImages,
              dishImagesHasMore else {
            return
        }

        isLoadingMoreDishImages = true

        let nextOffset = dishImagesOffset

        let params: [String: AnyJSON] = [
            "p_dish_id": .string(dishId),
            "p_limit": .integer(dishImagesLimit),
            "p_offset": .integer(nextOffset)
        ]

        let result: DishImagesResponse? = try? await supabase
            .rpc(
                "get_dish_images",
                params: params
            )
            .single()
            .execute()
            .value

        if let response = result {

            dishImages.append(contentsOf: response.images)
            dishImagesTotal = response.total
            dishImagesHasMore = response.hasMore
            dishImagesOffset += response.images.count
            isLoadingMoreDishImages = false

        } else {

            isLoadingMoreDishImages = false
            print("Error loading more dish images: request failed")
        }
    }


    func loadRestaurantImages(restaurantId: String) async {

        guard !isLoadingRestaurantImages else {
            return
        }

        isLoadingRestaurantImages = true
        restaurantImagesOffset = 0

        let params: [String: AnyJSON] = [
            "p_restaurant_id": .string(restaurantId),
            "p_limit": .integer(restaurantImagesLimit),
            "p_offset": .integer(0)
        ]

        let result: RestaurantImagesResponse? = try? await supabase
            .rpc(
                "get_restaurant_images",
                params: params
            )
            .single()
            .execute()
            .value

        if let response = result {

            restaurantImages = response.images
            restaurantImagesTotal = response.total
            restaurantImagesHasMore = response.hasMore
            restaurantImagesOffset = response.images.count
            isLoadingRestaurantImages = false

        } else {

            isLoadingRestaurantImages = false
            print("Error loading restaurant images: request failed")
        }
    }


    func loadMoreRestaurantImages(restaurantId: String) async {

        guard !isLoadingMoreRestaurantImages,
              restaurantImagesHasMore else {
            return
        }

        isLoadingMoreRestaurantImages = true

        let nextOffset = restaurantImagesOffset

        let params: [String: AnyJSON] = [
            "p_restaurant_id": .string(restaurantId),
            "p_limit": .integer(restaurantImagesLimit),
            "p_offset": .integer(nextOffset)
        ]

        let result: RestaurantImagesResponse? = try? await supabase
            .rpc(
                "get_restaurant_images",
                params: params
            )
            .single()
            .execute()
            .value

        if let response = result {

            restaurantImages.append(contentsOf: response.images)
            restaurantImagesTotal = response.total
            restaurantImagesHasMore = response.hasMore
            restaurantImagesOffset += response.images.count
            isLoadingMoreRestaurantImages = false

        } else {

            isLoadingMoreRestaurantImages = false
            print("Error loading more restaurant images: request failed")
        }
    }
}
