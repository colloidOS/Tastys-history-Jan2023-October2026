//
//  DishCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/12/2025.
//

import UIKit
import SwiftUI


struct DishCardView: View {
    let dish: Dish
    let restaurant: RestaurantDetails
    let rating: Int
    let size: CGFloat
    
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var bottomColor: Color = .gray
    @State private var dishScore: Int
    @State private var showAddToPlateSheet: Bool = false
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @State private var showAuthPopup = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    init(dish: Dish, restaurant: RestaurantDetails, rating: Int, size: CGFloat = 180) {
        self.dish = dish
        self.restaurant = restaurant
        self.rating = rating
        _dishScore = State(initialValue: rating)
        self.size = size
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            CachedAsyncImage(
                urlString: dish.image,
                onImageLoaded: { image in
                    updateBottomColor(from: image, key: dish.image ?? "")
                }
            ) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.plumTastys
                
//                Image("logoImage")
//                    .resizable()
//                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 19))
            .frame(width: size, height: size)
            .onAppear {
                Haptics.prepare()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    Haptics.revealDone()

                    if !viewModel.isAuthenticated {
                        showAuthPopup = true
                    } else {
                        showAddToPlateSheet.toggle()
                    }

                } label: {
                    Image("bookmarkIcon")
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background {
                            if #available(iOS 26.0, *) {
                                Circle()
                                    .fill(bottomColor.opacity(0.4))
                                    .glassEffect(.regular, in: .circle)
                            } else {
                                ZStack {
                                    bottomColor
                                        .clipShape(Circle())
                                        .opacity(0.75)

                                    Circle()
                                        .foregroundStyle(.black)
                                        .opacity(0.75)
                                        .blur(radius: 38)
                                        .clipped()
                                        .clipShape(Circle())

                                    Circle()
                                        .stroke(lineWidth: 1.0)
                                        .foregroundStyle(.white)
                                        .opacity(0.1)
                                }
                            }
                        }
                        .frame(width: 42, height: 38)
                }
//                .buttonStyle(.plain)
                .padding([.trailing, .top], 5)
            }

            VStack{
                HStack{

                    Spacer()
                }
                Spacer()
            }
            .padding([.top, .horizontal], 6)
            // Text with extracted bottom color and gradient fade

                VStack {

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text((dish.name).capitalized)
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text((restaurant.name).capitalized)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }

                        Spacer()


                    }
                    .padding(.bottom)
                    .padding(.horizontal, 9)
                    .frame(width: size)

                    .padding(.top)
                }

                .frame(width: size)
                .background{
                    bottomColor
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                }
                .overlay(alignment: .topLeading) {
                    Button{
                        Haptics.revealDone()
                        viewModel.currentDish = nil
                        viewModel.breakdownDishId = dish.id.uuidString
                        withAnimation(.easeInOut) {
                            viewModel.showRatingBreakdown.toggle()
                        }
                    } label: {
                        ReuseableScoreBorderView(score: rating)
                            .scaleEffect(0.8)

                    }
                    .padding(4)
                    .background{
                        bottomColor
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .scaleEffect(0.8)
                    }
                    .offset(y: -18)
                }
//            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .shadow(radius: 4)
        .frame(width: size, height: size)
        .sheet(isPresented: $showAddToPlateSheet) {
            AddToPlateView(dishes: [dish])
                .presentationDetents([.fraction(2.0 / 3.0)])
                .environmentObject(viewModel)
        }
        .alert("Sign Up Required", isPresented: $showAuthPopup) {
            Button("Sign Up") {
                guestRouter.goToSignup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need to create an account to add this dish to plates.")
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

    /// Reuses the UIImage that CachedAsyncImage already downloaded/cached — no
    /// second network fetch. Also caches the resulting color per-URL so it's
    /// not recomputed every time this card re-appears.
    private func updateBottomColor(from image: UIImage, key: String) {
        guard !key.isEmpty else { return }
        Task {
            if let cached = await ImageCacheManager.shared.cachedColor(for: key) {
                await MainActor.run { bottomColor = cached }
                return
            }
            if let color = await Self.dominantBottomColor(from: image) {
                await MainActor.run { bottomColor = color }
                await ImageCacheManager.shared.setColor(color, for: key)
            }
        }
    }

    /// Runs off the main actor so sampling a large image never hitches scrolling.
    private static func dominantBottomColor(from image: UIImage) async -> Color? {
        await Task.detached(priority: .utility) {
            let imageHeight = image.size.height
            let bottomRect = CGRect(
                x: 0,
                y: imageHeight * 0.7,
                width: image.size.width,
                height: imageHeight * 0.3
            )
            guard let uiColor = image.dominantDarkColor(from: bottomRect) else { return nil }
            return Color(uiColor: uiColor)
        }.value
    }
}

// MARK: - Color Extension for Dominant Color Extraction
extension UIImage {
    func dominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                     y: inputImage.extent.origin.y,
                                     z: inputImage.extent.size.width,
                                     w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                     parameters: [kCIInputImageKey: inputImage,
                                                kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                      green: CGFloat(bitmap[1]) / 255,
                      blue: CGFloat(bitmap[2]) / 255,
                      alpha: CGFloat(bitmap[3]) / 255)
    }
    
    // Alternative: Get average color from a specific region
    func averageColor(from rect: CGRect? = nil) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let inputImage = CIImage(cgImage: cgImage)
        let extent = rect ?? inputImage.extent
        let extentVector = CIVector(x: extent.origin.x,
                                     y: extent.origin.y,
                                     z: extent.size.width,
                                     w: extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                     parameters: [kCIInputImageKey: inputImage,
                                                kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: nil)
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                      green: CGFloat(bitmap[1]) / 255,
                      blue: CGFloat(bitmap[2]) / 255,
                      alpha: 1.0)
    }
        
    func dominantDarkColor(from rect: CGRect? = nil) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let extent = rect ?? ciImage.extent
        
        let context = CIContext()
        
        // Downscale for performance
        let scale = 20.0 / max(extent.width, extent.height)
        let resized = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let width = Int(resized.extent.width)
        let height = Int(resized.extent.height)
        
        var bitmap = [UInt8](repeating: 0, count: width * height * 4)
        
        context.render(resized,
                       toBitmap: &bitmap,
                       rowBytes: width * 4,
                       bounds: resized.extent,
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        
        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var count: CGFloat = 0
        
        for i in stride(from: 0, to: bitmap.count, by: 4) {
            let r = CGFloat(bitmap[i]) / 255
            let g = CGFloat(bitmap[i + 1]) / 255
            let b = CGFloat(bitmap[i + 2]) / 255
            
            // 🔥 luminance formula
            let luminance = 0.299 * r + 0.587 * g + 0.114 * b
            
            // 👉 only keep DARK pixels
            if luminance < 0.5 {
                totalR += r
                totalG += g
                totalB += b
                count += 1
            }
        }
        
        // fallback if no dark pixels found
        if count == 0 {
            return self.averageColor(from: rect)
        }
        
        return UIColor(
            red: totalR / count,
            green: totalG / count,
            blue: totalB / count,
            alpha: 1.0
        )
    }
}

// MARK: - Convert UIColor to SwiftUI Color
extension Color {
    init(uiColor: UIColor) {
        self.init(uiColor)
    }
}







//#Preview {
////    ColorExtractionPreview()
//    DishCardView(dish: <#Dish#>, restaurant: <#RestaurantDetails#>, rating: <#Int#>)
//    
//}



struct DishCardSkeletonView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.grayTastys.opacity(0.6))
                .frame(width: 180, height: 180)
            
            VStack {
//                HStack {
//                    RoundedRectangle(cornerRadius: 11)
//                        .fill(Color.grayTastys.opacity(0.9))
//                        .frame(width: 60, height: 30)
//                    
//                    Spacer()
//                    
//                    Circle()
//                        .fill(Color.grayTastys.opacity(0.9))
//                        .frame(width: 35, height: 31)
//                }
//                .padding([.top, .horizontal], 6)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.grayTastys.opacity(0.3))
                        .frame(width: 98, height: 14)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.grayTastys.opacity(0.3))
                        .frame(width: 80, height: 13)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.grayTastys.opacity(0.3))
                    .frame(height: 34)
            }
            .padding(.vertical)
            .padding(.horizontal, 10)
            .frame(width: 178)
            .background(
                ZStack {
                    Color.ashTastys.opacity(0.8)
                    Color.ashTastys.opacity(0.6).blur(radius: 37.1)
                    Color.ashTastys.opacity(0.5).blur(radius: 40)
                }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 21))
        .shadow(radius: 1)
        .frame(width: 176, height: 180)
        .redacted(reason: .placeholder)
    }
}
