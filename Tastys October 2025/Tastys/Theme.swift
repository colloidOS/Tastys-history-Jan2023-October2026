//
//  Theme.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 21/06/2023.
//

import SwiftUI

enum Theme {
    static let cornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16
    static let titleFont: Font = .system(.headline, design: .rounded)
    static let captionFont: Font = .system(.footnote, design: .rounded)
}

extension Color {
    static let tastysRed = Color("tastysRed")
    static let grayTastys = Color("grayTastys")
    static let greenTastys = Color("greenTastys")
    static let plumTastys = Color("plumTastys")
    static let ashTastys = Color("ashTastys")
    static let homeHeader = Color("homeHeader")
    static let rateTastys = Color("rateTastys")
    static let plateWhite = Color("plateWhite")
    static let firstPlaceTastys = Color("firstPlaceTastys")
    static let thirdPlaceTastys = Color("thirdPlaceTastys")
    static let darkRedTastys = Color("darkRedTastys")
    static let blackWaitlist = Color("blackWaitlist")
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.cardPadding)
            .background(.background, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardBackground()) }
}
