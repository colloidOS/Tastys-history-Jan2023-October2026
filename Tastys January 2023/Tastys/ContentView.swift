//
//  ContentView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 04/01/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Text("Tastys")
                .font(.largeTitle)
                .bold()
            Text("Find the dish, not just the restaurant.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
