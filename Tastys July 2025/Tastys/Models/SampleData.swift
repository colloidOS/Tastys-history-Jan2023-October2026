//
//  SampleData.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 20/02/2023.
//

import Foundation

enum SampleData {
    static let cuisines = ["Barbeque", "Pizza", "Japanese", "Mediterranean", "Mexican", "Korean"]

    static let restaurants: [Restaurant] = [
        Restaurant(
            id: "r1",
            name: "Smokehouse 54",
            cuisine: "Barbeque",
            imageName: "pizzaImage",
            rating: 4.6,
            address: "12 Admiralty Way, Lekki",
            dishes: [
                Dish(id: "r1d1", name: "Suya Platter", price: 3500, imageName: "dishImage", averageRating: 4.7, ratingsCount: 182),
                Dish(id: "r1d2", name: "Smoked Ribs", price: 9200, imageName: "defaultFood", averageRating: 4.4, ratingsCount: 96)
            ],
            latitude: 6.4474,
            longitude: 3.4720,
            diets: [.halal]
        ),
        Restaurant(
            id: "r2",
            name: "Slice House",
            cuisine: "Pizza",
            imageName: "pizzaImage",
            rating: 4.3,
            address: "4 Ozumba Mbadiwe Ave, Victoria Island",
            dishes: [
                Dish(id: "r2d1", name: "Margherita", price: 7000, imageName: "pizzaImage", averageRating: 4.2, ratingsCount: 140),
                Dish(id: "r2d2", name: "Pepperoni Feast", price: 9000, imageName: "pizzaImage", averageRating: 4.5, ratingsCount: 211)
            ],
            latitude: 6.4302,
            longitude: 3.4216,
            diets: [.vegetarian]
        ),
        Restaurant(
            id: "r3",
            name: "Kobe Grill",
            cuisine: "Japanese",
            imageName: "dishImage",
            rating: 4.8,
            address: "27 Bourdillon Rd, Ikoyi",
            dishes: [
                Dish(id: "r3d1", name: "Salmon Nigiri", price: 8500, imageName: "dishImage", averageRating: 4.9, ratingsCount: 77),
                Dish(id: "r3d2", name: "Chicken Katsu", price: 6500, imageName: "defaultFood", averageRating: 4.6, ratingsCount: 120)
            ],
            latitude: 6.4549,
            longitude: 3.4335,
            diets: [.glutenFree]
        ),
        Restaurant(
            id: "r4",
            name: "Green Bowl",
            cuisine: "Mediterranean",
            imageName: "defaultFood",
            rating: 4.1,
            address: "9 Adeola Odeku St, Victoria Island",
            dishes: [
                Dish(id: "r4d1", name: "Falafel Wrap", price: 4000, imageName: "defaultFood", averageRating: 4.0, ratingsCount: 58),
                Dish(id: "r4d2", name: "Greek Salad", price: 3800, imageName: "defaultFood", averageRating: 4.2, ratingsCount: 64)
            ],
            latitude: 6.4298,
            longitude: 3.4180,
            diets: [.vegan, .vegetarian, .dairyFree]
        ),
        Restaurant(
            id: "r5",
            name: "Taco Libre",
            cuisine: "Mexican",
            imageName: "defaultFood",
            rating: 4.4,
            address: "15 Awolowo Rd, Ikoyi",
            dishes: [
                Dish(id: "r5d1", name: "Birria Tacos", price: 6000, imageName: "dishImage", averageRating: 4.7, ratingsCount: 150),
                Dish(id: "r5d2", name: "Elote", price: 2500, imageName: "defaultFood", averageRating: 4.1, ratingsCount: 41)
            ],
            latitude: 6.4466,
            longitude: 3.4251,
            diets: [.glutenFree]
        ),
        Restaurant(
            id: "r6",
            name: "Seoul Food",
            cuisine: "Korean",
            imageName: "dishImage",
            rating: 4.5,
            address: "3 Akin Adesola St, Victoria Island",
            dishes: [
                Dish(id: "r6d1", name: "Bibimbap", price: 5500, imageName: "dishImage", averageRating: 4.6, ratingsCount: 88),
                Dish(id: "r6d2", name: "Korean Fried Chicken", price: 7000, imageName: "dishImage", averageRating: 4.8, ratingsCount: 132)
            ],
            latitude: 6.4315,
            longitude: 3.4229,
            diets: [.halal]
        )
    ]

    static let feed: [FeedPost] = [
        FeedPost(author: "ada", avatar: "dp1", restaurant: "Smokehouse 54", dish: "Suya Platter",
                 reaction: .chefsKiss, caption: "Proper suya spice. Worth the queue.", imageName: "feedImage", likes: 24, comments: 6),
        FeedPost(author: "tobi", avatar: "dp2", restaurant: "Kobe Grill", dish: "Salmon Nigiri",
                 reaction: .fire, caption: "Freshest fish in Ikoyi.", imageName: "dishImage", likes: 41, comments: 9),
        FeedPost(author: "zainab", avatar: "dp3", restaurant: "Slice House", dish: "Pepperoni Feast",
                 reaction: .solid, caption: "Good crust, a bit too salty.", imageName: "pizzaImage", likes: 7, comments: 2)
    ]
}
