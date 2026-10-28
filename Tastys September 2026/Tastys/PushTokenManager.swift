//
//  PushTokenManager.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 20/09/2026.
//

import Foundation

final class PushTokenManager {
    static let shared = PushTokenManager()
    private let defaultsKey = "pendingFCMToken"

    private init() {}

    /// Called from didReceiveRegistrationToken every time Firebase hands us a token
    /// (this can fire multiple times over an app's life — token rotation is normal).
    func cache(token: String) {
        UserDefaults.standard.set(token, forKey: defaultsKey)
        Task { await tryUpload() }
    }

    /// Called again whenever auth state changes to signed-in, in case the token
    /// arrived before the user was logged in.
    func tryUploadCachedToken() {
        Task { await tryUpload() }
    }

    private func tryUpload() async {
        guard let token = UserDefaults.standard.string(forKey: defaultsKey) else { return }

        guard let session = try? await supabase.auth.session else {
            // not logged in yet — token stays cached, we'll retry on next auth event
            return
        }
        let userId = session.user.id

        do {
            try await supabase
                .from("user_device_token")
                .upsert([
                    "user_id": userId.uuidString,
                    "token": token,
                    "platform": "ios"
                ], onConflict: "user_id,token")
                .execute()
            print("Uploaded FCM token to Supabase")
        } catch {
            print("Failed to upload FCM token: \(error)")
            // leave it cached — will retry next time cache() or tryUploadCachedToken() fires
        }
    }
}
