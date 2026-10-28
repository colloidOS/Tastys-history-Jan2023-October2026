//
//  SignUpView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 08/12/2025.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isUsingEmail = true
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentNonce: String?
    // Individual animation states for staggered entry
    @State private var animateSkipButton = false
    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var animateEmailField = false
    @State private var animateContinueButton = false
    @State private var animateOrDivider = false
    @State private var animateGoogleButton = false
    @State private var animateAppleButton = false
    @State private var animateNumberButton = false
    @State private var animateSignInLink = false
//    @State private var showError = false
    @FocusState private var isTextFieldFocused: Bool
    private let animationDuration: Double = 0.4
    private let delayInterval: Double = 0.05
    @StateObject private var homeVM = HomeViewModel()
    @AppStorage("requireSignup") var requireSignup: Bool = UserDefault.requireSignup
    @EnvironmentObject var guestRouter: GuestNavigationRouter
    
    var body: some View {
        ZStack {
            Color.fakeWhite
                .ignoresSafeArea()
//            NavigationLink(
//                destination: AnyView(MainTabView().environmentObject(authVM)),  // Always navigate to MainTabView; handle onboarding as overlay there
//                isActive: Binding(
//                    get: { authVM.isAuthenticated == true },
//                    set: { _ in }
//                )
//            ) {
//                EmptyView()
//            }
            
            if let err = authVM.errorMessage {
                VStack {
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 34).fill(Color.white))
                        .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(1)
            }
            
            NavigationLink(
                destination: NameView(id: authVM.email, isUsingEmail: true)
                    .environmentObject(authVM)
                    /*.navigationBarBackButtonHidden()*/,
                isActive: $authVM.shouldNavigateToName
            ) {
                EmptyView()
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 25) {
                    
                    HStack{
                      Spacer()
                        
                        Button {
                            guestRouter.showHome()
                        } label: {
                            Text("skip")
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                                .foregroundStyle(Color.tastysRed)
//                                .underline()
                        }
                    }
                    .padding(.trailing, 10)
                    .offset(y: animateSkipButton ? 0 : -50)
                    .opacity(animateSkipButton ? 1 : 0)
                    .animation(.easeOut(duration: animationDuration), value: animateSkipButton)
                    
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
                        .padding(.bottom, 20)
                        .offset(y: animateTitle ? 0 : UIScreen.main.bounds.height)
                        .animation(.easeOut(duration: animationDuration), value: animateTitle)
                    
                    // 3. Email Field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                            .fontWeight(.semibold)
                            .opacity(0.6)
                        
                        ZStack(alignment: .leading) {
                            if authVM.email.isEmpty {
                                Text("hello@gmail.com")
                                    .accentColor(.black)
                                    .font(.system(size: 18))
                                    .opacity(0.5)
                            }
                            TextField("", text: $authVM.email)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .focused($isTextFieldFocused)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
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
                    .offset(y: animateEmailField ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateEmailField)
                    
                    VStack(spacing: 5) {
                    // 4. Continue Button
                        Button {
                            Haptics.slide()
                            Task {
                                await authVM.checkEmailAndContinue()
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
                                RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(.tastysRed)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        
                        
                    }
                    .padding(.top, 11)
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
//                        HStack(spacing: 14) {
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
//                    .buttonStyle(.plain)
//                    .padding(.horizontal, 14)
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
                    
                    // 8. Continue with Number
                    NavigationLink {
                        MobileNumberView()
                            .environmentObject(authVM)
//                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack(spacing: 14) {
                            Spacer()
                            Image("numberpad")
                            Text("Continue with number")
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
                    .padding(.horizontal, 12)
                    .offset(y: animateNumberButton ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateNumberButton)
                    
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
            Haptics.prepare()
            authVM.email = ""
            requireSignup = false
            // Staggered animation with 0.1s delay between each element
            let delays: [Double] = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45]
            
            for delay in delays {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: animationDuration)) {
                        if delay == 0.0 {
                            animateSkipButton = true
                        } else if delay == 0.05 {
                            animateLogo = true
                        } else if delay == 0.1 {
                            animateTitle = true
                        } else if delay == 0.15 {
                            animateEmailField = true
                        } else if delay == 0.2 {
                            animateContinueButton = true
                        } else if delay == 0.25 {
                            animateOrDivider = true
                        } else if delay == 0.3 {
                            animateGoogleButton = true
                        } else if delay == 0.35 {
                            animateAppleButton = true
                        } else if delay == 0.4 {
                            animateNumberButton = true
                        } else if delay == 0.45 {
                            animateSignInLink = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
//            .environmentObject(GuestNavigationRouter())
    }
}



struct ReuseableTextField: View {
    @Binding var text: String
    var placeholder: String
    var body: some View {
        HStack{
            Image(systemName: "person")
                .font(.system(size: 18))
                .foregroundStyle(.black)
                .fontWeight(.semibold)
                .opacity(0.6)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                                .foregroundColor(.black)
                        .accentColor(.black)
                        .font(.system(size: 18))
                        .opacity(0.5)
                }
                TextField("", text: $text)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background{
            RoundedRectangle(cornerRadius: 27.0)
                .foregroundStyle(.rectTastys)
            
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(lineWidth: 4)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.04), radius: 1.5)
        }
    }
}



struct ReuseableSecureField: View {
    @Binding var password: String
    var placeholder: String?
    @State private var isShowing = false
    var body: some View {
        HStack{
            Image(systemName: "key")
                .font(.system(size: 18))
                .foregroundStyle(.black)
                .fontWeight(.semibold)
                .opacity(0.6)
            
            if isShowing {
                ZStack(alignment: .leading) {
                    if password.isEmpty {
                        if let initialPrompt = placeholder {
                            Text(initialPrompt)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .font(.system(size: 18))
                                .opacity(0.5)
                        } else {
                            Text("password")
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .font(.system(size: 16))
                                .opacity(0.5)
                        }
                    }
                    TextField("", text: $password)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
            } else {
                ZStack(alignment: .leading) {
                    if password.isEmpty {
                        if let initialPrompt = placeholder {
                            Text(initialPrompt)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .font(.system(size: 18))
                                .opacity(0.5)
                        } else {
                            Text("password")
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .font(.system(size: 18))
                                .opacity(0.5)
                        }
                    }
                    SecureField("", text: $password)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
            }
            
            Button{
                isShowing.toggle()
            } label:{
                Image(systemName: isShowing ? "eye" : "eye.slash")
                    .foregroundStyle(.black)
            }
            .padding(.trailing, 8)
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background{
            RoundedRectangle(cornerRadius: 29.0)
                .foregroundStyle(.rectTastys)
            
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(lineWidth: 4)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.04), radius: 1.5)
        }
    }
}


enum UserDefault {
    static let requireSignup = false
}


@MainActor
final class GuestNavigationRouter: ObservableObject {
    @Published var isShowingSignup = true

    func showHome() {
        isShowingSignup = false
    }

    func goToSignup() {
        isShowingSignup = true
    }
}
