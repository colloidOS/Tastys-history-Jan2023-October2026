//
//  Restaurant.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 17/02/2023.
//

import Foundation
import CoreLocation

struct Restaurant: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var cuisine: String
    var imageName: String
    var rating: Double
    var address: String
    var dishes: [Dish]
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func distance(from location: CLLocation?) -> CLLocationDistance? {
        guard let location else { return nil }
        return location.distance(from: CLLocation(latitude: latitude, longitude: longitude))
    }
}

struct Dish: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var imageName: String
    var averageRating: Double
    var ratingsCount: Int

    var formattedPrice: String {
        price.formatted(.currency(code: "NGN"))
    }
}
