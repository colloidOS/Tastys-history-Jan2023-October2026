//
//  LaunchView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 16/12/2025.
//

import SwiftUI
import UIKit

struct LaunchView: View {
    @State private var showWaitlist = false
    @AppStorage("waitlisted") private var isWaitlisted = false
    @AppStorage("waitlistNumber")private var waitlistNumber: Int?
    var body: some View {
        NavigationStack {   // ← this is required
            ZStack {
                AnimateLaunchView()
                
            
            }
            .navigationDestination(isPresented: $showWaitlist) {
                if !isWaitlisted {
                    WaitlistView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    SuccessfulWaitlistView(listNumber: waitlistNumber ?? 0)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onAppear {
            Haptics.prepare()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                Haptics.revealDone()
                showWaitlist = true
            }
        }
    }
}

#Preview {
    LaunchView()
}








struct IconSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct LogoSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct PatchRevealModifier: ViewModifier {
    let reveal: Bool
    let duration: Double
    let patchSize: CGFloat
    let animationDuration: Double = 0.2
    
    @State private var delays: [Double] = []
    @State private var viewSize: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                GeometryReader { geo in
                    let pSize = patchSize
                    let columns = Int(ceil(geo.size.width / pSize))
                    let rows = Int(ceil(geo.size.height / pSize))
                    let total = rows * columns
                    
                    ZStack(alignment: .topLeading) {
                        if delays.count != total || viewSize != geo.size {
                            Color.clear
                                .onAppear {
                                    viewSize = geo.size
                                    delays = (0..<total).map { _ in
                                        Double.random(in: 0...duration)
                                    }
                                }
                        } else {
                            let pWidth  = geo.size.width  / CGFloat(columns)
                            let pHeight = geo.size.height / CGFloat(rows)
                            
                            ForEach(0..<total, id: \.self) { index in
                                let row = index / columns
                                let col = index % columns
                                
                                Rectangle()
                                    .fill(Color.tastysRed)
                                    .frame(width: pWidth, height: pHeight)
                                    .offset(x: CGFloat(col) * pWidth, y: CGFloat(row) * pHeight)
                                    .opacity(reveal ? 0 : 1)
                                    .animation(
                                        .easeOut(duration: animationDuration)
                                            .delay(delays[index]),
                                        value: reveal
                                    )
                            }
                        }
                    }
                }
            }
    }
}

struct AnimateLaunchView: View {
    @State private var revealIcon = false
    @State private var revealLogo = false
    @State private var iconOffset: CGFloat = 0
    @State private var logoOffset: CGFloat = 20
    @State private var iconSize: CGSize = .zero
    @State private var logoSize: CGSize = .zero
    @State private var showLogo = false
    
    let revealDuration: Double = 0.6         // 1–2 sec: icon appears
    let pauseAfterIconReveal: Double = 0.4    // small pause
    let slideDuration: Double = 0.6           // 3–4 sec: slide left
    let pauseAfterSlide: Double = 0.4         // small pause
    let logoRevealStartDelay: Double = 1.5    // starts at ~5 sec
    
    var body: some View {
        ZStack {
            Color.tastysRed
                .ignoresSafeArea()
            
            ZStack/*(spacing: 2)*/ {
                
                
                Image("launchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 222, height: 110)
                    .offset(x: logoOffset, y: 5)
                    .opacity(showLogo ? 1 : 0)
                    .modifier(PatchRevealModifier(reveal: revealLogo, duration: revealDuration, patchSize: 10))
                    .background {
                        GeometryReader { geo in
                            Color.clear.preference(key: LogoSizeKey.self, value: geo.size)
                        }
                    }
                
                Image("launchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92, height: 90)
                    .offset(x: iconOffset)
                    .modifier(PatchRevealModifier(reveal: revealIcon, duration: revealDuration, patchSize: 10))
                    .background {
                        GeometryReader { geo in
                            Color.clear.preference(key: IconSizeKey.self, value: geo.size)
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .allowsHitTesting(false)
        .compositingGroup()
        .onPreferenceChange(IconSizeKey.self) { iconSize = $0 }
        .onPreferenceChange(LogoSizeKey.self) { logoSize = $0 }
        .onAppear {
            Haptics.prepare()
            
            // 1–2s: icon reveal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                Haptics.tick()
                withAnimation/*(.easeInOut(duration: 1.0))*/ {
                    revealIcon = true
                }
            }

            // 3–4s: slide
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
//                guard iconSize != .zero, logoSize != .zero else { return }

//                let spacing: CGFloat = 0
//                let distance = (iconSize.width + logoSize.width) / 2 + spacing
                Haptics.slide()
                withAnimation(.easeInOut(duration: 0.6)) {
                    iconOffset = -70
                    logoOffset = 20
                    
                }
               
            }

            // 5–6s: logo reveal
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                showLogo = true
                Haptics.revealDone()
                withAnimation {
                    
                    revealLogo = true
                }
            }
        }
    }
}
 




enum Haptics {
    static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    static let success = UINotificationFeedbackGenerator()

    static func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        rigidImpact.prepare()
        success.prepare()
    }

    static func tick() {
        lightImpact.impactOccurred(intensity: 0.4)
    }

    static func slide() {
        mediumImpact.impactOccurred()
    }

    static func revealDone() {
        success.notificationOccurred(.success)
    }
}
