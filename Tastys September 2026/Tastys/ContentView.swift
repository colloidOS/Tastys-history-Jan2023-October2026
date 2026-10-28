//
//  ContentView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/12/2025.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()
    @State private var showLaunch = true   // 👈 gate
//    @AppStorage("isRecoveringPassword") private var isRecoveringPassword = false
//    @StateObject private var router = GuestNavigationRouter()
    var body: some View {
        ZStack {
//            KeyboardDismissHelper()
            // Main app routing (locked behind launch gate)
            if !showLaunch {
                Group {
                    if !authVM.isAuthenticated || authVM.isResolvingAuth {

                        GuestFlowView()
                            .environmentObject(authVM)
                        

                    } else if authVM.needsOnboarding || authVM.isOnboardingInProgress {

                        NavigationStack {
                            DietFilterView()
                                .environmentObject(authVM)
                                .transition(.opacity)
                        }

                    } else {

                        MainTabView()
                            .environmentObject(authVM)
                            
                        
                    }
                }
            }

            // Launch animation always on top
            if showLaunch {
                AnimateLaunchView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Enforce minimum 3s launch duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showLaunch = false
                }
            }
        }
        .onChange(of: authVM.isAuthenticated) { value in
            print("isAuthenticated =", value)
            if authVM.isAuthenticated {
                authVM.shouldNavigateToName = false
                authVM.firstName = ""
                authVM.lastName = ""
            }
        }

        .onChange(of: authVM.session) { session in
            print("session =", session != nil)
        }

        .onChange(of: authVM.isInPasswordRecovery) { value in
            print("isInPasswordRecovery =", value)
        }

        .sheet(isPresented: $authVM.showPasswordResetScreen) {
            ResetPasswordView(isUsingEmail: true, text: "", vm: authVM)
        }
    }
}



#Preview {
    NavigationStack {
        ContentView()
    }
}


enum AppRoute {
    case unauthenticated
    case onboarding
    case main
}


@MainActor
final class AuthGate: ObservableObject {
    @Published var isAuthenticated: Bool? = nil // nil = loading

    func checkAuth() {
        // Use the currentUser property
        if let user = supabase.auth.currentUser {
            print("Signed in as \(user.email ?? "unknown")")
            isAuthenticated = true
        } else {
            print("Not signed in")
            isAuthenticated = false
        }
    }
}


class KeyboardDismissGesture: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
        state = .failed // 👈 allow other touches to continue
    }
}

struct KeyboardDismissHelper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        DispatchQueue.main.async {
            if let window = view.window {
                let gesture = KeyboardDismissGesture()
                gesture.cancelsTouchesInView = false // 👈 VERY IMPORTANT
                
                window.addGestureRecognizer(gesture)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}




struct GuestFlowView: View {
    @StateObject private var guestRouter = GuestNavigationRouter()
    @StateObject private var homeVM = HomeViewModel()

    var body: some View {
        Group {
            if guestRouter.isShowingSignup {
                NavigationStack{
                    SignUpView()
                }
            } else {
                NavigationStack {
                    HomeView(showTabButtons: .constant(false))
                        .environmentObject(homeVM)
                }
            }
        }
        .environmentObject(guestRouter)
    }
}
