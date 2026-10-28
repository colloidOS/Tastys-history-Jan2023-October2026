//
//  WaitlistViewModel.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/01/2026.
//

import SwiftUI
import Combine
import Supabase

struct AddToWaitlistResponse: Decodable {
    let id: Int?
    let total_count: Int
    let is_new: Bool?
}

final class WaitlistService {

    let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    func addToWaitlist(
        email: String?,
        phone: String?
    ) async throws -> AddToWaitlistResponse {

        var params: [String: String] = [:]
        if let email {
            params["p_email"] = email
        }

        if let phone {
            params["p_phone"] = phone
        }
        print(params)
        let response: [AddToWaitlistResponse] = try await supabase
            .rpc(
                "add_to_waitlist",
                params: params
            )
            .execute()
            .value

        guard let first = response.first else {
            throw NSError(
                domain: "WaitlistError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"]
            )
        }

        return first
    }
}




@MainActor
final class WaitlistViewModel: ObservableObject {

    // MARK: - Input
    @Published var email = ""
    @Published var phone = ""

    // MARK: - UI State
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var shouldNavigateToSuccess = false
    @Published var listNumber: Int = 0

    private let waitlistService = WaitlistService(supabase: supabase)
    private var errorTask: Task<Void, Never>?

    // MARK: - Validation rules
    private let phoneRules: [String: PhoneRule] = [
        "+1":   PhoneRule(minDigits: 10, maxDigits: 10),
        "+234": PhoneRule(minDigits: 10, maxDigits: 10),
        "+44":  PhoneRule(minDigits: 10, maxDigits: 10),
        "+91":  PhoneRule(minDigits: 10, maxDigits: 10)
    ]

    // MARK: - Helpers
    func showError(_ message: String) {
        errorTask?.cancel()
        errorMessage = message

        errorTask = Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            await MainActor.run {
                withAnimation {
                    self.errorMessage = nil
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }

    private func isValidPhone(dialCode: String, number: String) -> Bool {
        let digits = number.filter { $0.isNumber }

        guard let rule = phoneRules[dialCode] else {
            return digits.count >= 8 && digits.count <= 15
        }

        return digits.count >= rule.minDigits &&
               digits.count <= rule.maxDigits
    }

    // MARK: - Actions
    func submitEmail() async {

        guard !email.isEmpty else {
            showError("Email is required")
            return
        }

        guard isValidEmail(email) else {
            showError("Enter a valid email address")
            return
        }

        isLoading = true
        do {
            let result = try await waitlistService.addToWaitlist(
                email: email.lowercased(),
                phone: nil
            )

            listNumber = result.total_count
            shouldNavigateToSuccess = true

        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    func submitPhone(
        dialCode: String,
        number: String
    ) async {

        let cleanNumber = number.filter { $0.isNumber }

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
            let result = try await waitlistService.addToWaitlist(
                email: nil,
                phone: finalPhone
            )

            listNumber = result.total_count
            shouldNavigateToSuccess = true

        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
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

}
