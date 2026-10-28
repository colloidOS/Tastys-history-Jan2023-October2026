//
//  BetaWaitlistView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 15/09/2025.
//

import SwiftUI
import Supabase

struct BetaWaitlistView: View {
    @AppStorage("betaAccessGranted") private var betaAccessGranted = false
    @State private var email = ""
    @State private var inviteCode = ""
    @State private var joined = false
    @State private var message: String?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("launchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
            Text(joined ? "You're on the list 🎉" : "Tastys is in private beta")
                .font(.title2.bold())
            Text("Leave your email and we'll send you an invite as soon as a spot opens.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.grayTastys.opacity(0.12), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

            Button("Join the waitlist") { Task { await join() } }
                .buttonStyle(.borderedProminent)
                .tint(.blackWaitlist)
                .disabled(!email.contains("@") || joined)

            Divider().padding(.vertical)

            HStack {
                TextField("Invite code", text: $inviteCode)
                    .textInputAutocapitalization(.characters)
                Button("Unlock") { betaAccessGranted = inviteCode.uppercased() == "TASTYS2025" }
            }
            if let message { Text(message).font(.footnote).foregroundStyle(.secondary) }
            Spacer()
        }
        .padding(24)
    }

    private func join() async {
        struct Entry: Encodable { let email: String }
        do {
            try await supabase.from("waitlist").insert(Entry(email: email.lowercased())).execute()
            joined = true
        } catch {
            message = error.localizedDescription
        }
    }
}
