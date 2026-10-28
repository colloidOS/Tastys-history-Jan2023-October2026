//
//  SignInView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 12/02/2025.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Image("logoImage")
                .resizable()
                .scaledToFit()
                .frame(height: 64)
                .padding(.bottom, 24)

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.grayTastys.opacity(0.12), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color.grayTastys.opacity(0.12), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

            if let error = auth.errorMessage {
                Text(error).font(.footnote).foregroundStyle(.red)
            }

            Button {
                Task { await auth.signIn(email: email, password: password) }
            } label: {
                Group {
                    if auth.isWorking { ProgressView() } else { Text("Sign in") }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.count < 6 || auth.isWorking)
        }
        .padding(24)
    }
}
