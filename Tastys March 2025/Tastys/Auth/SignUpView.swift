//
//  SignUpView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 24/03/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password (min. 8 characters)", text: $password)
            }

            if let error = auth.errorMessage {
                Text(error).foregroundStyle(.red)
            }

            Section {
                Button("Create account") {
                    Task { await auth.signUp(email: email, password: password, displayName: name) }
                }
                .disabled(name.isEmpty || email.isEmpty || password.count < 8 || auth.isWorking)

                Button {
                    // Google sign-in comes later
                } label: {
                    Label("Continue with Google", image: "googleIcon")
                }
                .disabled(true)
            }
        }
        .navigationTitle("Create account")
    }
}
