//
//  RateDishView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 18/03/2024.
//

import SwiftUI

struct RateDishView: View {
    let dish: Dish
    let restaurant: Restaurant
    @EnvironmentObject private var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Reaction?

    var body: some View {
        VStack(spacing: 20) {
            Text("How was the \(dish.name)?")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            Text(restaurant.name)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(Reaction.allCases) { reaction in
                    Button {
                        selection = reaction
                    } label: {
                        VStack {
                            Image(reaction.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                            Text(reaction.title)
                                .font(.caption)
                        }
                        .padding(8)
                        .background(selection == reaction ? Color.rateTastys.opacity(0.2) : .clear,
                                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                if let selection { viewModel.rate(dish, reaction: selection) }
                dismiss()
            } label: {
                Text("Submit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selection == nil)
        }
        .padding(24)
    }
}
