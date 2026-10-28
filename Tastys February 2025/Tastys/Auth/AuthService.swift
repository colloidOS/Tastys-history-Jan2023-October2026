//
//  AuthService.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 22/02/2025.
//

import Foundation
import Supabase

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var userID: UUID?
    @Published var errorMessage: String?
    @Published private(set) var isWorking = false

    func restoreSession() async {
        if let session = try? await supabase.auth.session {
            userID = session.user.id
            isSignedIn = true
        }
    }

    func signIn(email: String, password: String) async {
        await run {
            let session = try await supabase.auth.signIn(email: email.lowercased(), password: password)
            self.userID = session.user.id
            self.isSignedIn = true
        }
    }

    func signOut() async {
        try? await supabase.auth.signOut()
        userID = nil
        isSignedIn = false
    }

    private func run(_ work: @escaping () async throws -> Void) async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do { try await work() } catch { errorMessage = error.localizedDescription }
    }
}
