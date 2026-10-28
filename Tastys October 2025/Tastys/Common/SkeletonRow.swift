//
//  SkeletonRow.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 22/10/2025.
//

import SwiftUI

struct SkeletonRow: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().frame(width: 36, height: 36)
                RoundedRectangle(cornerRadius: 4).frame(width: 120, height: 12)
            }
            RoundedRectangle(cornerRadius: Theme.cornerRadius).frame(height: 220)
            RoundedRectangle(cornerRadius: 4).frame(width: 200, height: 12)
        }
        .foregroundStyle(Color.grayTastys.opacity(0.2))
        .overlay {
            LinearGradient(colors: [.clear, .white.opacity(0.6), .clear], startPoint: .leading, endPoint: .trailing)
                .offset(x: phase * 300)
        }
        .clipped()
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = 1 }
        }
        .accessibilityHidden(true)
    }
}
