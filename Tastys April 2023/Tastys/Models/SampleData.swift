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
            address: "12 Admiralty Way, Lekki",
            dishes: [
                Dish(name: "Suya Platter", price: 3500, imageName: "dishImage"),
                Dish(name: "Smoked Ribs", price: 9200, imageName: "defaultFood")
            ]
        ),
        Restaurant(
            name: "Slice House",
            cuisine: "Pizza",
            imageName: "pizzaImage",
            rating: 4.3,
            address: "4 Ozumba Mbadiwe Ave, Victoria Island",
            dishes: [
                Dish(name: "Margherita", price: 7000, imageName: "pizzaImage"),
                Dish(name: "Pepperoni Feast", price: 9000, imageName: "pizzaImage")
            ]
        ),
        Restaurant(
            name: "Kobe Grill",
            cuisine: "Japanese",
            imageName: "dishImage",
            rating: 4.8,
            address: "27 Bourdillon Rd, Ikoyi",
            dishes: [
                Dish(name: "Salmon Nigiri", price: 8500, imageName: "dishImage"),
                Dish(name: "Chicken Katsu", price: 6500, imageName: "defaultFood")
            ]
        ),
        Restaurant(
            name: "Green Bowl",
            cuisine: "Mediterranean",
            imageName: "defaultFood",
            rating: 4.1,
            address: "9 Adeola Odeku St, Victoria Island",
            dishes: [
                Dish(name: "Falafel Wrap", price: 4000, imageName: "defaultFood"),
                Dish(name: "Greek Salad", price: 3800, imageName: "defaultFood")
            ]
        )
    ]
}
