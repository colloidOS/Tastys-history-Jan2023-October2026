//
//  FeedPost.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 24/07/2024.
//

import Foundation

struct FeedPost: Identifiable, Hashable {
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
}
