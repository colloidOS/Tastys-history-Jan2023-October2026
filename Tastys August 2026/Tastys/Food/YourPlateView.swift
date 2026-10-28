//
//  YourPlateView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 19/12/2025.
//

import SwiftUI

struct YourPlateView: View {
    let plate: UserPlateWithDishes
    
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @AppStorage("selectedOption") private var selectedOption = "grid"
    @State private var options = ["grid", "list"]
    @State private var currentIndex: Int = 0
    @EnvironmentObject private var foodVM: FoodViewModel
    @EnvironmentObject private var homeVM: HomeViewModel
    @FocusState private var isTextFieldFocused: Bool
    var filteredDishes: [Dish] {
        if searchText.isEmpty {
            return plate.dishes
        }

        let query = searchText.lowercased()

        return plate.dishes.filter {
            $0.name.lowercased().contains(query) ||
            ($0.restaurantName?.lowercased().contains(query) ?? false)
        }
    }
    
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                VStack(spacing: 11){
                    HStack{
                        Button {
                            Haptics.slide()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.black)
                                .padding(18)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.9))
                                )
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            RemovePlateView(plate: plate)
                                .environmentObject(foodVM)
                        } label: {
                            Text("Remove")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.red)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .font(.system(size: 16))
                        
                        TextField("Search in \(plate.plateName)", text: $searchText)
                            .foregroundStyle(.black)
                            .font(.system(size: 15))
                            .focused($isTextFieldFocused)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    //                .padding(.top, 8)
                }
                
                // Content area
                if filteredDishes.isEmpty {
                    Spacer()
                    VStack(spacing: 13) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No dishes match your search")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    if selectedOption == "grid" {
                        // Carousel (prominent view for featured dish)
                        DishCarouselView(
                            dishes: filteredDishes,
                            currentIndex: $currentIndex,
                            carouselHeight: isTextFieldFocused ? 250 : 380, showTabButtons: $showTabButtons
                        )
                        .environmentObject(homeVM)
                        .frame(height: isTextFieldFocused ? 250 : 380)
                        .padding(.horizontal, 8)
                    } else {
                        // List / Grid view
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 14),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 20) {
                                ForEach(filteredDishes) { dish in
                                    NavigationLink{
                                        FoodDetailView(dishId: dish.id.uuidString, showTabButtons: $showTabButtons)
                                            .environmentObject(homeVM)
                                    } label: {
                                        DishCardView(
                                            dish: Dish(
                                                id: dish.id,
                                                name: dish.name,
                                                description: dish.description,
                                                categories: dish.categories,
                                                createdAt: nil,
                                                updatedAt: nil,
                                                image: dish.image,
                                                restaurantId: dish.restaurantId,
                                                restaurantName: dish.restaurantName,
                                                avgRating: dish.avgRating,
                                                ratingCount: dish.ratingCount,
                                                rating: dish.rating ?? 0,
                                                sectionType: nil,
                                                tags: nil,
                                                diets: []
                                            ),
                                            restaurant: RestaurantDetails(
                                                id: dish.restaurantId ?? UUID(),
                                                name: dish.restaurantName ?? "",
                                                image: dish.image,
                                                description: nil,
                                                address: nil,
                                                //                                            location: nil,
                                                website: nil,
                                                telephone: nil,
                                                createdAt: nil,
                                                updatedAt: nil,
                                                rank: nil,
                                                rating: nil,
                                                avgRating: nil, totalRating: nil,
                                                isBookmarked: false,
                                                distanceKm: nil,
                                                topDishes: nil
                                            ),
                                            rating: Int(dish.rating ?? 0)
                                        )
                                        .environmentObject(homeVM)
                                    }
                                    
                                    
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 4)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
                
               if !isTextFieldFocused || selectedOption == "grid" {
                    Spacer()
                }
                
                // View toggle buttons
                HStack(spacing: 40) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            Haptics.slide()
                            withAnimation(.spring()) {
                                selectedOption = option
                            }
                        } label: {
                            Image(systemName: option == "grid" ? "square.grid.2x2" : "list.bullet")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(selectedOption == option ? .black : .gray)
                                .padding(16)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 6)
                
                // Plate info footer
                VStack(spacing: 4) {
                    Text(plate.plateName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text("\(plate.dishes.count) items")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, isTextFieldFocused && selectedOption == "grid" ? 90 : 30)
            }
        }
        .enableSwipeBack()
        .onAppear{
            Haptics.prepare()
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            isTextFieldFocused = false
        }
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundStyle(.black)
//                        .padding(10)
//                        .background(Circle().fill(.white.opacity(0.9)))
//                }
//            }
//            
//            ToolbarItem(placement: .topBarTrailing) {
//                NavigationLink {
//                    RemovePlateView(plate: plate)
//                        .environmentObject(foodVM)
//                } label: {
//                    Text("Remove")
//                        .font(.system(size: 12, weight: .medium))
//                        .foregroundStyle(.red)
//                }
//            }
//        }
    }
}

// MARK: - Dish Carousel View (updated to use real data)



//#Preview {
//    YourPlateView()
//}


struct DishCarouselView: View {
    let dishes: [Dish]
    @Binding var currentIndex: Int
    @EnvironmentObject private var homeVM: HomeViewModel
    let carouselHeight: CGFloat
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(dishes.enumerated()), id: \.offset) { index, dish in
                    NavigationLink{
                        FoodDetailView(dishId: dish.id.uuidString, showTabButtons: $showTabButtons)
                            .environmentObject(homeVM)
                    } label: {
                        DishCardView(
                            dish: dish,
                            restaurant: RestaurantDetails(
                                id: dish.restaurantId ?? UUID(),
                                name: dish.restaurantName ?? "",
                                image: dish.image,
                                description: nil,
                                address: nil,
                                website: nil,
                                telephone: nil,
                                createdAt: nil,
                                updatedAt: nil,
                                rank: nil,
                                rating: nil,
                                avgRating: nil, totalRating: nil,
                                isBookmarked: false,
                                distanceKm: nil,
                                topDishes: nil
                            ),
                            rating: Int(dish.rating ?? 0)
                        )
                        .environmentObject(homeVM)
                    }
                    .frame(
                        width: cardWidth(for: index, in: geo),
                        height: carouselHeight - 20
                    )
                    .offset(x: cardOffset(for: index, in: geo))
                    .rotationEffect(cardRotation(for: index))
                    .zIndex(zIndex(for: index))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -80 {
                                    withAnimation(.spring()) {
                                        currentIndex = min(currentIndex + 1, dishes.count - 1)
                                    }
                                } else if value.translation.width > 80 {
                                    withAnimation(.spring()) {
                                        currentIndex = max(currentIndex - 1, 0)
                                    }
                                }
                            }
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: carouselHeight)
    }
    
    private func cardWidth(for index: Int, in geo: GeometryProxy) -> CGFloat {
        index == currentIndex ? geo.size.width * 0.92 : geo.size.width * 0.65
    }
    
    private func cardOffset(for index: Int, in geo: GeometryProxy) -> CGFloat {
        let spacing = geo.size.width * 0.78
        if index < currentIndex { return -spacing }
        if index > currentIndex { return spacing }
        return 0
    }
    
    private func cardRotation(for index: Int) -> Angle {
        index == currentIndex ? .degrees(0) : .degrees(index < currentIndex ? -12 : 12)
    }
    
    private func zIndex(for index: Int) -> Double {
        Double(100 - abs(index - currentIndex))
    }
}
