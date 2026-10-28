//
//  FoodView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/12/2025.
//

import SwiftUI

struct FoodView: View {
    @State private var selectedOption = "Saved plate"
    @State private var options = ["Saved plate", "Next Bites"]
    @State private var searchText = ""
    
    @StateObject private var vm = FoodViewModel()
    @EnvironmentObject private var homeVM: HomeViewModel  // if needed elsewhere
    
    @State private var showCreatePlateSheet = false
    @FocusState private var isTextFieldFocused: Bool
    var filteredPlates: [UserPlateWithDishes] {
        if searchText.isEmpty {
            return vm.userPlates
        }
        return vm.userPlates.filter {
            $0.plateName.lowercased().contains(searchText.lowercased())
        }
    }
    
    var filteredRestaurants: [RestaurantDetails] {
        print("user's bookmarked restaurants: \(vm.bookmarkedRestaurants)")
        if searchText.isEmpty {
            return vm.bookmarkedRestaurants
        }
        return vm.bookmarkedRestaurants.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    @Binding var showTabButtons: Bool   // Received from MainTabView
    @State private var lastOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if let error = vm.errorMessage {
                PopUpView(error: error)
            }
            
            VStack(spacing: 21) {
                // Header
                Text("My Plates")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 8)
                
                // Segmented control
                VStack(spacing: 0) {
                    HStack(spacing: 20) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                Haptics.slide()
                                selectedOption = option
                            } label: {
                                VStack(spacing: 5) {
                                    Text(option)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedOption == option ? .black : .gray)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(height: 5)
                                        .foregroundColor(.black)
                                        .opacity(selectedOption == option ? 1 : 0)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .foregroundColor(.black)
                        .font(.system(size: 15))
                        .focused($isTextFieldFocused)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                
                // Content
                if vm.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    ScrollView {
                        if selectedOption == "Saved plate" {
                            if filteredPlates.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    Text("No plates yet")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, minHeight: 300)
                            } else {
                                ForEach(filteredPlates) { plate in
                                    NavigationLink {
                                        YourPlateView(plate: plate, showTabButtons: $showTabButtons)
                                            .environmentObject(vm)
                                            .environmentObject(homeVM)
//                                            .navigationBarBackButtonHidden(true)
                                    } label: {
                                        plateRow(plate: plate)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                            }
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                            }
                            .frame(height: 0)
                        }
                        else if selectedOption == "Next Bites" {
                            if filteredRestaurants.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 54))
                                        .foregroundColor(.gray)
                                    Text("No saved places yet")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, minHeight: 300)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 12) {
                                    ForEach(filteredRestaurants) { restaurant in
                                        NavigationLink {
                                            RestaurantDetailView(restaurantId: restaurant.id.uuidString, dishImage: restaurant.image ?? "", showTabButtons: $showTabButtons)
                                                .environmentObject(homeVM)
                                        } label: {
                                            RestaurantCardView(
                                                restaurant: restaurant,
                                                restaurantScore: Int(restaurant.rating ?? 0)
                                            )
                                            .environmentObject(homeVM)
                                            
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                                    }
                                    .frame(height: 0)
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                    }
                    .refreshable {
                        await vm.fetchData()
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                
                // Floating action button for creating new plate
                if selectedOption == "Saved plate" {
                    Button {
                        Haptics.slide()
                        showCreatePlateSheet = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add New Plate")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                            Spacer()
                        }
                        .background(Color.red)  // .tastysRed
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $showCreatePlateSheet) {
            AddNewPlateView(onSuccess: {
                Task { await vm.fetchData() }
            })
            .presentationDetents([.fraction(1/3)])
            .environmentObject(vm)  // pass FoodViewModel
        }
        .onAppear {
            Haptics.prepare()
            Task { await vm.fetchData() }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { currentOffset in
            let directionIsUp = currentOffset > lastOffset
            if abs(currentOffset - lastOffset) > 5 {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabButtons = directionIsUp || currentOffset >= 0  // Also show when at top
                }
            }
            lastOffset = currentOffset
        }
    }
    
//    private func fetchData() async {
//        guard let userId = vm.session?.user.id else {
//            print("no user found")
//            return
//        }
//        if let bookmarks = await vm.getUserBookmarks(userId: userId) {
//            await MainActor.run {
//                vm.userPlates = bookmarks.plates
//                vm.bookmarkedRestaurants = bookmarks.bookmarkedRestaurants
//            }
//        }
//    }
    
    @ViewBuilder
    private func plateRow(plate: UserPlateWithDishes) -> some View {
        HStack(spacing: 12) {
            // Stacked dish images preview
            if !plate.dishes.isEmpty {
                ZStack {
                    ForEach(Array(plate.dishes.prefix(3).enumerated().reversed()), id: \.offset) { index, dish in
                        AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                
                            case .failure(_):
                                ZStack {
                                    ForEach(0..<3, id: \.self) { placeholderIndex in
                                        RoundedRectangle(cornerRadius: 13)
                                            .fill(Color.gray.opacity(0.35))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white, lineWidth: 2.5)
                                            )
                                            .frame(
                                                width: 60 + CGFloat(placeholderIndex * 4),
                                                height: 60 + CGFloat(placeholderIndex * 8)
                                            )
                                            .offset(x: CGFloat(placeholderIndex * 8))
                                            .rotationEffect(.degrees(Double(placeholderIndex) * -5))
                                    }
                                }
                                
                            case .empty:
                                ZStack {
                                    ForEach(0..<3, id: \.self) { placeholderIndex in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.35))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 13)
                                                    .stroke(Color.white, lineWidth: 2.5)
                                            )
                                            .frame(
                                                width: 60 + CGFloat(placeholderIndex * 4),
                                                height: 60 + CGFloat(placeholderIndex * 8)
                                            )
                                            .offset(x: CGFloat(placeholderIndex * 8))
                                            .rotationEffect(.degrees(Double(placeholderIndex) * -5))
                                    }
                                }
                                .shimmering()
                                
                            @unknown default:
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.6))
                            }
                        }
                        .frame(width: 60 + CGFloat(index * 4), height: 60 + CGFloat(index * 8))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 6)
                        .offset(x: CGFloat(index * 8))
                        .rotationEffect(.degrees(Double(index) * -5))
                    }
                }
                .frame(width: 100, height: 70)
            } else {
                ZStack {
                    ForEach((0..<3).reversed(), id: \.self) { placeholderIndex in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.35))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 2.5)
                            )
                            .frame(
                                width: 60 + CGFloat(placeholderIndex * 4),
                                height: 60 + CGFloat(placeholderIndex * 8)
                            )
                            .offset(x: CGFloat(placeholderIndex * 8))
                            .rotationEffect(.degrees(Double(placeholderIndex) * -5))
                    }
                }
                .frame(width: 100, height: 70)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plate.plateName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("\(plate.dishes.count) item\(plate.dishes.count > 1 ? "s" : "")")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
//        .padding(.horizontal, 9)
        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .padding(.horizontal, 10)
    }
}

#Preview {
    FoodView(showTabButtons: .constant(true))
        .environmentObject(HomeViewModel())
}
