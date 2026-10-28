//
//  FirstOnboardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/12/2025.
//

import SwiftUI
import AuthenticationServices

struct FirstOnboardView: View {
    @State private var showAuthBox = false
    @State private var logoScale: CGFloat = 1.5
    @State private var logoOffsetY: CGFloat = UIScreen.main.bounds.height/2.2
    @State private var animatePlates = false
    @State private var animateText1 = false
    @State private var animateText2 = false
    @State private var animateText3 = false
    @State private var animateText4 = false
    @State private var animateText5 = false
    @State private var visibleNews: [NewsItem] = []
    @State private var isVisible = false
    @State private var newsOffset: CGFloat = 300
    
    let newsItems = [
        NewsItem(id: 1, image: "dp1", text: "John Rated ", food: "Pizza Hut", score: 95),
        NewsItem(id: 2, image: "dp2", text: "Sarah ate ", food: "Burger", score: 78),
        NewsItem(id: 3, image: "dp3", text: "Sasha Rated ", food: "Nobu", score: 25),
        NewsItem(id: 4, image: "dp4", text: "Audrey ate ", food: "Tuna Rolls", score: 95),
        NewsItem(id: 5, image: "dp5", text: "Michelle Rated ", food: "McDonalds", score: 45)
    ]
    
    let newsHeight: CGFloat = 300
    let scalesFromBottomToTop: [CGFloat] = [0.7, 0.85, 0.8, 0.75, 0.65, 0.55]
    let rowHeight: CGFloat = 50
    let spacingVal: CGFloat = 7
    
    private var totalRowHeight: CGFloat {
        CGFloat(newsItems.count) * rowHeight + CGFloat(max(0, newsItems.count - 1)) * spacingVal
    }
    
    private var scaleHeight: CGFloat {
        
        let finalMidYOfLastRow = totalRowHeight - rowHeight / 2
        
        let targetScaleIndex: CGFloat = 1.0
        
        let posAtEnd = targetScaleIndex
        let normalizedAtEnd = 1 - (posAtEnd / CGFloat(scalesFromBottomToTop.count - 1))
        return finalMidYOfLastRow / normalizedAtEnd
    }
    
    private func scaleForY(_ midY: CGFloat) -> CGFloat {
        let normalized = midY / scaleHeight
        let pos = (1 - normalized) * CGFloat(scalesFromBottomToTop.count - 1)
        let lowIndex = max(0, min(scalesFromBottomToTop.count - 2, Int(floor(pos))))
        let highIndex = lowIndex + 1
        let frac = pos - CGFloat(lowIndex)
        return scalesFromBottomToTop[lowIndex] + frac * (scalesFromBottomToTop[highIndex] - scalesFromBottomToTop[lowIndex])
    }
    
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
            // Plates background
            VStack(spacing: -60){
                HStack {
                    Image("plate1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 165, height: 165)
                        .offset(x: animatePlates ? -100 : -UIScreen.main.bounds.width)
                        .rotationEffect(.degrees(animatePlates ? 30 : 0))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Image("plate2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .offset(x: animatePlates ? 0 : UIScreen.main.bounds.width)
                        .rotationEffect(.degrees(animatePlates ? -30 : 0))
                }
                .offset(x: animatePlates ? 140 : 0)
                
                Spacer()
                
                HStack {
                    Image("plate4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 184, height: 184)
                        .offset(x: animatePlates ? 0 : -UIScreen.main.bounds.width)
                        .rotationEffect(.degrees(animatePlates ? 30 : 0))
                    Spacer()
                }
                .offset(x: animatePlates ? -120 : 0, y: -70)
                
                HStack {
                    Spacer()
                    Image("plate5")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 174, height: 174)
                        .offset(x: animatePlates ? 110 : UIScreen.main.bounds.width)
                        .rotationEffect(.degrees(animatePlates ? -30 : 0))
                }
                
                HStack {
                    Image("plate6")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 141, height: 141)
                        .offset(x: animatePlates ? -100 : -UIScreen.main.bounds.width)
                        .rotationEffect(.degrees(animatePlates ? 30 : 0))
//                        .animation(.easeInOut(duration: 1.5))
                    Spacer()
                }
            }
            .ignoresSafeArea()
            
            VStack{
                Image("logo")
                    .scaleEffect(logoScale)
                    .offset(y: logoOffsetY)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                
                Spacer()
                
                VStack(spacing: spacingVal){
                    ForEach(visibleNews) { item in
                        GeometryReader { geo in
                            NewsRow(image: item.image, text: item.text, food: item.food, score: item.score)
                                .scaleEffect(scaleForY(geo.frame(in: .named("newsFrame")).midY))
                        }
                        .frame(height: rowHeight)
                    }
                }
                .offset(x: 30, y: newsOffset)
                .coordinateSpace(name: "newsFrame")
                .frame(height: newsHeight, alignment: .top)
                .padding(.bottom, 20)
                .clipped()
                .overlay(alignment: .bottom){
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.clear, .fakeWhite.opacity(0.5), .fakeWhite.opacity(0.5)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: 90)
                        .padding(.horizontal, 25)
                        .opacity(isVisible ? 1 : 0)
                }
                
                VStack(spacing: 15) {
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 8) {
                        Text("Find what to")
                            .font(.system(size: 33))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Badge(
                            text: "eat",
                            gradientColors: [Color(hex: "#5DC45B"), Color(hex: "#65F384")],
                            borderColor: Color(hex: "#71ED77"),
                            borderOverlayColor: Color(hex: "#AFD8FF").opacity(0.29),
                            foreground: .white,
                            rotation: 5,
                            font: .system(size: 25)
                        )
                    }
                    .offset(y: animateText1 ? 0 : UIScreen.main.bounds.height)
                    
                    HStack(alignment: .center, spacing: 8) {
                        Text("every")
                            .font(.system(size: 33))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Badge(
                            text: "time",
                            gradientColors: [Color(hex: "#FEED6E"), Color(hex: "#FFEE67")],
                            borderColor: Color(hex: "#FAE755"),
                            borderOverlayColor: Color(hex: "#F4FFAF").opacity(0.29),
                            foreground: .black,
                            rotation: -5,
                            font: .system(size: 25)
                        )
                        Text("with")
                            .font(.system(size: 33))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .offset(y: animateText2 ? 0 : UIScreen.main.bounds.height)
                    
                    Text("Tastys")
                        .foregroundStyle(.black)
                        .font(.system(size: 33))
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#6BB9FF"),
                                            Color(hex: "#F5EFA4"),
                                            Color(hex: "#E59C55")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                    .offset(y: animateText3 ? 0 : UIScreen.main.bounds.height)
                    
                    Text("Never guess your order again")
                        .foregroundStyle(.black)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    .offset(y: animateText4 ? 0 : UIScreen.main.bounds.height)
                    
                    Spacer()
                }
                
                Spacer()
                
                NavigationLink{
                    SignUpView()
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .padding(.vertical)
                        Spacer()
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.tastysRed)
                    }
                }
                .buttonStyle(.borderless)
                .offset(y: animateText5 ? 0 : UIScreen.main.bounds.height)
                .padding(.horizontal, 40)
                .padding(.top)
            }
            
            
        }
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 1)) {
                    logoScale = 1
                    logoOffsetY = 0
                    animatePlates = true
                }
                
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateText1 = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.8)) { animateText2 = true }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.8)) { animateText3 = true }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.8)) { animateText4 = true }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        animateText5 = true
                        isVisible = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    visibleNews = newsItems
                    withAnimation(.easeInOut(duration: 6.5)) {
                        newsOffset = 0
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FirstOnboardView()
    }
}




// MARK: - Hex Color helper
extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }

        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hexString.count {
        case 6: // RRGGBB
            r = Double((int & 0xFF0000) >> 16) / 255.0
            g = Double((int & 0x00FF00) >> 8) / 255.0
            b = Double(int & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA
            r = Double((int & 0xFF000000) >> 24) / 255.0
            g = Double((int & 0x00FF0000) >> 16) / 255.0
            b = Double((int & 0x0000FF00) >> 8) / 255.0
            a = Double(int & 0x000000FF) / 255.0
        default:
            r = 1; g = 0; b = 1; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Reusable Badge view
struct Badge: View {
    let text: String
    let gradientColors: [Color]
    let borderColor: Color
    let borderOverlayColor: Color?
    let foreground: Color
    let rotation: Double
    let font: Font

    var body: some View {
        Text(text)
            .font(font)
            .fontWeight(.bold)
            .foregroundColor(foreground)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .overlay(
                Group {
                    if let overlay = borderOverlayColor {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(overlay, lineWidth: 8)
                            .blendMode(.normal)
                    } else {
                        EmptyView()
                    }
                }
            )
            .rotationEffect(.degrees(rotation))
    }
}

struct AuthBox: View {
    var body: some View {
        VStack{
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.gray)
                .frame(width: 70, height: 5)
            
            NavigationLink{
                SignUpView()
                    .navigationBarBackButtonHidden()
            } label: {
                HStack (spacing: 14){
                    Spacer()
                    
                    Text("@  Continue with email")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                    .padding(.vertical)
                    Spacer()
                        
                }
                .background{
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.ashTastys)
                }
//                        .padding()
            
            }
            .padding(.horizontal, 10)
            
            Button{
                
            } label: {
                HStack (spacing: 12){
                    Spacer()
                    Image("googleIcon")
                    Text("Continue with google")
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                    .padding(.vertical)
                    Spacer()
                        
                }
                .background{
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundStyle(.ashTastys)
                }
            
            }
            .padding(.horizontal, 10)
            
            SignInWithAppleButton(
//                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    // handle result
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(25)
            .padding(.horizontal, 10)
            
            HStack {
                Text("Have an account?")
                    .foregroundStyle(.black)
                    .opacity(0.5)
                .font(.system(size: 15))
                
                NavigationLink{
//                    SignInView(authVM: <#AuthViewModel#>)
//                        .navigationBarBackButtonHidden()
                } label:{
                    Text("Sign in")
                        .foregroundStyle(.black)
                    .opacity(0.85)
                    .font(.system(size: 15))
                }
            }
            .padding(.top, 10)
            
        
        }
        .padding(.vertical, 15)
        .padding(10)
        .background{
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(10)
        
    }
}



enum OnboardingPhase {
    case logoOnly
    case logoSettled
    case platesIn
    case textIn
    case newsStart
}



struct NewsItem: Identifiable, Equatable {
    let id: Int
    let image: String
    let text: String
    let food: String
    let score: Int
}

struct NewsRow: View {
    let image: String
    let text: String
    let food: String
    let score: Int
    
    var body: some View {
        ZStack {
            HStack {
                Image(image)
                
                Text(text)
                    .foregroundStyle(.black)
                    .font(.system(size: 13.5))
                +
                Text(food)
                    .foregroundStyle(.black)
                    .font(.system(size: 13.5))
                    .fontWeight(.semibold)
                
                Spacer()
                
                
                ReuseableScoreBorderView(score: score/*, isOnDish: false*/)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(.fakeWhite)
                
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.white)
            }
        }
        .frame(width: UIScreen.main.bounds.width / 1.15)
    }
}


