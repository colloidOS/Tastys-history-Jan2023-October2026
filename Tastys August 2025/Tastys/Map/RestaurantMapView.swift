//
//  RestaurantMapView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 23/08/2025.
//

import SwiftUI
import MapKit

struct RestaurantMapView: View {
    let restaurants: [Restaurant]
    @State private var position: MapCameraPosition = .userLocation(fallback: .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 6.4400, longitude: 3.4300),
                           span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))))
    @State private var selected: Restaurant?

    var body: some View {
        Map(position: $position, selection: $selected) {
            UserAnnotation()
            ForEach(restaurants) { restaurant in
                Marker(restaurant.name, systemImage: "fork.knife", coordinate: restaurant.coordinate)
                    .tint(.tastysRed)
                    .tag(restaurant)
            }
        }
        .mapControls { MapUserLocationButton() }
        .safeAreaInset(edge: .bottom) {
            if let selected {
                RestaurantRowView(restaurant: selected)
                    .cardStyle()
                    .padding()
            }
        }
        .navigationTitle("Map")
    }
}
