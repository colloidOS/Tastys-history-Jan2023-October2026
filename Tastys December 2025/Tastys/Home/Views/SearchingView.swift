//
//  SearchingView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 13/12/2025.
//

import SwiftUI
import CoreLocation
import MapKit

struct SearchingView: View {
    @Binding var searchText: String
    @Binding var isShowing: Bool
    @AppStorage("userLocation") var userLocation: String = "New York"
    @StateObject private var locManager = LocationManager()
    @State private var searchResults: [MKMapItem] = []
    @EnvironmentObject var homeVM: HomeViewModel  // Inject HomeViewModel
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                HStack {
                    Text("Current")
                        .foregroundStyle(.black)
                        .opacity(0.4)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                    
                    Text(userLocation)
                        .foregroundStyle(.black)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                    
                    Image(systemName: "location.fill")
                        .foregroundStyle(.tastysRed)
                        .font(.system(size: 16))
                        .rotationEffect(Angle(degrees: -90))
                }
                .padding(.top, 16)
                .padding(.bottom, 5)
                
                ZStack {
                    Image("mapImage")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 74)
                        .clipShape(RoundedRectangle(cornerRadius: 27))
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white)
                            .opacity(0.7)
                            .font(.system(size: 17))
                        
                        ZStack(alignment: .leading) {
                            TextField("", text: $searchText)
                                .foregroundStyle(.white)
                                .font(.system(size: 15))
                                .focused($isTextFieldFocused)
                            
                            if searchText.isEmpty {
                                Text("search locations")
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 11)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 23)
                                .fill(.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                        }
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 19))
                    }
                    .padding(.horizontal, 22)
                }
                
                ScrollView {
                    ForEach(searchResults, id: \.self) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(formattedStreetAndState(from: item.placemark))
                                    .foregroundStyle(.black)
                                    .font(.system(size: 17))
                                    .fontWeight(.semibold)
                                
//                                Text(item.placemark.locality ?? "")
//                                    .foregroundStyle(.black)
//                                    .opacity(0.4)
//                                    .font(.system(size: 14))
//                                    .fontWeight(.medium)
                            }
                            Spacer()
                            
                            Circle()
                                .stroke(lineWidth: 0.5)
                                .frame(height: 16)
                                .padding(.trailing, 6)
                        }
                        .onTapGesture {
                            let displayName = formattedStreetAndState(from: item.placemark)
                            userLocation = displayName
                            let coord = item.placemark.coordinate
                            let locationString = "\(coord.longitude) \(coord.latitude)"  // Format for geography
                            Task {
                                await homeVM.updateLocation(longitude: coord.longitude, latitude: coord.latitude)
                                await homeVM.getTopRatedDishesNearUser()
                                await MainActor.run {
                                    isShowing = false
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.bottom, 2)
                .scrollDismissesKeyboard(.interactively)
                
                
            }
            .padding(.horizontal, 9)
            
            VStack {
                Spacer()
                
                ZStack {
                    LinearGradient(colors: [Color.clear, Color.white.opacity(0.5), Color.white.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 50)
                        .clipped()
                    
                    Button {
                        Haptics.slide()
                        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
                            locManager.requestAuthorization()
                        } else {
                            locManager.startUpdating()
                        }
                        if let coord = locManager.location?.coordinate {
                            let locationString = "\(coord.longitude) \(coord.latitude)"
                            print(locationString)
                            let displayName = locManager.address ?? "Current Location"
                            userLocation = displayName
                            Task {
                                await homeVM.updateLocation(longitude: coord.longitude, latitude: coord.latitude)
                                await MainActor.run {
                                    isShowing = false
                                }
                            }
                        } else {
                            print("Unable to get current location")
                            // Handle no location available
                            homeVM.showError("Unable to get current location")
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Use location")
                                .foregroundStyle(.white)
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                            .padding(.vertical, 8)
                            Spacer()
                            
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundStyle(.tastysRed)
                        }
                        
                    }
                    .padding(.horizontal, 60)
                    .padding(.vertical, 21)
                }
                
            }
            
            if homeVM.isUpdateLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .tastysRed))
                    .scaleEffect(1.5)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 50)
        .frame(maxHeight: 400)
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .shadow(color: .black.opacity(0.15), radius: 4)
        .onAppear{
            Haptics.prepare()
        }
        .onChange(of: searchText) { newValue in
            if newValue.isEmpty || newValue.count < 3 {
                searchResults = []
                return
            }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = newValue
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let response = response {
                    searchResults = response.mapItems
                }
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    func formattedStreetAndState(from placemark: MKPlacemark) -> String {
        let streetNumber = placemark.subThoroughfare ?? ""
        let streetName = placemark.thoroughfare ?? ""
        let street = "\(streetNumber) \(streetName)".trimmingCharacters(in: .whitespaces)

        let state = placemark.administrativeArea ?? ""
        let shortState = usStateAbbreviations[state] ?? state

        if street.isEmpty {
            return shortState
        }

        return "\(street), \(shortState)"
    }

}

#Preview {
    SearchingView(searchText: .constant(""), isShowing: .constant(true))
        .environmentObject(HomeViewModel())
}



let usStateAbbreviations: [String: String] = [
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Mississippi": "MS",
    "Missouri": "MO",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY",

    // Territories
    "District of Columbia": "DC",
    "American Samoa": "AS",
    "Guam": "GU",
    "Northern Mariana Islands": "MP",
    "Puerto Rico": "PR",
    "U.S. Virgin Islands": "VI"
]
