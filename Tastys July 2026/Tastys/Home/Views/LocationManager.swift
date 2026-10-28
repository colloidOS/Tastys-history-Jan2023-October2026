//
//  LocationManager.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/01/2026.
//

import SwiftUI
import CoreLocation
import MapKit


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var address: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            startUpdating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        location = loc
        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, error in
            if let place = placemarks?.first {
                self?.address = "\(place.thoroughfare ?? "") \(place.locality ?? "")".trimmingCharacters(in: .whitespaces)
                if self?.address?.isEmpty == true {
                    self?.address = "New York"
                }
            }
        }

        Task {
            await self.uploadLocationToSupabase(loc)
        }
    }

    
    
    private struct UpsertLocationParams: Encodable {
        let p_lat: Double
        let p_lng: Double
        let p_timezone: String
    }

    private func uploadLocationToSupabase(_ location: CLLocation) async {
        guard (try? await supabase.auth.session) != nil else { return } // must be logged in
        let tz = TimeZone.current.identifier

        let params = UpsertLocationParams(
            p_lat: location.coordinate.latitude,
            p_lng: location.coordinate.longitude,
            p_timezone: tz
        )

        do {
            try await supabase
                .rpc("upsert_user_location", params: params)
                .execute()
        } catch {
            print("Failed to upload location: \(error)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
