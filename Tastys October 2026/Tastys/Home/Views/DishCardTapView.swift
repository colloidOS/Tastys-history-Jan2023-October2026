//
//  DishCardTapView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/01/2026.
//

import SwiftUI

struct DishCardTapView: View {
    let dish: Dish
    let restaurant: RestaurantDetails
    let rating: Int
    
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var bottomColor: Color = .gray
    @State private var dishScore: Int
    @State private var showAddToPlateSheet: Bool = false
    
    @State private var plusOffset: CGSize = CGSize(width: 0, height: 50)
    @State private var eatOffset: CGSize = CGSize(width: -10, height: 20)
    
    init(dish: Dish, restaurant: RestaurantDetails, rating: Int) {
        self.dish = dish
        self.restaurant = restaurant
        self.rating = rating
        _dishScore = State(initialValue: rating)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Color.red // Error placeholder
                } else {
                    Color.gray // Loading placeholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(width: 177, height: 224)
            .onAppear {
                Haptics.prepare()
                if let imageUrl = dish.image {
                    extractBottomColor(from: imageUrl)
                }
                withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
                    plusOffset = CGSize(width: 46, height: 0)
                    eatOffset = CGSize(width: 10, height: 48)
                }
            }
            VStack{
                HStack{
//                    HStack(spacing: 2){
//                        Text(emoji)
//                            .font(.system(size: 14))
//                        Text("\(rating)%")
//                            .foregroundStyle(.white)
//                            .font(.system(size: 14))
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 8)
//                    .background{
//                        ZStack {
//                            bottomColor
//                            
//                            bottomColor
//                                .opacity(0.7)
//                                .blur(radius: 7.1)
//                            
//                            // Additional layer blur for depth
//                            bottomColor
//                                .opacity(0.5)
//                                .blur(radius: 40)
//                            
//                        }
//                    }
//                    
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    ReuseableScoreBorderView(score: rating)
                    Spacer()
                    
                }
                Spacer()
            }
            .padding([.top, .horizontal], 6)
            // Text with extracted bottom color and gradient fade
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text((dish.name).capitalized)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Text((restaurant.name).capitalized)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                
            }
            .padding(.vertical)
            .padding(.horizontal, 8)
            .frame(width: 177)
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
        .overlay(alignment: .bottomTrailing) {
            Button {
                Haptics.slide()
                viewModel.prefillRestaurant = restaurant
                viewModel.prefillDishes = [dish]
                viewModel.showPostView = true
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(bottomColor)
                    
                    bottomColor
                        .opacity(0.7)
                        .blur(radius: 37.1)
                    
                    // Additional layer blur for depth
                    bottomColor
                        .opacity(0.5)
                        .blur(radius: 40)
                    
                    
                    Image("plus")
                }
                .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)
            .offset(plusOffset)
            
            Button {
                Haptics.slide()
                showAddToPlateSheet.toggle()
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(bottomColor)
                    
                    bottomColor
                        .opacity(0.7)
                        .blur(radius: 37.1)
                    
                    // Additional layer blur for depth
                    bottomColor
                        .opacity(0.5)
                        .blur(radius: 40)
                    
                    Circle()
                        .foregroundStyle(.white)
                        .opacity(0.08)
                        .blur(radius: 21.9)
                    
                    Circle()
                        .stroke(lineWidth: 1.5)
                        .foregroundStyle(.white)
                        .opacity(0.1)
                    
                    Text("🍽️")
                        .font(.system(size: 18.5))
                }
                .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)
            .offset(eatOffset)
        }
        .sheet(isPresented: $showAddToPlateSheet) {
            AddToPlateView(dishes: [dish])
                .presentationDetents([.fraction(2.0 / 3.0)])
                .environmentObject(viewModel)
        }
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
    private var emoji: String {
        switch rating {
        case 0...69:
            return "🤢"
        case 70...79:
            return "🙂"
        case 80...94:
            return "😋"
        case 95...100:
            return "🤤"
        default:
            return "🙂"
        }
    }

}

//#Preview {
//    DishCardTapView(dishImage: "dishImage")
//}


