//
//  EditProfileView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 18/04/2025.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var bio = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Display name", text: $name)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
                if let error {
                    Text(error).foregroundStyle(.red)
                }
            }
            .navigationTitle("Edit profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                try await viewModel.save(displayName: name, bio: bio)
                                dismiss()
                            } catch {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                }
            }
            .onAppear {
                name = viewModel.profile?.displayName ?? ""
                bio = viewModel.profile?.bio ?? ""
            }
        }
    }
}
