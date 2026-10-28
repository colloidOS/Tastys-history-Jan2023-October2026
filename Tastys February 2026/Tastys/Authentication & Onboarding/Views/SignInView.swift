//
//  SignInView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/12/2025.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isUsingEmail = true
    @FocusState private var isTextFieldFocused: Bool
    @State private var number = ""
    @State private var selectedCountry = Country.us
    @State private var showingCountryPicker = false
    @ObservedObject var authVM: AuthViewModel
    @AppStorage("isOnboardingInProgress")
        private var isOnboardingInProgress = false
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
            NavigationLink(
                        destination: MainTabView(),
                        isActive: Binding(
                            get: { authVM.isAuthenticated == true },
                            set: { _ in }
                        )
                    ) { EmptyView() }

            if let err = authVM.errorMessage {
                VStack {
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 14))
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
            
            VStack(alignment: .leading, spacing: 15){
                Spacer()
                
                Text("Welcome back!")
                    .foregroundStyle(.black)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                if isUsingEmail{
                    Text("Enter your email and password to \nsign in to your account")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                    
                    HStack{
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                            .fontWeight(.semibold)
                            .opacity(0.6)
                        
                        ZStack(alignment: .leading) {
                            if authVM.email.isEmpty {
                                Text("hello@gmail.com")
                                //                          .foregroundColor(.black)
                                    .accentColor(.black)
                                    .font(.system(size: 19))
                                    .opacity(0.5)
                            }
                            TextField("", text: $authVM.email)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .focused($isTextFieldFocused)
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
                } else {
//                    Text("Enter your Number")
//                        .foregroundStyle(.black)
//                        .font(.system(size: 33))
//                        .fontWeight(.medium)
                    
                    Text("Enter your mobile number and password to \nsign in to your account")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 6){
                        HStack{
//                            Button(action: {
//                                showingCountryPicker = true
//                            }) {
                                HStack(spacing: 5) {
                                    Text(selectedCountry.flag)
                                        .font(.system(size: 15))
                                    Text(selectedCountry.dialCode)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.black)
                                        .fontWeight(.medium)
    //                                Image(systemName: "chevron.down")
    //                                    .font(.system(size: 11))
    //                                    .foregroundStyle(.black)
    //                                    .opacity(0.6)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.white)
                                }
//                            }
                            // Phone Number Field
                            ZStack(alignment: .leading) {
                                if authVM.phone.isEmpty {
                                    Text("Phone number")
                                        .foregroundColor(.black)
                                        .font(.system(size: 17))
                                        .opacity(0.5)
                                }
                                TextField("", text: $authVM.phone)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                    .focused($isTextFieldFocused)
                                    .onChange(of: authVM.phone) { oldValue, newValue in
                                        let formatted = authVM.formatUSPhone(newValue)
                                        if formatted != newValue {
                                            authVM.phone = formatted
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
                
                
                ReuseableSecureField(password: $authVM.password)
                    .focused($isTextFieldFocused)
                
                HStack {
                    
                    Spacer()
                    Button{
                        Haptics.slide()
                        isUsingEmail.toggle()
                    } label: {
                        Text(isUsingEmail ? "Use Mobile Number" : "Use email address")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
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
                
                
                HStack {
                    Spacer()
                    NavigationLink{
                        RequestPasswordResetView()
                            .environmentObject(authVM)
                    } label: {
                        Text("forgot password?")
                            .foregroundStyle(.black)
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 6)
                    Spacer()
                }
                
                Button {
                    Haptics.slide()
                    Task {
                        await authVM.signIn(
                            isUsingEmail: isUsingEmail,
                            dialCode: selectedCountry.dialCode
                        )
                        authVM.needsOnboarding = false
                        isOnboardingInProgress = false
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
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.tastysRed)
                    }
                
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                
            }
            .padding(.horizontal, 15)
            
            if authVM.isLoading {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
            }
        }
        .background(
            NavigationLink(destination: VerifyEmailView(isUsingEmail: isUsingEmail, text: authVM.id, authVM: authVM).environmentObject(authVM), isActive: $authVM.requiresOTPVerification) {
                EmptyView()
            }
            .hidden()
        )
        .onAppear{
            Haptics.prepare()
            authVM.email = ""
            authVM.password = ""
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
////                        .clipShape(Circle())
////                    .foregroundStyle(.white)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .enableSwipeBack()
    }
}

#Preview {
    NavigationStack {
        SignInView(authVM: AuthViewModel())
    }
}
