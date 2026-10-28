//
//  RequestPasswordResetView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/12/2025.
//

import SwiftUI

struct RequestPasswordResetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isUsingEmail = true
    
    @State private var number = ""
    @State private var selectedCountry = Country.us
    @State private var showingCountryPicker = false
    @State private var isShowingResetPassword = false
    @State private var text = ""
    @EnvironmentObject var vm: AuthViewModel
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
            if let error = vm.errorMessage {
                if !vm.showPasswordResetScreen{
                    PopUpView(error: error)
                }
            }
            
            VStack(alignment: .leading, spacing: 25){
                Spacer()
                
                Text("Forgot password")
                    .foregroundStyle(.black)
                    .font(.system(size: 33))
                    .fontWeight(.medium)
                if isUsingEmail{
                    Text("Enter your email to receive OTP code \nand verify it's you")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                    
                    HStack{
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                            .fontWeight(.semibold)
                            .opacity(0.6)
                        
                        ZStack(alignment: .leading) {
                            if vm.email.isEmpty {
                                Text("hello@gmail.com")
                                //                            .foregroundColor(.black)
                                    .accentColor(.black)
                                    .font(.system(size: 14))
                                    .opacity(0.5)
                            }
                            TextField("", text: $vm.email)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .focused($isTextFieldFocused)
                        }
                        
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.rectTastys)
                        
                        RoundedRectangle(cornerRadius: 25.0)
                            .stroke(lineWidth: 4)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.04), radius: 1.5)
                    }
                } else {
                    Text("Enter your phone number to receive OTP code \nand verify it's you")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 8){
                        HStack{
//                            Button(action: {
//                                showingCountryPicker = true
//                            }) {
                                HStack(spacing: 4) {
                                    Text(selectedCountry.flag)
                                        .font(.system(size: 15))
                                    Text(selectedCountry.dialCode)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.black)
                                        .fontWeight(.medium)
                                    
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.white)
                                }
//                            }
                            // Phone Number Field
                            ZStack(alignment: .leading) {
                                if number.isEmpty {
                                    Text("Phone number")
                                        .foregroundColor(.black)
                                        .font(.system(size: 15))
                                        .opacity(0.5)
                                }
                                TextField("", text: $number)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                    .focused($isTextFieldFocused)
                                    .onChange(of: number) { newValue in
                                        let formatted = vm.formatUSPhone(newValue)
                                        if formatted != newValue {
                                            number = formatted
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background{
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundStyle(.rectTastys)
                            
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 4)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.04), radius: 1.5)
                        }
                    }
//                    .padding(.vertical)
                }
                
                
                
                HStack {
                    Spacer()
                    Button{
                        isUsingEmail.toggle()
                    } label: {
                        Text(isUsingEmail ? "Use Mobile Number" : "Use email address")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 7)
                            .background{
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            }
                    }
//                    Spacer()
                }
                
                Spacer()
                Spacer()
                
                
                
                Button{
                    Task {
                        if isUsingEmail {
                            await vm.checkEmailAndSendOTP()
                        } else {
                            let cleanNumber = number.filter { $0.isNumber }
                            vm.phone = cleanNumber
                            await vm.checkPhoneAndSendOTP(dialCode: selectedCountry.dialCode)
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .foregroundStyle(.white)
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                        .padding(.vertical)
                        Spacer()
                            
                    }
                    .background{
                        RoundedRectangle(cornerRadius: 21.0)
                            .foregroundStyle(.tastysRed)
                    }
                
                }
                .padding(.horizontal, 29)
                .padding(.bottom)
                
            }
            .padding(.horizontal, 15)
            
            if vm.isLoading {
                Color.ashTastys
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
            }
        }
        .onAppear{
            vm.email = ""
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .sheet(isPresented: $vm.showPasswordResetScreen) {
            ResetPasswordView(isUsingEmail: isUsingEmail, text: isUsingEmail ? vm.email : vm.phone, vm: vm)
        }
//        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button{
//                    dismiss()
//                } label: {
//                    Image("backButtonIcon")
//                        .renderingMode(.template)
//                        .foregroundStyle(.black)
//                        .padding()
//                        .clipShape(Circle())
//                    .foregroundStyle(.white)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .enableSwipeBack()
    }
}
#Preview {
RequestPasswordResetView()
        .environmentObject(AuthViewModel())
}
