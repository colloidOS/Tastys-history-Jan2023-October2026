//
//  YourPlateView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 14/04/2024.
//

import SwiftUI

struct YourPlateView: View {
    @EnvironmentObject private var plates: PlateStore
    private let plateImages = ["plate1", "plate2", "plate3"]

    var body: some View {
        List {
            ForEach(Array(plates.items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 12) {
                    Image(plateImages[index % plateImages.count])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(item.dishName).font(.headline)
                        Text(item.restaurantName).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: plates.remove)
        }
        .overlay {
            if plates.items.isEmpty {
                ContentUnavailableView("Your plate is empty", image: "forkIcon",
                                       description: Text("Swipe a dish and tap Add to plate."))
            }
        }
        .navigationTitle("Your Plate")
    }
}
