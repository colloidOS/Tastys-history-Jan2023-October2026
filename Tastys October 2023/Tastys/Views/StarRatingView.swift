//
//  StarRatingView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 18/05/2023.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    var size: CGFloat = 14
    var maxRating = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: symbol(for: index))
                    .font(.system(size: size))
                    .foregroundStyle(Color.tastysRed)
            }
            Text(String(format: "%.1f", rating))
                .font(.system(size: size, weight: .semibold))
                .padding(.leading, 2)
        }
    }

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 1 { return "star.fill" }
        if value >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

#Preview {
    StarRatingView(rating: 3.5)
}
