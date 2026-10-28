//
//  AddToPlateView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/01/2026.
//

import SwiftUI

struct AddToPlateView: View {
    let dishes: [Dish]
    
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var plates: [UserPlateWithDishes] = []
    @State private var searchText: String = ""
    @State private var showCreatePlate: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    var filteredPlates: [UserPlateWithDishes] {
        if searchText.isEmpty {
            return plates
        } else {
            return plates.filter {
                $0.plateName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack {
            
            Color.ashTastys
                .opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                dragKnob
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                
                Text("Add to Plate")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.bottom, 16)
                
                // Search field
                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("Search plates...")
                            .foregroundStyle(.black.opacity(0.5))
                            .font(.system(size: 16, weight: .bold))
                            .padding(.leading, 16)
                    }
                    
                    TextField("", text: $searchText)
                        .foregroundStyle(.black)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .focused($isTextFieldFocused)
                }
                .background {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // List of plates
                if isLoading {
                    ProgressView()
                        .tint(.black)
                        .padding()
                } else if filteredPlates.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                            .opacity(0.8)
                        Text("No plates found")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .opacity(0.8)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredPlates) { plate in
                                plateRow(plate: plate)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        addDishesToPlate(plateId: plate.plateId)
                                    }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                
                Spacer(minLength: 20)
                
                // Create new plate button
                Button {
                    Haptics.slide()
                    showCreatePlate.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Text("Add New Plate")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.vertical, 16)
                        Spacer()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
        }
        .overlay {
            if viewModel.isUpdateLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.3)
                        
                        Text("Adding dishes...")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreatePlate) {
            AddNewPlateView(onSuccess: {
                fetchPlates()
            })
            .presentationDetents([.fraction(1/3)])
            .environmentObject(viewModel)
        }
        .onAppear {
            Haptics.prepare()
            fetchPlates()
        }
        .preferredColorScheme(.dark)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    
    private var dragKnob: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 40, height: 5)
            .foregroundStyle(.gray.opacity(0.5))
    }
    
    private func fetchPlates() {
        guard let userId = viewModel.session?.user.id else { return }
        
        isLoading = true
        Task {
            if let fetched = await viewModel.getUserPlates(userId: userId) {
                await MainActor.run {
                    plates = fetched
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func addDishesToPlate(plateId: UUID) {
        Task {
            for dish in dishes {
                _ = await viewModel.addDishToPlate(userPlateId: plateId, dishId: dish.id)
            }
            await MainActor.run {
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    private func plateRow(plate: UserPlateWithDishes) -> some View {
        HStack(spacing: 16) {
            // Stacked dish preview images (same style as FoodView)
            ZStack {
                ForEach(Array(plate.dishes.prefix(3).enumerated().reversed()), id: \.offset) { index, dish in
                    AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color.gray.opacity(0.5)
                        }
                    }
                    .frame(width: 56 + CGFloat(index * 6), height: 56 + CGFloat(index * 8))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                    .offset(x: CGFloat(index * 10))
                    .rotationEffect(.degrees(Double(index) * -6))
                }
            }
            .frame(width: 90, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plate.plateName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("\(plate.dishes.count) items")
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

//#Preview {
//    AddToPlateView()
//}
