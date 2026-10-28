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
    @AppStorage("foodProfile") private var foodProfileRaw = FoodProfile.adventurous.rawValue

    var body: some View {
        Form {
            Section("What should we call you?") {
                TextField("Name", text: $displayName)
                    .textContentType(.givenName)
            }
            Section("What kind of eater are you?") {
                Picker("Food profile", selection: $foodProfileRaw) {
                    ForEach(FoodProfile.allCases) { profile in
                        Text(profile.title).tag(profile.rawValue)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Button("Continue") { hasOnboarded = true }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .navigationTitle("About you")
    }
}
