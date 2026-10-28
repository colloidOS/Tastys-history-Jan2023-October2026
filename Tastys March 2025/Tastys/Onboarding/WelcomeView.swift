//
//  WelcomeView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/10/2024.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image("launchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                Text("Rate dishes, not restaurants.")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text("See what your friends are eating and find the best plate in town.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Spacer()
                NavigationLink {
                    NameEntryView()
                } label: {
                    Text("Get started")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
    }
}
