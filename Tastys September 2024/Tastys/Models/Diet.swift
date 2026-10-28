//
//  Diet.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 12/05/2024.
//

import Foundation

enum Diet: String, CaseIterable, Identifiable, Hashable {
    case vegan, vegetarian, halal, keto, paleo, glutenFree, dairyFree

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .halal: return "Halal"
        case .keto: return "Keto"
        case .paleo: return "Paleo"
        case .glutenFree: return "Gluten-free"
        case .dairyFree: return "Dairy Free"
        }
    }

    /// Asset name inside Assets.xcassets/Diet
    var iconName: String {
        self == .dairyFree ? "Diary Free" : title
    }
}
