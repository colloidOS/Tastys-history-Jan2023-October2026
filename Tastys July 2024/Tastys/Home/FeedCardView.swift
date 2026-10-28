//
//  FeedCardView.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 09/07/2024.
//

import SwiftUI

struct FeedCardView: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(post.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("@\(post.author)").font(.subheadline.bold())
                    Text(post.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(post.reaction.iconName)
                    .resizable()
                    .frame(width: 28, height: 28)
            }

            Image(post.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

            Text("\(post.dish) · \(post.restaurant)")
                .font(Theme.captionFont.bold())
            if !post.caption.isEmpty {
                Text(post.caption).font(Theme.captionFont)
            }
        }
        .cardStyle()
    }
}
