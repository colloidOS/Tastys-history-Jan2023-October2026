//
//  Reaction.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/03/2024.
//

import Foundation

enum Reaction: String, CaseIterable, Identifiable {
    case fire, chefsKiss, solid, meh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fire: return "Fire"
        case .chefsKiss: return "Chef's Kiss"
        case .solid: return "Solid"
        case .meh: return "Meh"
        }
    }

    var iconName: String {
        switch self {
        case .fire: return "FireIcon"
        case .chefsKiss: return "ChefsKissIcon"
        case .solid: return "SolidIcon"
        case .meh: return "MehIcon"
        }
    }

    var score: Double {
        switch self {
        case .fire: return 9.5
        case .chefsKiss: return 8.0
        case .solid: return 7.0
        case .meh: return 5.0
        }
    }
}
