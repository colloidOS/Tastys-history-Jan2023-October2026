//
//  SuccessfulWaitlistView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/01/2026.
//

import SwiftUI
import UIKit
import AVKit
import AVFoundation
import MediaPlayer

struct SuccessfulWaitlistView: View {
    @AppStorage("waitlisted") private var isWaitlisted = false
    var listNumber: Int
    @AppStorage("waitlistNumber") private var waitlistNumber: Int?
    private let player = AVPlayer(
        url: Bundle.main.url(forResource: "ticket", withExtension: "mp4")!
    )
    @State private var isShowingPopUp = false
    @State private var showShareSheet = false
    var message = "link copied"
    
    let appStoreURL = "https://apps.apple.com/app/id0000000000"

    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            if isShowingPopUp {
                VStack {
                    Text(message)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 28).fill(Color.white))
                        .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(1)
            }
            
            VStack(spacing: 14){
                LoopingVideoPlayer(player: player)
                    .frame(height: 196)
                    .cornerRadius(20)
                    .padding(.top, 16)
                    .onAppear {
                        player.isMuted = true
                        player.actionAtItemEnd = .none
                        player.play()

                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                    }
                
                VStack(spacing: 3){
                    Text("You are #\(listNumber)")
                        .foregroundStyle(.white)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                    
                    
                    Text("on the ")
                        .foregroundStyle(.white)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                    +
                    Text("waitlist")
                        .foregroundStyle(.tastysRed)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                }
                
                Text("Share your link to get higher on the list")
                    .foregroundStyle(.white)
                    .opacity(0.5)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                
                
                HStack{
                    Text(String(appStoreURL.prefix(24)))
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "rectangle.fill.on.rectangle.fill")
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .padding(8)
                        .onTapGesture {
                            UIPasteboard.general.string = appStoreURL

                            withAnimation {
                                Haptics.slide()
                                isShowingPopUp = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isShowingPopUp = false
                                }
                            }
                        }
                    
                    Button{
                        Haptics.slide()
                        showShareSheet = true
                    } label: {
                        Text("share")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .padding(5)
                            .padding(.horizontal, 9)
                            .background{
                                Color.tastysRed
                                    .clipShape(RoundedRectangle(cornerRadius: 27))
                            }
                    }
                    
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background{
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.blackWaitlist)
                }
                .padding(.vertical, 9)
                .padding(.horizontal, 19)
            }
            
            
        }
        .accentColor(.white)
        .onAppear{
            configureSilentVideoSession()
            Haptics.prepare()
//            isWaitlisted = true
            waitlistNumber = listNumber
            
            isWaitlisted = false
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(
                items: [
                    """
                    Join Tastys's waitlist to get early access to the best Dish review App:
                    \(appStoreURL)
                    """
                ]
            )
        }

    }
    func configureSilentVideoSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .ambient,
            mode: .moviePlayback,
            options: []
        )
        try? session.setActive(true)
        
        // Hard kill Now Playing
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

#Preview {
    SuccessfulWaitlistView(listNumber: 1)
}



struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
