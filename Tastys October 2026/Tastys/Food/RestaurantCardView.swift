//
//  RestaurantCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 15/01/2026.
//

import SwiftUI

struct RestaurantCardView: View {
    let restaurant: RestaurantDetails
    let restaurantScore: Int
    @State private var bottomColor: Color = .tastysRed
    @EnvironmentObject var viewModel: HomeViewModel
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: restaurant.image ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("logoImage")
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(width: 177, height: 224)
            .onAppear {
                if let imageUrl = restaurant.image {
                    extractBottomColor(from: imageUrl)
                }
            }
            VStack{
                HStack{
                    
                    ReuseableScoreBorderView(score: restaurantScore)
                    
                    
//                    HStack(spacing: 2){
//                        Text(emoji)
//                            .font(.system(size: 14))
//                        Text("\(restaurantScore)%")
//                            .foregroundStyle(.white)
//                            .font(.system(size: 14))
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 8)
//                    .background{
//                        ZStack {
//                            bottomColor
//                                .opacity(0.7)
//                                .blur(radius: 37.1)
//                            
//                            // Additional layer blur for depth
//                            bottomColor
//                                .opacity(0.5)
//                                .blur(radius: 40)
//                            
//                        }
//                    }
                    
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                    Button{
                        viewModel.prefillRestaurant = restaurant
//                        viewModel.prefillDishes = [dish]
                        viewModel.showPostView = true
                    } label: {
                        ZStack{
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
                        .frame(width: 31, height: 31)
                    }
                }
                Spacer()
            }
            .padding([.top, .horizontal], 6)
            // Text with extracted bottom color and gradient fade
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text((restaurant.name).capitalized)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
//                    Text(restaurant.name)
//                        .font(.system(size: 13))
//                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
//                Button{
//                    showAddToPlateSheet.toggle()
//                } label: {
//                    ZStack{
//                        Circle()
//                            .foregroundStyle(.white)
//                            .opacity(0.08)
//                            .blur(radius: 21.9)
//                        
//                        Circle()
//                            .stroke(lineWidth: 1.5)
//                            .foregroundStyle(.white)
//                            .opacity(0.1)
//                        
//                        Text("🍽️")
//                            .font(.system(size: 18.5))
//                    }
//                    .frame(height: 38)
//                }
//                .buttonStyle(.plain)
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
    }
    
    private var emoji: String {
        switch restaurantScore {
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
                    
                    if let bottomUIColor = uiImage.dominantDarkColor(from: bottomRect) {
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
//    RestaurantCardView()
//}
