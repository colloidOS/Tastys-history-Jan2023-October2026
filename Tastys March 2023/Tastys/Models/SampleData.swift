//
//  SampleData.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 20/02/2023.
//

import Foundation

enum SampleData {
    static let restaurants: [Restaurant] = [
        Restaurant(
            name: "Smokehouse 54",
            cuisine: "Barbeque",
            imageName: "pizzaImage",
            rating: 4.6,
            address: "12 Admiralty Way, Lekki"
        ),
        Restaurant(
            name: "Slice House",
            cuisine: "Pizza",
            imageName: "pizzaImage",
            rating: 4.3,
            address: "4 Ozumba Mbadiwe Ave, Victoria Island"
        ),
        Restaurant(
            name: "Kobe Grill",
            cuisine: "Japanese",
            imageName: "dishImage",
            rating: 4.8,
            address: "27 Bourdillon Rd, Ikoyi"
        ),
        Restaurant(
            name: "Green Bowl",
            cuisine: "Mediterranean",
            imageName: "defaultFood",
            rating: 4.1,
            address: "9 Adeola Odeku St, Victoria Island"
        )
    ]
}
