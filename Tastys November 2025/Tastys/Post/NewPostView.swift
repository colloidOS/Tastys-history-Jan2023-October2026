//
//  NewPostView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 11/07/2025.
//

import SwiftUI
import PhotosUI
import Supabase

struct NewPostView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var restaurant: Restaurant?
    @State private var dish: Dish?
    @State private var reaction: Reaction = .solid
    @State private var caption = ""
    @State private var photo: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isPosting = false

    var body: some View {
        NavigationStack {
            Form {
                Picker("Restaurant", selection: $restaurant) {
                    Text("Choose").tag(Restaurant?.none)
                    ForEach(viewModel.restaurants) { Text($0.name).tag(Restaurant?.some($0)) }
                }
                if let restaurant {
                    Picker("Dish", selection: $dish) {
                        Text("Choose").tag(Dish?.none)
                        ForEach(restaurant.dishes) { Text($0.name).tag(Dish?.some($0)) }
                    }
                }
                Picker("Rating", selection: $reaction) {
                    ForEach(Reaction.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                TextField("Say something", text: $caption, axis: .vertical)

                PhotosPicker(selection: $photo, matching: .images) {
                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image).resizable().scaledToFill().frame(height: 180).clipped()
                    } else {
                        Label("Add photo", systemImage: "camera")
                    }
                }
            }
            .navigationTitle("New post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") { Task { await post() } }
                        .disabled(dish == nil || isPosting)
                }
            }
            .onChange(of: photo) { _, item in
                Task { imageData = try? await item?.loadTransferable(type: Data.self) }
            }
        }
    }

    private func post() async {
        guard let restaurant, let dish else { return }
        isPosting = true
        defer { isPosting = false }
        var imageURL: String?
        if let imageData {
            let path = "posts/\(UUID().uuidString).jpg"
            _ = try? await supabase.storage.from("post-images")
                .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            imageURL = try? supabase.storage.from("post-images").getPublicURL(path: path).absoluteString
        }
        struct NewPost: Encodable {
            let restaurant: String, dish: String, reaction: String, caption: String, image_url: String?
        }
        _ = try? await supabase.from("feed_posts").insert(
            NewPost(restaurant: restaurant.name, dish: dish.name, reaction: reaction.rawValue,
                    caption: caption, image_url: imageURL)
        ).execute()
        await viewModel.load()
        dismiss()
    }
}
