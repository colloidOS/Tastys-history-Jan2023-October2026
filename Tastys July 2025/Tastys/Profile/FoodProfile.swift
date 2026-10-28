//
//  FoodProfile.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/11/2024.
//

import SwiftUI

enum FoodProfile: String, CaseIterable, Identifiable {
    case adventurous, bigEater, lightEater, picky, spicy, veggies

    var id: String { rawValue }

    var title: String {
        switch self {
        case .adventurous: return "Adventurous"
        case .bigEater: return "Big Eater"
        case .lightEater: return "Light Eater"
        case .picky: return "Picky"
        case .spicy: return "Spice Lover"
        case .veggies: return "Veggies"
        }
    }

    var imageName: String {
        switch self {
        case .adventurous: return "Adventorous"
        case .bigEater: return "Big Eater"
        case .lightEater: return "Light Eater"
        case .picky: return "picky"
        case .spicy: return "Spicy"
        case .veggies: return "Veggies"
        }
    }

    var color: Color { Color(self == .adventurous ? "adventorous" : rawValue) }
}

struct FoodProfileBadge: View {
    let profile: FoodProfile

    var body: some View {
        HStack(spacing: 4) {
            Image(profile.imageName)
                .resizable()
                .frame(width: 16, height: 16)
            Text(profile.title)
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(profile.color.opacity(0.2), in: Capsule())
    }
}
