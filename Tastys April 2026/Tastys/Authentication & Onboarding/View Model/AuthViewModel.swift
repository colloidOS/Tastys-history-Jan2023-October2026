//
//  AuthViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 02/01/2026.
//

import SwiftUI
import Combine
import Auth
import Supabase
import AuthenticationServices

final class AuthService {
    
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Email Signup
    func signUpWithEmail(email: String, password: String) async throws -> AuthResponse {
        try await supabase.auth.signUp(
            email: email.lowercased(),
            password: password
        )
    }
    
    func verifyEmailOTP(email: String, code: String) async throws -> AuthResponse {
        try await supabase.auth.verifyOTP(
            email: email.lowercased(),
            token: code,
            type: .signup
        )
    }
    
    func resendEmailOTP(email: String) async throws {
        try await supabase.auth.resend(
            email: email.lowercased(),
            type: .signup
        )
    }
    
    func resendEmailRecovery(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email.lowercased())
    }
    
    // MARK: - Email Sign In
    func signInWithEmail(email: String, password: String) async throws -> Session {
        try await supabase.auth.signIn(
            email: email.lowercased(),
            password: password
        )
    }
    
    // MARK: - Phone
    func signUpWithPhone(phone: String, password: String) async throws -> AuthResponse {
        try await supabase.auth.signUp(
            phone: phone,
            password: password
        )
    }
    
    func verifyPhoneOTP(phone: String, code: String) async throws -> AuthResponse {
        try await supabase.auth.verifyOTP(
            phone: phone,
            token: code,
            type: .sms
        )
    }
    
    func resendPhoneOTP(phone: String) async throws {
        try await supabase.auth.resend(
            phone: phone,
            type: .sms
        )
    }
    
    func signInWithPhone(phone: String, password: String) async throws -> Session {
        try await supabase.auth.signIn(
            phone: phone,
            password: password
        )
    }
}

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @AppStorage("firstName") var firstName = ""
    @AppStorage("lastName") var lastName = ""
    @Published var otpCode = ""
    @Published var needsOnboarding = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    @Published var isUpdateLoading = false
    @Published var requiresOTPVerification = false
    @Published var shouldNavigateToName = false
//    @AppStorage("isRecoveringPassword") private var isRecoveringPassword = false
    @Published var isInPasswordRecovery = false
    @Published var isResolvingAuth = false
    @Published var id = ""
    @Published private(set) var session: Session?
    private var pendingSession: Session?
//    @Published var route: AppRoute = .unauthenticated
//    @Published var isAuthenticated: Bool? = nil
    @AppStorage("isOnboardingInProgress")
    private var onboardingStorage = false

    var isOnboardingInProgress: Bool {
        get {
            onboardingStorage
        }
        set {
            onboardingStorage = newValue
        }
    }
    var isAuthenticated: Bool {
        session != nil && !isInPasswordRecovery
    }
    
    @Published var showPasswordResetScreen = false
    private var authListener: AuthStateChangeListenerRegistration?


    init() {
        print("AuthViewModel init:", ObjectIdentifier(self))
            // Load initial session
            Task { @MainActor in
                self.session = try? await supabase.auth.session
                PushTokenManager.shared.tryUploadCachedToken()
//                self.isAuthenticated = self.session != nil
//                self.isAuthenticated = self.session != nil
            }

            // Register auth state listener (async call!)
        Task {
            for await (event, session) in supabase.auth.authStateChanges {
                
                await MainActor.run {

                    
                    if isInPasswordRecovery {
                        pendingSession = session
                        return
                    }
                    self.session = session
                    
                    if event == .signedIn {
                        PushTokenManager.shared.tryUploadCachedToken()   // <-- and this
                    }

                }
            }
        }
    }
    
    deinit {
        authListener?.remove()
    }

    let authService = AuthService(supabase: supabase)
    private var errorTask: Task<Void, Never>?
    
    private let phoneRules: [String: PhoneRule] = [
        "+1":   PhoneRule(minDigits: 10, maxDigits: 10), // US / Canada
        "+234": PhoneRule(minDigits: 10, maxDigits: 10), // Nigeria
        "+44":  PhoneRule(minDigits: 10, maxDigits: 10), // UK
        "+91":  PhoneRule(minDigits: 10, maxDigits: 10)  // India
    ]
    
    var isOTPComplete: Bool {
        otpCode.count == 6
    }


    func isValidEmail(_ email: String) -> Bool {
        let regex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
    func isValidPhone(
        dialCode: String,
        number: String
    ) -> Bool {

        // Remove spaces, dashes, etc.
        let digits = number.filter { $0.isNumber }

        guard let rule = phoneRules[dialCode] else {
            return digits.count >= 8 && digits.count <= 15 // safe fallback
        }

        return digits.count >= rule.minDigits &&
               digits.count <= rule.maxDigits
    }

    func showError(_ message: String) {
        errorTask?.cancel()
        errorMessage = message

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation {
                    errorMessage = nil
                }
            }
        }
    }
    
    func showSuccess(_ message: String) {
        errorTask?.cancel()
        errorMessage = message

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation {
                    errorMessage = nil
                }
            }
        }
    }

    func signIn(isUsingEmail: Bool, dialCode: String? = nil) async {

        

        isLoading = true
        do {
            if isUsingEmail {
                // Email validation
                guard !email.isEmpty else {
                    showError("Email is required")
                    isLoading = false
                    return
                }

                guard isValidEmail(email) else {
                    showError("Enter a valid email address")
                    isLoading = false
                    return
                }
                
                guard !password.isEmpty else {
                    showError("Password is required")
                    isLoading = false
                    return
                }
                id = email

                _ = try await authService.signInWithEmail(
                    email: email,
                    password: password
                )
                needsOnboarding = false
                isOnboardingInProgress = false
                

            } else {
                // Phone validation
                guard let dialCode else {
                    showError("Country code missing")
                    isLoading = false
                    return
                }

                let cleanNumber = phone.filter { $0.isNumber }

                guard !cleanNumber.isEmpty else {
                    showError("Phone number is required")
                    isLoading = false
                    return
                }

                guard isValidPhone(dialCode: dialCode, number: cleanNumber) else {
                    showError("Enter a valid phone number")
                    isLoading = false
                    return
                }
                
                guard !password.isEmpty else {
                    showError("Password is required")
                    isLoading = false
                    return
                }

                let finalPhone = dialCode + cleanNumber

                id = finalPhone
                _ = try await authService.signInWithPhone(
                    phone: finalPhone,
                    password: password
                )
                needsOnboarding = false
                isOnboardingInProgress = false
            }

            // ✅ Successful sign in
//            shouldNavigateToName = true

        } catch {
            let message = error.localizedDescription

                if message.lowercased().contains("email not confirmed") {
                    requiresOTPVerification = true
                    await resendOTP(isUsingEmail: true)
                    return
                } else if message.lowercased().contains("phone not confirmed") {
                    requiresOTPVerification = true
                    await resendOTP(isUsingEmail: false)
                    return
                }

                showError(message)
//            showError(error.localizedDescription)
        }

        isLoading = false
    }

    
    func signUpWithEmail() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        
        isLoading = true
        do {
            _ = try await authService.signUpWithEmail(
                email: email,
                password: password
            )
            requiresOTPVerification = true
            successMessage = "Check your email for OTP"
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func verifySignUpEmailOTP() async {
        isLoading = true
        do {
            isOnboardingInProgress = true
            let response = try await authService.verifyEmailOTP(
                email: email,
                code: otpCode
            )
            
            let userId = response.user.id
            try await updateUserProfile(
                UpdateUserProfileParams(
                    userId: userId,
                    firstName: firstName,
                    lastName: lastName
                )
            )
            
            successMessage = "Email verified"
            requiresOTPVerification = false
            needsOnboarding = true  // Set for new user
        } catch {
            isOnboardingInProgress = false
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signUpWithPhone() async {
        guard !phone.isEmpty, !password.isEmpty else {
            errorMessage = "Phone and password are required."
            return
        }
        print(phone)
        isLoading = true
        do {
            _ = try await authService.signUpWithPhone(
                phone: phone,
                password: password
            )
            requiresOTPVerification = true
            successMessage = "Check your phone for OTP"
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func verifySignUpPhoneOTP() async {
        isLoading = true
        do {
            isOnboardingInProgress = true
            let response = try await authService.verifyPhoneOTP(
                phone: phone,
                code: otpCode
            )
            
            let userId = response.user.id
            try await updateUserProfile(
                UpdateUserProfileParams(
                    userId: userId,
                    firstName: firstName,
                    lastName: lastName
                )
            )
            
            successMessage = "Phone verified"
            requiresOTPVerification = false
            needsOnboarding = true  // Set for new user
        } catch {
            isOnboardingInProgress = false
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func checkEmailAndContinue() async {
        guard !email.isEmpty else {
            showError("Email is required")
            return
        }
        
        // Format check
            guard isValidEmail(email) else {
                showError("Enter a valid email address")
                return
            }

        isLoading = true
        do {
            let exists = try await authService.checkEmailExists(email)

            if exists {
                showError("Email already exists. Please sign in.")
            } else {
                shouldNavigateToName = true
            }
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }
    
    func checkEmailAndSendOTP() async {
        guard !email.isEmpty else {
            showError("Email is required")
            return
        }
        
        // Format check
            guard isValidEmail(email) else {
                showError("Enter a valid email address")
                return
            }

        isLoading = true
        do {
            let exists = try await authService.checkEmailExists(email)

            if !exists {
                showError("No user found")
            } else {
                let _ = try await supabase.auth.resetPasswordForEmail(email)
                showPasswordResetScreen = true
            }
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    func checkPhoneAndSendOTP(dialCode: String) async {
        let cleanNumber = phone.filter { $0.isNumber }
        
        guard !cleanNumber.isEmpty else {
            showError("Phone number is required")
            return
        }

        guard isValidPhone(dialCode: dialCode, number: cleanNumber) else {
            showError("Enter a valid phone number")
            return
        }

        let finalPhone = dialCode + cleanNumber

        isLoading = true
        do {
            let exists = try await authService.checkPhoneExists(finalPhone)

            if !exists {
                showError("No user found")
            } else {
                try await supabase.auth.signInWithOTP(phone: finalPhone)
                phone = finalPhone
                showPasswordResetScreen = true
                successMessage = "Check your phone for the code"
            }
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    func checkPhoneAndContinue(dialCode: String) async {

        let cleanNumber = phone.filter { $0.isNumber }
        

        guard !cleanNumber.isEmpty else {
            showError("Phone number is required")
            return
        }

        guard isValidPhone(dialCode: dialCode, number: cleanNumber) else {
            showError("Enter a valid phone number")
            return
        }

        let finalDial = dialCode.replacingOccurrences(of: "+", with: "")
        let finalPhoneNumber = finalDial + cleanNumber
        print(finalPhoneNumber)
//        phone = dialCode + cleanNumber

        isLoading = true
        do {
            let exists = try await authService.checkPhoneExists(finalPhoneNumber)

            if exists {
                showError("Phone number already exists. Please sign in.")
            } else {
                phone = finalPhoneNumber
                shouldNavigateToName = true
            }
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    func verifyOTP(isUsingEmail: Bool) async {
        guard otpCode.count == 6 else {
            showError("Enter the 6-digit code")
            return
        }

        isLoading = true
        do {
            isOnboardingInProgress = true
            if isUsingEmail {
                let response = try await authService.verifyEmailOTP(
                    email: email,
                    code: otpCode
                )

                try await updateUserProfile(
                    UpdateUserProfileParams(
                        userId: response.user.id,
                        firstName: firstName,
                        lastName: lastName
                    )
                )
            } else {
                let response = try await authService.verifyPhoneOTP(
                    phone: phone,
                    code: otpCode
                )

                try await updateUserProfile(
                    UpdateUserProfileParams(
                        userId: response.user.id,
                        firstName: firstName,
                        lastName: lastName
                    )
                )
            }

            successMessage = "Verification successful"
            requiresOTPVerification = false
            needsOnboarding = true

        } catch {
            isOnboardingInProgress = false
            showError(error.localizedDescription)
            print(error.localizedDescription)
        }
        isLoading = false
    }
    

    func resendOTP(isUsingEmail: Bool) async {
        isLoading = true
        do {
            if isUsingEmail {
                try await authService.resendEmailOTP(email: email)
                successMessage = "Code resent to email"
            } else {
                try await authService.resendPhoneOTP(phone: phone)
                successMessage = "Code resent to phone"
            }
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }
    
    /// Checks if a username is available
    func isUsernameAvailable(_ username: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let available = try await authService.checkUsernameAvailability(username)
            if !available {
                showError("Username is already taken")
            }
            return available
        } catch {
            showError(error.localizedDescription)
            return false
        }
    }

        /// Updates the username for the current user
    func updateUsername(_ username: String) async -> Bool {
        guard let session = session else {
            showError("User not authenticated")
            return false
        }

        isUpdateLoading = true
        defer { isUpdateLoading = false }

        do {
            let updatedProfile = try await authService.updateUsername(
                userId: session.user.id.uuidString,
                username: username
            )
            successMessage = "Username updated"
            return true
        } catch {
            showError(error.localizedDescription)
            return false
        }
    }
    func formatUSPhone(_ input: String) -> String {
        let digits = input.filter(\.isNumber)
        let maxDigits = String(digits.prefix(10))

        switch maxDigits.count {
        case 0...3:
            return maxDigits.isEmpty ? "" : "(\(maxDigits)"
        case 4...6:
            let area = maxDigits.prefix(3)
            let mid = maxDigits.dropFirst(3)
            return "(\(area)) \(mid)"
        default:
            let area = maxDigits.prefix(3)
            let mid = maxDigits.dropFirst(3).prefix(3)
            let last = maxDigits.dropFirst(6)
            return "(\(area)) \(mid)-\(last)"
        }
    }
    

    func resendRecoveryOTP(isUsingEmail: Bool, identifier: String) async {
        isLoading = true
        do {
            if isUsingEmail {
                try await authService.resendEmailRecovery(email: identifier)
            } else {
                try await authService.resendPhoneOTP(phone: identifier)
            }
            successMessage = "New code sent"
        } catch {
            showError("Failed to resend code: \(error.localizedDescription)")
        }
        isLoading = false
    }
        
        func resetPasswordWithOTP(isUsingEmail: Bool, identifier: String, otp: String, newPassword: String) async {
            isLoading = true
            do {
                // 1. Re-authenticate → sends OTP (but we already sent it earlier)
                //    In practice, if user is not signed in, you may need to skip or handle differently
                //    For password reset flow, Supabase usually doesn't require prior session for recovery
                
                // 2. Update password with nonce (OTP)
                try await supabase.auth.update(
                    user: UserAttributes(
                        password: newPassword,
                        nonce: otp   // the 6-digit code
                    )
                )
                
                successMessage = "Password reset successfully"
                
            } catch {
                showError("Password reset failed: \(error.localizedDescription)")
            }
            isLoading = false
        }
    
    func updatePassword(newPassword: String, confirmPassword: String) async {
        guard !newPassword.isEmpty, newPassword == confirmPassword else {
            showError("Passwords do not match or are empty")
            return
        }
        
        guard newPassword.count >= 6 else {  // Adjust to your password policy
            showError("Password must be at least 6 characters")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Correct syntax: update(user:) with UserAttributes
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            
            await MainActor.run {
                session = pendingSession
                pendingSession = nil
                print("Password updated successfully")
                successMessage = "Password updated successfully!"
                isInPasswordRecovery = false

                showPasswordResetScreen = false
            }
            
            // Or keep signed in and redirect to home/profile
        } catch {
            
            showError("Failed to update password: \(error.localizedDescription)")
            print("Failed to update password: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async {
        isLoading = true
        isResolvingAuth = true
        
        defer {
            isLoading = false
            isResolvingAuth = false
        }
        
        do {
            let session = try await authService.signInWithApple(idToken: idToken, nonce: nonce)
            
//            self.isAuthenticated = true
            
            // Check if profile exists
            if let profile = try await authService.getUserProfile(userId: session.user.id.uuidString) {
                // Returning user
                let needsOnboarding =
                        (profile.first_name.isEmpty &&
                        profile.last_name.isEmpty) ||
                        profile.username.hasPrefix("user_")

                    self.needsOnboarding = needsOnboarding
                isOnboardingInProgress = needsOnboarding
                
                if self.needsOnboarding {
                    // New user
                    let firstName = fullName?.givenName ?? ""
                    let lastName = fullName?.familyName ?? ""
                    
                    print("first name: \(firstName), last name: \(lastName)")
                    _ = try await updateUserProfile(
                        UpdateUserProfileParams(
                            userId: session.user.id,
                            firstName: firstName,
                            lastName: lastName
                        )
                    )
                    
//                    self.needsOnboarding = true
                }
                self.session = session

                    successMessage = needsOnboarding
                        ? "Account created!"
                        : "Welcome back!"
            } else {
                showError("Apple Sign-In failed")
                print("Apple Sign-In failed: no user profile created")
//                successMessage = "Account created!"
            }
            
        } catch let error as ASAuthorizationError {
            
            switch error.code {
            case .canceled:
                print("Apple Sign-In interrupted")
                return
            case .failed:
                showError("Apple Sign-In failed")
                
            case .invalidResponse:
                showError("Invalid Apple Sign-In response")
                
            case .notHandled:
                showError("Apple Sign-In not handled")
                
            case .unknown:
                fallthrough
                
            @unknown default:
                showError("Something went wrong with Apple Sign-In")
            }
            
            print("Apple Sign-In error: \(error.localizedDescription)")
            
        } catch {
            showError("Apple Sign-In failed")
            print("Apple sign-in failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func verifyRecoveryOTP(email: String, token: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await authService.verifyRecoveryOTP(
                email: email,
                token: token
            )

            // Handle success
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension AuthService {

    func verifyRecoveryOTP(
        email: String,
        token: String
    ) async throws -> AuthResponse {
        try await supabase.auth.verifyOTP(
            email: email.lowercased(),
            token: token,
            type: .recovery
        )
    }
    
    func checkEmailExists(_ email: String) async throws -> Bool {
        let response: Bool = try await supabase
            .rpc(
                "check_email_exists",
                params: ["p_email": email.lowercased()]
            )
            .execute()
            .value
        return response
    }

    func checkPhoneExists(_ phone: String) async throws -> Bool {
        let response: Bool = try await supabase
            .rpc(
                "check_phone_exists",
                params: ["p_phone": phone]
            )
            .execute()
            .value
        return response
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let response: Bool = try await supabase
            .rpc(
                "check_username_availability",
                params: ["target_username": username.lowercased()]
            )
            .execute()
            .value
        return response
    }
    
    func updateUsername(userId: String, username: String) async throws -> UserProfile {
        let response = try await supabase
            .rpc(
                "update_user_profile",
                params: ["p_user_id": userId, "p_username": username.lowercased()]
            )
            .execute()

        // Decode directly
        let updatedProfile = try JSONDecoder.supabase.decode(UserProfile.self, from: response.data)
        return updatedProfile
    }
    func signInWithApple(idToken: String, nonce: String) async throws -> Session {
            // FIXED: Use SignInWithIdTokenCredentials (not OAuthCredentials).
            // Provider .apple is now correctly inferred.
            // Nonce is a separate param in signInWithIdToken.
        let credentials = OpenIDConnectCredentials(
            provider: .apple,
            idToken: idToken,
            nonce: nonce
        )
        return try await supabase.auth.signInWithIdToken(
            credentials: credentials
        )
    }
        
        func getUserProfile(userId: String) async throws -> UserProfile? {
            // FIXED: No .maybeSingle() or .decoded(as:). Use .single().execute().value for auto-decoding.
            // Use try? to make it optional (nil if no row or error).
            let response = try? await supabase
                .from("user_profile")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value as UserProfile?  // Infer as optional UserProfile
            return response
        }

}


struct PhoneRule {
    let minDigits: Int
    let maxDigits: Int
}
