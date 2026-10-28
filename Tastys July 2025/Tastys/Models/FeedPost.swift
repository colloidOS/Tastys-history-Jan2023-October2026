//
//  FeedPost.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 24/07/2024.
//

import Foundation

struct FeedPost: Identifiable, Hashable, Codable {
    var id = UUID()
    var author: String
    var avatar: String
    var restaurant: String
    var dish: String
    var reaction: Reaction
    var caption: String
    var imageName: String
    var imageURL: URL? = nil
    var likes: Int = 0
    var comments: Int = 0
    var isLiked = false
    var createdAt = Date()

    enum CodingKeys: String, CodingKey {
        case id, author, avatar, restaurant, dish, reaction, caption, likes, comments
        case imageName = "image_name"
        case imageURL = "image_url"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        author = try c.decode(String.self, forKey: .author)
        avatar = try c.decodeIfPresent(String.self, forKey: .avatar) ?? "dp1"
        restaurant = try c.decode(String.self, forKey: .restaurant)
        dish = try c.decode(String.self, forKey: .dish)
        reaction = try c.decode(Reaction.self, forKey: .reaction)
        caption = try c.decodeIfPresent(String.self, forKey: .caption) ?? ""
        imageName = try c.decodeIfPresent(String.self, forKey: .imageName) ?? "defaultFood"
        imageURL = try c.decodeIfPresent(URL.self, forKey: .imageURL)
        likes = try c.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        comments = try c.decodeIfPresent(Int.self, forKey: .comments) ?? 0
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }

    init(author: String, avatar: String, restaurant: String, dish: String, reaction: Reaction,
         caption: String, imageName: String, likes: Int = 0, comments: Int = 0) {
        self.author = author; self.avatar = avatar; self.restaurant = restaurant; self.dish = dish
        self.reaction = reaction; self.caption = caption; self.imageName = imageName
        self.likes = likes; self.comments = comments
    }
}
