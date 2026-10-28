//
//  NameView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 16/12/2025.
//

import SwiftUI

struct NameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    var id: String
    var isUsingEmail: Bool
    
    // Animation states for initial appear (staggered)
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateNameFields = false
    @State private var animatePasswordField = false
    @State private var animateInstruction = false
    @State private var animateContinueButton = false
    @FocusState private var isTextFieldFocused: Bool
    // Error display
    @State private var showError = false
    @State private var navigateToVerify = false
    
    private let animationDuration: Double = 0.6
    private let delayInterval: Double = 0.05
    
    var body: some View {
        ZStack {
            Color.fakeWhite
                .ignoresSafeArea()
            
            if let err = viewModel.errorMessage, showError {
                VStack {
                    Text(err)
                        .foregroundStyle(.black)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 21)
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                        .shadow(color: .black.opacity(0.12), radius: 28, x: 0, y: 10.95)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .zIndex(1)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .frame(height: 45)
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
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.white)
                            .frame(width: 69, height: 28)
    
                        // Green progress fill (flat trailing edge)
                        GeometryReader { geo in
                            Rectangle()
                                .fill(.green)
                                .frame(
                                    width: geo.size.width / 3,
                                    height: geo.size.height
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
    
                        // Centered text
                        Text("1/3")
                            .foregroundStyle(.black)
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                    }
                    .frame(width: 68, height: 28)
                }
                // Title
                Text("Create your account")
                    .foregroundStyle(.black)
                    .font(.system(size: 33))
                    .fontWeight(.medium)
                    .offset(y: animateTitle ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateTitle)
                
                // Subtitle
                Text("Enter your name and a secure password so we get to know you better")
                    .foregroundStyle(.black)
                    .opacity(0.5)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .offset(y: animateSubtitle ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animateSubtitle)
                
                // Name fields horizontal
                HStack(spacing: 8) {
                    ReuseableTextField(text: $viewModel.firstName, placeholder: "First name")
                        .frame(maxWidth: .infinity)
                        .focused($isTextFieldFocused)
                    ReuseableTextField(text: $viewModel.lastName, placeholder: "Last name")
                        .frame(maxWidth: .infinity)
                        .focused($isTextFieldFocused)
                }
                .offset(y: animateNameFields ? 0 : UIScreen.main.bounds.height)
                .animation(.easeOut(duration: animationDuration), value: animateNameFields)
                
                // Password field
                ReuseableSecureField(password: $viewModel.password)
                    .offset(y: animatePasswordField ? 0 : UIScreen.main.bounds.height)
                    .animation(.easeOut(duration: animationDuration), value: animatePasswordField)
                    .focused($isTextFieldFocused)
                
                // Password instruction with checkmark
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 20))
                        .opacity(viewModel.password.count >= 8 ? 1 : 0)
                    Text("Enter at least 8 digits")
                        .foregroundStyle(.black.opacity(0.5))
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                    Spacer()
                }
                .offset(y: animateInstruction ? 0 : UIScreen.main.bounds.height)
                .animation(.easeOut(duration: animationDuration), value: animateInstruction)
                
                Spacer()
                
                // Continue Button
                Button {
                    print(id)
                    print("email: \(viewModel.email), number: \(viewModel.phone)")
                    print("is it using email: \(isUsingEmail)")
                    var valid = true
                    if viewModel.firstName.isEmpty {
                        viewModel.errorMessage = "Please enter your first name"
                        valid = false
                    } else if viewModel.lastName.isEmpty {
                        viewModel.errorMessage = "Please enter your last name"
                        valid = false
                    } else if viewModel.password.count < 8 {
                        viewModel.errorMessage = "Password must be at least 8 characters"
                        valid = false
                    }
                    
                    if valid {
                        Task {
                            if isUsingEmail {
                                await viewModel.signUpWithEmail()
                                if viewModel.errorMessage != nil {
                                    withAnimation {
                                        showError = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showError = false
                                        }
                                        viewModel.errorMessage = nil
                                    }
                                } else {
                                    navigateToVerify = true
                                }
                            } else {
                                await viewModel.signUpWithPhone()
                                if viewModel.errorMessage != nil {
                                    withAnimation {
                                        showError = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showError = false
                                        }
                                        viewModel.errorMessage = nil
                                    }
                                } else {
                                    navigateToVerify = true
                                }
                            }
                            
                        }
                    } else {
                        withAnimation {
                            showError = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showError = false
                            }
                            viewModel.errorMessage = nil
                        }
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
                        RoundedRectangle(cornerRadius: 29.0)
                            .foregroundStyle(.tastysRed)
                    }
                }
                .buttonStyle(.plain)
                .offset(y: animateContinueButton ? 0 : UIScreen.main.bounds.height)
                .animation(.easeOut(duration: animationDuration), value: animateContinueButton)
            }
            .padding(.horizontal)
            .padding(.bottom, 28)
            
            if viewModel.isLoading {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(1.5)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
//        .enableSwipeBack()
        .navigationBarBackButtonHidden()
        
        .background(
            NavigationLink(destination: VerifyEmailView(isUsingEmail: isUsingEmail, text: id, authVM: viewModel).environmentObject(viewModel), isActive: $navigateToVerify) {
                EmptyView()
            }
            .hidden()
        )
        .onAppear {
            print("is it using email?: \(isUsingEmail)")
            viewModel.password = ""
            if isUsingEmail {
                viewModel.email = id
            } else {
                viewModel.phone = id
            }
            
            
            // Staggered initial appear
            let delays: [Double] = [0.0, 0.05, 0.10, 0.15, 0.20, 0.25]
            for delay in delays {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: animationDuration)) {
                        if delay == 0.0 { animateTitle = true }
                        else if delay == 0.05 { animateSubtitle = true }
                        else if delay == 0.10 { animateNameFields = true }
                        else if delay == 0.15 { animatePasswordField = true }
                        else if delay == 0.20 { animateInstruction = true }
                        else if delay == 0.25 { animateContinueButton = true }
                    }
                }
            }
        }
    }
}

#Preview {
//    CombinedNamePasswordView(id: "")
    NavigationStack {
        NameView(id: "nnagoziemcollin@gmail.com", isUsingEmail: true)
            .environmentObject(AuthViewModel())
    }
}



//struct CombinedNamePasswordView: View {
//    @Environment(\.dismiss) var dismiss
//    var id: String
//    @State private var firstName = ""
//    @State private var lastName = ""
//    @State private var password = ""
//    
//    @State private var stage: Int = 1  // 1: First name, 2: Last name, 3: Password
//    
//    // Animation states for initial appear (staggered)
//    @State private var animateTitle = false
//    @State private var animateSubtitle = false
//    @State private var animateFirstNameField = false
//    @State private var animateContinueButton = false
//    
//    // Transition animations
//    @State private var firstNameScale: CGFloat = 1.0
//    @State private var firstNameOffset: CGFloat = 0.0
//    @State private var lastNameScale: CGFloat = 1.0
//    @State private var lastNameOffset: CGFloat = 0.0
//    @State private var animateLastNameField = false
//    @State private var animatePasswordField = false
//    
//    private let animationDuration: Double = 0.6
//    private let delayInterval: Double = 0.05
//    
//    var currentTitle: String {
//        switch stage {
//        case 1: return "Enter your First name"
//        case 2: return "Enter your Last name"
//        case 3: return "Enter your password"
//        default: return ""
//        }
//    }
//    
//    var currentSubtitle: String {
//        switch stage {
//        case 1: return "Enter your first name so we \nget to know a bit more about you"
//        case 2: return "Enter your last name so we \nget to know a bit more about you"
//        case 3: return "Enter a safe and secure password"
//        default: return ""
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            Color.fakeWhite
//                .ignoresSafeArea()
//            
//            VStack(alignment: .leading, spacing: 15) {
//                // Title
//                Text(currentTitle)
//                    .foregroundStyle(.black)
//                    .font(.system(size: 32))
//                    .fontWeight(.medium)
//                    .offset(y: animateTitle ? 0 : UIScreen.main.bounds.height)
//                    .animation(.easeOut(duration: animationDuration), value: animateTitle)
//                
//                // Subtitle
//                Text(currentSubtitle)
//                    .foregroundStyle(.black)
//                    .opacity(0.5)
//                    .font(.system(size: 12))
//                    .fontWeight(.medium)
//                    .offset(y: animateSubtitle ? 0 : UIScreen.main.bounds.height)
//                    .animation(.easeOut(duration: animationDuration), value: animateSubtitle)
//                
//                // Fields stack
//                ZStack/*(spacing: 25) */{
//                    if stage >= 1 {
//                        ReuseableTextField(text: $firstName, placeholder: "First name")
//                            .scaleEffect(firstNameScale)
//                            .offset(y: firstNameOffset)
//                            .offset(y: animateFirstNameField ? 0 : UIScreen.main.bounds.height)
//                            .animation(.easeOut(duration: animationDuration), value: animateFirstNameField)
//                            .disabled(stage > 1)  // Disable editing after stage 1
//                    }
//                    
//                    if stage >= 2 {
//                        ReuseableTextField(text: $lastName, placeholder: "Last name")
//                            .scaleEffect(lastNameScale)
//                            .offset(y: lastNameOffset)
//                            .offset(y: animateLastNameField ? 0 : UIScreen.main.bounds.height)
//                            .animation(.easeOut(duration: animationDuration), value: animateLastNameField)
//                            .disabled(stage > 2)
//                    }
//                    
//                    if stage >= 3 {
//                        ReuseableSecureField(password: $password)
//                            .offset(y: animatePasswordField ? 0 : UIScreen.main.bounds.height)
//                            .animation(.easeOut(duration: animationDuration), value: animatePasswordField)
//                    }
//                }
//                .padding(.vertical, 37)
//                
//                Spacer()
//                
//                // Continue Button
//                if stage < 3 {
//                    Button {
//                        advanceStage()
//                    } label: {
//                        HStack {
//                            Spacer()
//                            Text("Continue")
//                                .foregroundStyle(.white)
//                                .font(.system(size: 16))
//                                .fontWeight(.bold)
//                                .padding(.vertical)
//                            Spacer()
//                        }
//                        .background {
//                            RoundedRectangle(cornerRadius: 21.0)
//                                .foregroundStyle(.tastysRed)
//                        }
//                    }
//                    .offset(y: animateContinueButton ? 0 : UIScreen.main.bounds.height)
//                    .animation(.easeOut(duration: animationDuration), value: animateContinueButton)
//                } else {
//                    NavigationLink {
//                        VerifyEmailView(isUsingEmail: false, text: id)
//                    } label: {
//                        HStack {
//                            Spacer()
//                            Text("Continue")
//                                .foregroundStyle(.white)
//                                .font(.system(size: 15))
//                                .fontWeight(.bold)
//                                .padding(.vertical)
//                            Spacer()
//                        }
//                        .background {
//                            RoundedRectangle(cornerRadius: 25.0)
//                                .foregroundStyle(.tastysRed)
//                        }
//                    }
//                    .offset(y: animateContinueButton ? 0 : UIScreen.main.bounds.height)
//                    .animation(.easeOut(duration: animationDuration), value: animateContinueButton)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 24)
//        }
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
//                        .foregroundStyle(.white)
//                }
//            }
//        }
//        .onAppear {
//            // Staggered initial appear for stage 1
//            let delays: [Double] = [0.0, 0.05, 0.10, 0.15]
//            for delay in delays {
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    withAnimation(.easeOut(duration: animationDuration)) {
//                        if delay == 0.0 { animateTitle = true }
//                        else if delay == 0.05 { animateSubtitle = true }
//                        else if delay == 0.10 { animateFirstNameField = true }
//                        else if delay == 0.15 { animateContinueButton = true }
//                    }
//                }
//            }
//        }
//        .onChange(of: stage) { newStage in
//            if newStage == 2 {
//                withAnimation(.easeOut(duration: animationDuration)) {
//                    firstNameScale = 0.9
//                    firstNameOffset = -15
//                    animateLastNameField = true
//                }
//            } else if newStage == 3 {
//                withAnimation(.easeOut(duration: animationDuration)) {
//                    firstNameOffset = -30  // Further up for first name
//                    firstNameScale = 0.8
//                    lastNameScale = 0.9
//                    lastNameOffset = -15
//                    animatePasswordField = true
//                }
//            }
//        }
//    }
//    
//    private func advanceStage() {
//        if stage < 3 {
//            stage += 1
//        }
//    }
//}
