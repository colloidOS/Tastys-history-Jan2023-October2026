//
//  RemovePlateView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 20/12/2025.
//

import SwiftUI

struct RemovePlateView: View {
    let plate: UserPlateWithDishes
    
    @EnvironmentObject var viewModel: FoodViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDishIds: Set<UUID> = []
    @State private var isDeleting = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header area
                Text("Remove Dishes")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 16)
                
                if plate.dishes.isEmpty {
                    Spacer()
                    Text("This plate has no dishes to remove")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(plate.dishes) { dish in
                                DishRemoveCard(
                                    dish: dish,
                                    isSelected: selectedDishIds.contains(dish.id)
                                ) {
                                    if selectedDishIds.contains(dish.id) {
                                        selectedDishIds.remove(dish.id)
                                    } else {
                                        selectedDishIds.insert(dish.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                    }
                }
                
                // Bottom action buttons
                if !plate.dishes.isEmpty {
                    HStack(spacing: 16) {
                        // Cancel
                        Button {
                            Haptics.slide()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Cancel")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .background(
                                Color.gray.opacity(0.2)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            )
                        }
                        
                        // Delete
                        Button {
                            Haptics.slide()
                            deleteSelectedDishes()
                        } label: {
                            HStack {
                                Spacer()
                                if isDeleting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Delete (\(selectedDishIds.count))")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(
                                Color.red  // .tastysRed
                                    .opacity(selectedDishIds.isEmpty || isDeleting ? 0.5 : 1.0)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            )
                        }
                        .disabled(selectedDishIds.isEmpty || isDeleting)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 55)
                }
            }
        }
        .onAppear{
            Haptics.prepare()
        }
//        .enableSwipeBack()
//        .navigationBarBackButtonHidden(true)
        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    Haptics.slide()
//                    dismiss()
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundStyle(.black)
//                        .padding(8)
//                        .background(Circle().fill(.white.opacity(0.9)))
//                }
//            }
            
            ToolbarItem(placement: .principal) {
                Text("Remove")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.tastysRed)
            }
        }
    }
    
    private func deleteSelectedDishes() {
        guard !selectedDishIds.isEmpty else { return }
        
        isDeleting = true
        
        Task {
            let success = await viewModel.removeDishesFromPlate(
                userPlateId: plate.plateId,
                dishIds: Array(selectedDishIds)
            )
            
            await MainActor.run {
                isDeleting = false
                // Error is already shown via viewModel.showError
            }
            if success {
                // Optionally refresh parent data or just dismiss
                await viewModel.fetchData()
                dismiss()
            }
        }
    }
}

// MARK: - Dish Remove Card (simple preview card with selection overlay)

struct DishRemoveCard: View {
    let dish: Dish
    let isSelected: Bool
    let onTap: () -> Void
    @State private var bottomColor: Color = .gray
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                // Dish image
                AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.5)
                    @unknown default:
                        Color.gray
                    }
                }
                .frame(width: 177, height: 224)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .onAppear {
                    if let imageUrl = dish.image {
                        extractBottomColor(from: imageUrl)
                    }
                }
                
                
                
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dish.name)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(dish.restaurantName ?? "")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    
                }
                .padding(.vertical)
                .padding(.horizontal, 8)
                .frame(width: 175)
                .background(
                    ZStack {
                        // Base solid layer with gradient fade
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: bottomColor.opacity(0.05), location: 0.0),
                                .init(color: bottomColor.opacity(0.85), location: 0.5),
                                .init(color: bottomColor.opacity(1.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Background blur layer
                        bottomColor
                            .opacity(0.7)
                            .blur(radius: 37.1)
                        
                        // Additional layer blur for depth
                        bottomColor
                            .opacity(0.5)
                            .blur(radius: 40)
                    }
                )
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 4)
            .frame(width: 177, height: 224)
            // Selection indicator
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.white.opacity(0.7)))
                }
            }
            .padding(12)
            
            
//            Text(dish.name)
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(.black)
//                .lineLimit(1)
//            
//            Text(dish.restaurantName)
//                .font(.system(size: 12))
//                .foregroundColor(.gray)
//                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func extractBottomColor(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    let imageHeight = uiImage.size.height
                    let bottomRect = CGRect(x: 0,
                                            y: imageHeight * 0.7,
                                            width: uiImage.size.width,
                                            height: imageHeight * 0.3)
                    
                    if let bottomUIColor = uiImage.averageColor(from: bottomRect) {
                        await MainActor.run {
                            bottomColor = Color(uiColor: bottomUIColor)
                        }
                    }
                }
            } catch {
                print("Error extracting color: \(error)")
            }
        }
    }
}

//#Preview {
//    RemovePlateView(plate: UserPlateWithDishes(plateName: "", plateId: <#T##UUID#>, createdAt: <#T##Date?#>, updatedAt: <#T##Date?#>, dishes: <#T##[PlateDish]#>))
//}
