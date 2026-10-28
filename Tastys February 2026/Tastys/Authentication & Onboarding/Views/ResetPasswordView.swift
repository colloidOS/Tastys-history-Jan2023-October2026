//
//  ResetPasswordView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/12/2025.
//

import SwiftUI

struct ResetPasswordView: View {
    let isUsingEmail: Bool
    let text: String  // email or full phone number
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var otpCode: String = ""
    @FocusState private var isFocused: Bool
    @State private var countdown = 60
    @State private var isResendEnabled = false
    @State private var timer: Timer?
//    @AppStorage("isRecoveringPassword") private var isRecoveringPassword = false
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    enum Field: Hashable {
        case otp
        case newPassword
        case confirmPassword
    }

    @FocusState private var focusedField: Field?
    var body: some View {
        ZStack {
            Color.fakeWhite
                .ignoresSafeArea()
            
            if let error = vm.errorMessage {
                PopUpView(error: error)
                    .padding(.top, 23)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer()
                    
                    Text("Reset Password")
                        .foregroundStyle(.black)
                        .font(.system(size: 32))
                        .fontWeight(.medium)
                    
                    Text("Enter the 6-digit code sent to your ")
                        .foregroundStyle(.black.opacity(0.5))
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                    + Text(isUsingEmail ? "email" : "phone number")
                        .foregroundStyle(.black.opacity(0.5))
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                    
                    ZStack {
                        VStack(spacing: 0) {
                            // Display email or phone
                            HStack {
                                Text(text)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .opacity(0.6)
                                    .padding(6)
                                    .padding(.horizontal, 3)
                                    .background {
                                        Color.white
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .padding(.vertical, 8)
                                Spacer()
                            }
                            
                            Divider()
                                .background(Color.black.opacity(0.1))
                                .padding(.vertical, 6)
                            
                            // 6-digit OTP display
                            HStack(spacing: 0) {
                                ForEach(0..<6) { index in
                                    ZStack {
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
                                    .focused($focusedField, equals: .otp)
                                    .opacity(0)
                                    .onChange(of: otpCode) { oldValue, newValue in
                                        handleOTPChange(oldValue: oldValue, newValue: newValue)
                                    }
                            )
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 27.0)
                            .foregroundStyle(.rectTastys)
                        
                        RoundedRectangle(cornerRadius: 25.0)
                            .stroke(lineWidth: 4)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.04), radius: 1.5)
                    }
                    
                    // New password fields
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 13) {
                            ReuseableSecureField(password: $newPassword, placeholder: "New password")
                                .focused($focusedField, equals: .newPassword)
                            ReuseableSecureField(password: $confirmNewPassword, placeholder: "Confirm new password")
                                .focused($focusedField, equals: .confirmPassword)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    // Resend code
                    HStack {
                        Spacer()
                        Button {
                            if isResendEnabled {
                                resendCode()
                            }
                        } label: {
                            Text(isResendEnabled ? "Resend Code" : "Resend in \(countdown)s")
                                .foregroundStyle(isResendEnabled ? .black : .black.opacity(0.4))
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 7)
                                .background {
                                    Color.white
                                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                }
                        }
                        .disabled(!isResendEnabled)
                        Spacer()
                    }
                    
                    // Reset button
                    Button {
                        print("Setting recovery on:", ObjectIdentifier(vm))
                        vm.isInPasswordRecovery = true
                        //                        isRecoveringPassword = true
                        let fullCode = otpCode
                        
                        guard fullCode.count == 6 else {
                            vm.showError("Please enter the 6-digit code")
                            return
                        }
                        
                        guard !newPassword.isEmpty, newPassword == confirmNewPassword else {
                            vm.showError("Passwords do not match or are empty")
                            return
                        }
                        
                        Task {
                            do {
                                //                            isRecoveringPassword = true
                                //                            vm.isInPasswordRecovery = true
                                if isUsingEmail {
                                    _ = try await vm.verifyRecoveryOTP(email: text, token: fullCode)
                                } else {
                                    _ = try await vm.authService.verifyPhoneOTP(phone: text, code: fullCode)
                                }
                                await vm.updatePassword(newPassword: newPassword, confirmPassword: confirmNewPassword)
                                
                                if vm.errorMessage == nil {
                                    // Success → close sheet or navigate
                                    dismiss()
                                }
                            } catch {
                                vm.showError(error.localizedDescription)
                                print("verify error: \(error.localizedDescription)")
                                //                            isRecoveringPassword = false
                                //                            vm.isInPasswordRecovery = false
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset Password")
                                .foregroundStyle(.white)
                                .font(.system(size: 17))
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
            }
            
            if vm.isLoading {
                Color.ashTastys
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
            }
        }
        .onTapGesture {
            focusedField = nil
        }
//        .navigationBarBackButtonHidden()
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
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .enableSwipeBack()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
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
    
    private func resendCode() {
        Task {
            await vm.resendRecoveryOTP(isUsingEmail: isUsingEmail, identifier: text)
            if vm.errorMessage == nil {
                startCountdown()
            }
        }
    }
}
#Preview {
    ResetPasswordView(isUsingEmail: true, text: "nnagoziemcollin@gmail.com", vm: AuthViewModel())
}
