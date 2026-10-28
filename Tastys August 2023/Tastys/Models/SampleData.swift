//
//  SampleData.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 20/02/2023.
//

import Foundation

enum SampleData {
    static let cuisines = ["Barbeque", "Pizza", "Japanese", "Mediterranean", "Mexican"]

    static let restaurants: [Restaurant] = [
        Restaurant(
            name: "Smokehouse 54",
            cuisine: "Barbeque",
            imageName: "pizzaImage",
            rating: 4.6,
            address: "12 Admiralty Way, Lekki",
            dishes: [
                Dish(name: "Suya Platter", price: 3500, imageName: "dishImage", averageRating: 4.7, ratingsCount: 182),
                Dish(name: "Smoked Ribs", price: 9200, imageName: "defaultFood", averageRating: 4.4, ratingsCount: 96)
            ]
        ),
        Restaurant(
            name: "Slice House",
            cuisine: "Pizza",
            imageName: "pizzaImage",
            rating: 4.3,
            address: "4 Ozumba Mbadiwe Ave, Victoria Island",
            dishes: [
                Dish(name: "Margherita", price: 7000, imageName: "pizzaImage", averageRating: 4.2, ratingsCount: 140),
                Dish(name: "Pepperoni Feast", price: 9000, imageName: "pizzaImage", averageRating: 4.5, ratingsCount: 211)
            ]
        ),
        Restaurant(
            name: "Kobe Grill",
            cuisine: "Japanese",
            imageName: "dishImage",
            rating: 4.8,
            address: "27 Bourdillon Rd, Ikoyi",
            dishes: [
                Dish(name: "Salmon Nigiri", price: 8500, imageName: "dishImage", averageRating: 4.9, ratingsCount: 77),
                Dish(name: "Chicken Katsu", price: 6500, imageName: "defaultFood", averageRating: 4.6, ratingsCount: 120)
            ]
        ),
        Restaurant(
            name: "Green Bowl",
            cuisine: "Mediterranean",
            imageName: "defaultFood",
            rating: 4.1,
            address: "9 Adeola Odeku St, Victoria Island",
            dishes: [
                Dish(name: "Falafel Wrap", price: 4000, imageName: "defaultFood", averageRating: 4.0, ratingsCount: 58),
                Dish(name: "Greek Salad", price: 3800, imageName: "defaultFood", averageRating: 4.2, ratingsCount: 64)
            ]
        ),
        Restaurant(
            name: "Taco Libre",
            cuisine: "Mexican",
            imageName: "defaultFood",
            rating: 4.4,
            address: "15 Awolowo Rd, Ikoyi",
            dishes: [
                Dish(name: "Birria Tacos", price: 6000, imageName: "dishImage", averageRating: 4.7, ratingsCount: 150),
                Dish(name: "Elote", price: 2500, imageName: "defaultFood", averageRating: 4.1, ratingsCount: 41)
            ]
        )
    ]
}
