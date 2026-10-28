//
//  VerifyEmailView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/12/2025.
//

import SwiftUI

struct VerifyEmailView: View {
    var isUsingEmail: Bool
    var text: String
    @Environment(\.dismiss) var dismiss
    @State private var otpCode: String = ""
    @FocusState private var isFocused: Bool
    @State private var countdown = 60
    @State private var isResendEnabled = false
    @State private var timer: Timer?
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.fakeWhite
                .ignoresSafeArea()
            
            // Removed NavigationLink to DietFilterView; onboarding handled in MainTabView as overlay

            if let err = authVM.errorMessage {
                VStack {
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                        .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(1)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Enter your Verification Code")
                    .foregroundStyle(.black)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                
                Text("Enter The 6-Digit Code we \nsent to your ")
                    .foregroundStyle(.black.opacity(0.5))
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                +
                Text(isUsingEmail ? "email" : "number")
                    .foregroundStyle(.black.opacity(0.5))
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                
                ZStack {
                    VStack(spacing: 0) {
                        // Email/Phone display
                        HStack {
                            Text(text)
                                .foregroundStyle(.black)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .opacity(0.6)
                                .padding(6)
                                .padding(.horizontal, 5)
                                .background {
                                    Color.white
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.vertical, 12)
                            Spacer()
                        }
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                            .padding(.vertical, 8)
                        
                        // 6-digit code display
                        HStack(spacing: 0) {
                            ForEach(0..<6) { index in
                                ZStack {
                                    // Placeholder circle when empty
                                    if index >= otpCode.count {
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 10, height: 10)
                                    } else {
                                        Text(String(Array(otpCode)[index]))
                                            .foregroundStyle(.black)
                                            .font(.system(size: 24))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isFocused = true
                                }
                                
                                // Vertical divider between boxes (except after last one)
                                if index < 5 {
                                    Divider()
                                        .frame(height: 40)
                                        .background(Color.black.opacity(0.1))
                                }
                            }
                        }
                        .background(
                            TextField("", text: $otpCode)
                                .keyboardType(.numberPad)
                                .focused($isFocused)
                                .opacity(0) // Fully hidden
                                .onChange(of: otpCode) { oldValue, newValue in
                                    handleOTPChange(oldValue: oldValue, newValue: newValue)
                                }
                        )
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundStyle(.rectTastys)
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(lineWidth: 4)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.04), radius: 1.5)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        Haptics.slide()
                        if isResendEnabled {
                            Task {
                                await authVM.resendOTP(isUsingEmail: isUsingEmail)
                                startCountdown()
                            }
                        }
                    } label: {
                        Text(isResendEnabled ? "Resend Code" : "Resend in \(countdown)s")
                            .foregroundStyle(isResendEnabled ? .black : .black.opacity(0.4))
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background {
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            }
                    }
                    .disabled(!isResendEnabled)
                    Spacer()
                }
                
                Button {
                    Haptics.slide()
                    print("first name: \(authVM.firstName)")
                    print("last name: \(authVM.lastName)")
                    if authVM.firstName.isEmpty {
                        print("unable to sign you up")
                    }
                    Task {
                        await authVM.verifyOTP(isUsingEmail: isUsingEmail)
                    }
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
                    .background {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.tastysRed)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
            }
            .padding(.horizontal, 20)
            
            if authVM.isLoading {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
            }
        }
        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button {
//                    dismiss()
//                } label: {
//                    Image("backButtonIcon")
//                        .renderingMode(.template)
//                        .foregroundStyle(.black)
//                        .padding()
//                        .clipShape(Circle())
//                        .foregroundStyle(.white)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .enableSwipeBack()
        .onAppear {
            Haptics.prepare()
            // Auto-focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
            
            // Start countdown timer
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func handleOTPChange(oldValue: String, newValue: String) {
        // Only allow numbers
        otpCode = newValue.filter { $0.isNumber }
        
        // Limit to 6 digits
        if otpCode.count > 6 {
            otpCode = String(otpCode.prefix(6))
        }
        
        // Update authVM
        authVM.otpCode = otpCode
        
        // Optional: If complete, trigger something
        if otpCode.count == 6 {
            print("Complete code: \(otpCode)")
            // You can auto-verify here if desired
        }
    }
    
    private func startCountdown() {
        countdown = 60
        isResendEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                isResendEnabled = true
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    VerifyEmailView(isUsingEmail: false, text: "+98765323456", authVM: AuthViewModel())
}
