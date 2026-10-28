//
//  SetUsernameView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/12/2025.
//

import SwiftUI

struct SetUsernameView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var username = ""
    @State private var isChecking = false
    @State private var isAvailable: Bool? = nil
//    @State private var navigateToMain = false
    var body: some View {
        ZStack{
            Color.fakeWhite
                .ignoresSafeArea()
            
//            NavigationLink(
//                destination: MainTabView()
//                    .navigationBarBackButtonHidden()
//                    .disableSwipeBack(),
//                isActive: $navigateToMain
//            ) {
//                EmptyView()
//            }
            
            if let err = authVM.errorMessage {
                VStack {
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .padding(.vertical, 19)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 34).fill(Color.white))
                        .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(1)
            }
            
            VStack(spacing: 45){
             
                HStack{
                    Button{
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .frame(height: 38)
                            Image("backButtonIcon")
                                .renderingMode(.template)
                                .foregroundStyle(.black)
//                                .padding()
//                                .clipShape(Circle())
//                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    
                    ZStack {
                        // Outer pill
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.green)
                            .frame(width: 66, height: 28)
                        
                        
                        // Centered text
                        Text("3/3")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            
                    }
                    .frame(width: 70, height: 28)
                }
                .padding()
                Spacer()
                Text("Enter your username")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .opacity(0.3)
                
                ZStack{
                    Circle()
                        .foregroundStyle(.rectTastys)
                        .frame(height: 108)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundStyle(.white)
                        .frame(height: 109)
                    
                    Image("plateUsername")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38.47, height: 38.47)
                }
                .overlay(alignment: .bottomTrailing) {
                    ZStack{
                        Circle()
                            .foregroundStyle(.white)
                            .frame(height: 34.5)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1.5)
                                    .blur(radius: 2)
                                    .offset(x: 0, y: 1)
                            )
                            .clipShape(Circle())
                        
//                        Image(systemName: "plus")
//                            .foregroundStyle(.tastysRed)
//                            .font(.system(size: 18))
//                            .bold()
                        
                    }
                }
                
                
                HStack(spacing: 2){
                    Text("@")
                        .foregroundStyle(.black)
                        .opacity(0.4)
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                    
                    TextField("JohnDoe123", text: $username)
                        .foregroundStyle(.black)
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .fixedSize()
                        .focused($isTextFieldFocused)
                        .onChange(of: username) { _, newValue in
                            isChecking = false
                            isAvailable = nil

                            Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if newValue == username {
                                    checkUsername(newValue)
                                }
                            }
                        }

                        
                    if isChecking {
                        ProgressView()
                            .scaleEffect(1.1)
                            .padding(.horizontal, 8)
                    }
                    else if isAvailable == true {
                        ZStack {
                            Circle().foregroundStyle(.greenTastys)
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                        .frame(height: 34)
                        .padding(.horizontal, 8)
                    }
                    else if isAvailable == false {
                        ZStack {
                            Circle().foregroundStyle(.tastysRed)
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                        .frame(height: 33)
                        .padding(.horizontal, 8)
                    }
                    
                    
                    
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                Spacer()
                
                Button {
                    let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !trimmedUsername.isEmpty else {
                        withAnimation {
                            authVM.errorMessage = "Username cannot be empty"
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                authVM.errorMessage = nil
                            }
                        }

                        return
                    }

                    guard isAvailable == true else {
                        withAnimation {
                            authVM.errorMessage = "Username is not available"
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                authVM.errorMessage = nil
                            }
                        }

                        return
                    }

                    Task {
                        let success = await authVM.updateUsername(trimmedUsername.lowercased())

                        if success {
                            await MainActor.run {
                                authVM.needsOnboarding = false
                                authVM.isOnboardingInProgress = false
//                                navigateToMain = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Spacer()

                        Text("Continue")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .padding(.vertical)

                        Spacer()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundStyle(.tastysRed)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                .disabled(authVM.isLoading)
            }
            
            if authVM.isUpdateLoading {
                Color.ashTastys
                    .opacity(0.6)
                
                ProgressView("updating...")
            }
            
        }
        .onAppear {
            DispatchQueue.main.async {
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
//        .enableSwipeBack()

        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
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
//            
//            ToolbarItem(placement: .topBarTrailing) {
//                Button{
//                    
//                } label: {
//                    ZStack {
//                        // Outer pill
////                        RoundedRectangle(cornerRadius: 25)
////                            .fill(.green)
////                            .frame(width: 66, height: 28)
//                        
//                        
//                        // Centered text
//                        Text("3/3")
//                            .foregroundStyle(.black)
//                            .font(.system(size: 16))
//                            .fontWeight(.medium)
//                            .padding(.vertical, 3)
//                            .padding(.horizontal, 20)
//                            .background{
//                                RoundedRectangle(cornerRadius: 25)
//                                    .fill(.green)
//                            }
//                    }
////                    .frame(width: 72, height: 28)
//                }
//                .buttonStyle(.plain)
//
//            }
//        }
        .toolbarBackground(.hidden, for: .navigationBar)
        
        
        
    }
    func checkUsername(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isAvailable = nil
            return
        }

        isChecking = true
        isAvailable = nil

        Task {
            let available = await authVM.isUsernameAvailable(trimmed.lowercased())

            await MainActor.run {
                self.isAvailable = available
                self.isChecking = false
            }
        }
    }

}

#Preview {
    NavigationStack {
        SetUsernameView()
            .environmentObject(AuthViewModel())
    }
}



//struct DisableSwipeBackModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .background(
//                NavigationControllerConfigurator {
//                    $0.interactivePopGestureRecognizer?.isEnabled = false
//                }
//            )
//    }
//}
//
//extension View {
//    func disableSwipeBack() -> some View {
//        modifier(DisableSwipeBackModifier())
//    }
//}
//
//struct NavigationControllerConfigurator: UIViewControllerRepresentable {
//    let configure: (UINavigationController) -> Void
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        viewController.view.backgroundColor = .clear
//        return viewController
//    }
//
//    func updateUIViewController(
//        _ viewController: UIViewController,
//        context: Context
//    ) {
//        if let navigationController = viewController.navigationController {
//            configure(navigationController)
//        }
//    }
//}
