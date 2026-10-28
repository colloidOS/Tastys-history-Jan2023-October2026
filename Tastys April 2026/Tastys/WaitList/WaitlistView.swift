//
//  WaitlistView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 12/01/2026.
//

import SwiftUI
import AVKit
import AVFoundation
import MediaPlayer

struct WaitlistView: View {
    @StateObject private var vm = WaitlistViewModel()
    @State private var isEmail = true
//    @State private var number = ""
//    @State private var email = ""
    @State private var selectedCountry = Country.us
    @State private var showingCountryPicker = false
    private let player = AVPlayer(
        url: Bundle.main.url(forResource: "ticket", withExtension: "mp4")!
    )

    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            NavigationLink(
                destination: SuccessfulWaitlistView(
                    listNumber: vm.listNumber
                ).navigationBarBackButtonHidden(),
                isActive: $vm.shouldNavigateToSuccess
            ) {
                EmptyView()
            }
            
            if let error = vm.errorMessage {
                PopUpView(error: error)
            }

            
            VStack(spacing: 20){
                Text("Tasty’s early access is live.\nJoin the waitlist")
                    .foregroundStyle(.white)
                    .font(.system(size: 29, weight: .bold))
                
                if isEmail{
                    Text("By providing your email, you agree to email updates.")
                        .foregroundStyle(.white)
                        .opacity(0.5)
                        .font(.system(size: 15))
                } else {
                    Text("By providing your number, you agree to SMS updates.")
                        .foregroundStyle(.white)
                        .opacity(0.5)
                        .font(.system(size: 15))
                }
                
                LoopingVideoPlayer(player: player)
                    .frame(height: 200)
                    .cornerRadius(20)
                    .padding(.top, 14)
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

                
                
                if isEmail{
                    HStack{
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 26))
                            .fontWeight(.bold)
                            .padding(8)
                            .background{
                                RoundedRectangle(cornerRadius: 13)
                                    .foregroundStyle(.white)
                                    .opacity(0.14)
                            }
                        
                        ZStack(alignment: .leading) {
                            if vm.email.isEmpty {
                                Text("Enter Email")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 26))
                                    .fontWeight(.semibold)
                                    .opacity(0.4)
                                
                            }
                            TextField("", text: $vm.email)
                                .foregroundStyle(.white)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    
                    if vm.email.isEmpty{
                        Button{
                            Haptics.slide()
                            isEmail = false
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 21)
                                    .foregroundStyle(.selectedBlack)
                                    .frame(height: 57)
                                RoundedRectangle(cornerRadius: 29)
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(.blackWaitlist)
                                    .frame(height: 55)
                                
                                Text("Use Phone")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                            }
                            
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                    } else {
                        Button{
                            Haptics.tick()
                          Task {
                            await vm.submitEmail()
                        }
                        } label: {
                            ContinueButtonView()
                            
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                    }
                    
                } else {
                    HStack(spacing: 8) {
                        HStack {
//                            Button(action: {
//                                showingCountryPicker = true
//                            }) {
                            HStack(spacing: 4) {
                                Text(selectedCountry.flag)
                                    .font(.system(size: 28))
                                    .fontWeight(.bold)
                                Text(selectedCountry.dialCode)
                                    .font(.system(size: 23))
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.white)
                                    .opacity(0.14)
                            }
//                            }
                            
                            ZStack(alignment: .leading) {
                                if vm.phone.isEmpty {
                                    Text("Enter Phone")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                        .fontWeight(.semibold)
                                        .opacity(0.4)
                                }
                                TextField("", text: $vm.phone)
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .keyboardType(.numberPad)
                                    .onChange(of: vm.phone) { newValue in
                                        let formatted = vm.formatUSPhone(newValue)
                                        if formatted != newValue {
                                            vm.phone = formatted
                                        }
                                    }

                            }
                        }
//                        .padding()
                    }
                    
                    if vm.phone.isEmpty {
                        Button{
                            Haptics.slide()
                            isEmail = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27)
                                    .foregroundStyle(.selectedBlack)
                                    .frame(height: 55)
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(.blackWaitlist)
                                    .frame(height: 55)
                                
                                Text("Use email")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                            }
                            
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    } else {
                        Button{
                            Haptics.tick()
                            Task {
                                await vm.submitPhone(
                                    dialCode: selectedCountry.dialCode,
                                    number: vm.phone
                                )
                            }
                            
                        } label: {
                            
                            ContinueButtonView()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }
                }
                
//                Spacer()
                
            }
        }
        .overlay {
            if vm.isLoading {
                Color.black.opacity(0.45).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .white)
                    )
                    .scaleEffect(1.4)
            }
        }
        .onAppear{
            configureSilentVideoSession()
            Haptics.prepare()
        }
//        .sheet(isPresented: $showingCountryPicker) {
//            CountryPickerView(selectedCountry: $selectedCountry)
//        }
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
    WaitlistView()
}

struct ContinueButtonView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(.tastysRed)
                .frame(height: 55)
            
            Text("Continue")
                .foregroundStyle(.white)
                .font(.system(size: 16))
                .fontWeight(.bold)
        }
    }
}


struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false   // ✅ hide controls
        vc.videoGravity = .resizeAspectFill
        return vc
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
    }
}
