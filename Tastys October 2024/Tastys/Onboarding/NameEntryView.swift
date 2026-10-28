//
//  NameEntryView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 17/10/2024.
//

import SwiftUI

struct NameEntryView: View {
    @AppStorage("displayName") private var displayName = ""
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        Form {
            Section("What should we call you?") {
                TextField("Name", text: $displayName)
                    .textContentType(.givenName)
            }
            Button("Continue") { hasOnboarded = true }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .navigationTitle("About you")
    }
}
