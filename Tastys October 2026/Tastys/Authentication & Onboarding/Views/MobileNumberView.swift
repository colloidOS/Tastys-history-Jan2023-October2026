//
//  MobileNumberView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/12/2025.
//

import SwiftUI
import AuthenticationServices

struct MobileNumberView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var number = ""
    @State private var selectedCountry = Country.us
    @State private var showingCountryPicker = false
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentNonce: String?
    // Individual animation states for staggered entry
    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var animatePhoneField = false
    @State private var animateContinueButton = false
    @State private var animateOrDivider = false
    @State private var animateGoogleButton = false
    @State private var animateAppleButton = false
    @State private var animateEmailButton = false
    @State private var animateSignInLink = false
    @FocusState private var isTextFieldFocused: Bool
    private let animationDuration: Double = 0.5
    private let delayInterval: Double = 0.05
    
    var body: some View {
        ZStack {
            Color.fakeWhite
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false
                }
//            NavigationLink(
//                destination: authVM.needsOnboarding ? AnyView(DietFilterView().environmentObject(authVM)) : AnyView(MainTabView()),
//                isActive: Binding(
//                    get: { authVM.isAuthenticated == true },
//                    set: { _ in }
//                )
//            ) {
//                EmptyView()
//            }
            
            NavigationLink(
                destination: NameView(id: authVM.phone, isUsingEmail: false)
                    .environmentObject(authVM),
                isActive: $authVM.shouldNavigateToName
            ) {
                EmptyView()
            }
            
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
            
            
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 25) {
                    // 1. Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 127, height: 68)
                        .offset(y: animateLogo ? 0 : UIScreen.main.bounds.height)
                        .animation(.easeOut(duration: animationDuration), value: animateLogo)
                    
                    // 2. Title
                    Text("What to order made obvious")
                        .foregroundStyle(.black)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .offset(y: animateTitle ? 0 : UIScreen.main.bounds.height)
                        .animation(.easeOut(duration: animationDuration), value: animateTitle)
                    
                    // 3. Phone Number Field with Country Picker
                    HStack(spacing: 8) {
                        HStack {
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
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.white)
                                }
//                            }
                            
                            ZStack(alignment: .leading) {
                                if authVM.phone.isEmpty {
                                    Text("Phone number")
                                        .foregroundColor(.black)
                                        .font(.system(size: 15))
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
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundStyle(.rectTastys)
                            
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 4)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.04), radius: 1.5)
                        }
                    }
                    .offset(y: animatePhoneField ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animatePhoneField)
                    
                    // 4. Continue Button
                    Button {
                        Haptics.slide()
                        Task {
                            await authVM.checkPhoneAndContinue(
                            dialCode: selectedCountry.dialCode
                            )
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
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .offset(y: animateContinueButton ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateContinueButton)
                    
                    // 5. "Or" Divider
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.black)
                            .opacity(0.3)
                            .frame(height: 0.7)
                        
                        Text("Or")
                            .foregroundStyle(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.black)
                            .opacity(0.3)
                            .frame(height: 0.7)
                    }
                    .offset(y: animateOrDivider ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateOrDivider)
                    
                    // 6. Google Button
//                    Button {
//                        // Google sign-in action
//                    } label: {
//                        HStack(spacing: 12) {
//                            Spacer()
//                            Image("googleIcon")
//                            Text("Continue with google")
//                                .foregroundStyle(.black)
//                                .font(.system(size: 18))
//                                .fontWeight(.semibold)
//                                .padding(.vertical)
//                            Spacer()
//                        }
//                        .background {
//                            RoundedRectangle(cornerRadius: 25.0)
//                                .foregroundStyle(.grayTastys)
//                                .opacity(0.6)
//                        }
//                    }
//                    .padding(.horizontal, 10)
//                    .offset(y: animateGoogleButton ? 0 : UIScreen.main.bounds.height)
//                    .animation(.easeOut(duration: animationDuration), value: animateGoogleButton)
                    
                    // 7. Apple Button
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            currentNonce = randomNonceString()
                            request.requestedScopes = [.fullName, .email]
                            
                            if let nonce = currentNonce {
                                request.nonce = sha256(nonce)
                            }
                        },
                        onCompletion: { result in
                            switch result {
                                
                            case .success(let authorization):
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                   let idTokenData = appleIDCredential.identityToken,
                                   let idToken = String(data: idTokenData, encoding: .utf8),
                                   let nonce = currentNonce {
                                    
                                    Task {
                                        await authVM.signInWithApple(
                                            idToken: idToken,
                                            nonce: nonce,
                                            fullName: appleIDCredential.fullName
                                        )
                                    }
                                }
                                
                            case .failure(let error):
                                
                                if let appleError = error as? ASAuthorizationError {
                                    
                                    switch appleError.code {
                                    case .canceled:
                                        print("Apple Sign-In interrupted")
                                        
                                    default:
                                        authVM.showError("Apple Sign-In failed")
                                    }
                                    
                                } else {
                                    authVM.showError("Apple Sign-In failed")
                                }
                                
                                print("Apple Sign-In error: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(25)
                    .padding(.horizontal, 10)
                    .offset(y: animateAppleButton ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateAppleButton)
                    
                    // 8. Continue with Email
                    NavigationLink {
                        SignUpView()
                            .environmentObject(authVM)
//                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack(spacing: 14) {
                            Spacer()
                            Text("@  Continue with email")
                                .foregroundStyle(.black)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .padding(.vertical)
                            Spacer()
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(lineWidth: 1.5)
                                .foregroundStyle(.grayTastys)
                                .opacity(0.6)
                        }
                    }
                    .padding(.horizontal, 10)
                    .offset(y: animateEmailButton ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateEmailButton)
                    
                    // 9. Sign In Link
                    HStack {
                        Text("Have an account?")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.system(size: 15))
                        
                        NavigationLink {
                            SignInView(authVM: authVM)
                                .environmentObject(authVM)
//                                .navigationBarBackButtonHidden()
                        } label: {
                            Text("Sign in")
                                .foregroundStyle(.black)
                                .opacity(0.85)
                                .font(.system(size: 15))
                        }
                    }
                    .offset(y: animateSignInLink ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateSignInLink)
                }
                .padding(.horizontal, 15)
            }
            .scrollDismissesKeyboard(.interactively)
            
            if authVM.isLoading {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
            }
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
////                        .background(Color.white.opacity(0.8))
////                        .clipShape(Circle())
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .enableSwipeBack()
        .onAppear {
            authVM.phone = ""
            Haptics.prepare()
            // Staggered animation with 0.05s delay between each element
            let delays: [Double] = [0.0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40]
            
            for delay in delays {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: animationDuration)) {
                        if delay == 0.0 { animateLogo = true }
                        else if delay == 0.05 { animateTitle = true }
                        else if delay == 0.10 { animatePhoneField = true }
                        else if delay == 0.15 { animateContinueButton = true }
                        else if delay == 0.20 { animateOrDivider = true }
                        else if delay == 0.25 { animateGoogleButton = true }
                        else if delay == 0.30 { animateAppleButton = true }
                        else if delay == 0.35 { animateEmailButton = true }
                        else if delay == 0.40 { animateSignInLink = true }
                    }
                }
            }
        }
        
        .sheet(isPresented: $showingCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
    }
}

// Country Model
struct Country: Identifiable {
    let id = UUID()
    let name: String
    let dialCode: String
    let code: String
    let flag: String
    
    static let us = Country(name: "United States", dialCode: "+1", code: "US", flag: "🇺🇸")
    
    static let allCountries = [
        Country(name: "United States", dialCode: "+1", code: "US", flag: "🇺🇸"),
        Country(name: "Canada", dialCode: "+1", code: "CA", flag: "🇨🇦"),
        Country(name: "United Kingdom", dialCode: "+44", code: "GB", flag: "🇬🇧"),
        Country(name: "Australia", dialCode: "+61", code: "AU", flag: "🇦🇺"),
        Country(name: "Germany", dialCode: "+49", code: "DE", flag: "🇩🇪"),
        Country(name: "France", dialCode: "+33", code: "FR", flag: "🇫🇷"),
        Country(name: "Italy", dialCode: "+39", code: "IT", flag: "🇮🇹"),
        Country(name: "Spain", dialCode: "+34", code: "ES", flag: "🇪🇸"),
        Country(name: "Japan", dialCode: "+81", code: "JP", flag: "🇯🇵"),
        Country(name: "China", dialCode: "+86", code: "CN", flag: "🇨🇳"),
        Country(name: "India", dialCode: "+91", code: "IN", flag: "🇮🇳"),
        Country(name: "Brazil", dialCode: "+55", code: "BR", flag: "🇧🇷"),
        Country(name: "Mexico", dialCode: "+52", code: "MX", flag: "🇲🇽"),
        Country(name: "South Korea", dialCode: "+82", code: "KR", flag: "🇰🇷"),
        Country(name: "Netherlands", dialCode: "+31", code: "NL", flag: "🇳🇱"),
        Country(name: "Sweden", dialCode: "+46", code: "SE", flag: "🇸🇪"),
        Country(name: "Norway", dialCode: "+47", code: "NO", flag: "🇳🇴"),
        Country(name: "Denmark", dialCode: "+45", code: "DK", flag: "🇩🇰"),
        Country(name: "Switzerland", dialCode: "+41", code: "CH", flag: "🇨🇭"),
        Country(name: "Belgium", dialCode: "+32", code: "BE", flag: "🇧🇪"),
        Country(name: "Austria", dialCode: "+43", code: "AT", flag: "🇦🇹"),
        Country(name: "Poland", dialCode: "+48", code: "PL", flag: "🇵🇱"),
        Country(name: "Turkey", dialCode: "+90", code: "TR", flag: "🇹🇷"),
        Country(name: "Saudi Arabia", dialCode: "+966", code: "SA", flag: "🇸🇦"),
        Country(name: "United Arab Emirates", dialCode: "+971", code: "AE", flag: "🇦🇪"),
        Country(name: "South Africa", dialCode: "+27", code: "ZA", flag: "🇿🇦"),
        Country(name: "Nigeria", dialCode: "+234", code: "NG", flag: "🇳🇬"),
        Country(name: "Egypt", dialCode: "+20", code: "EG", flag: "🇪🇬"),
        Country(name: "Argentina", dialCode: "+54", code: "AR", flag: "🇦🇷"),
        Country(name: "Chile", dialCode: "+56", code: "CL", flag: "🇨🇱"),
    ]
}

// Country Picker View
struct CountryPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountry: Country
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return Country.allCountries
        } else {
            return Country.allCountries.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.dialCode.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                List(filteredCountries) { country in
                    Button(action: {
                        selectedCountry = country
                        dismiss()
                    }) {
                        HStack {
                            Text(country.flag)
                                .font(.system(size: 32))
                            Text(country.name)
                                .foregroundStyle(.black)
                            Spacer()
                            Text(country.dialCode)
                                .foregroundStyle(.black)
                                .opacity(0.6)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search countries")
                .navigationTitle("Select Country")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
            }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MobileNumberView()
            .environmentObject(AuthViewModel())
    }
}
