//
//  CachedAsyncImage.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 18/09/2026.
//

import SwiftUI

/// Drop-in replacement for `AsyncImage` that:
/// 1. Checks `ImageCacheManager` before touching the network, so re-appearing
///    views (tab switches, scroll recycling, nav pop) show instantly with no flicker.
/// 2. Hands the raw `UIImage` back via `onImageLoaded`, so callers (e.g. for
///    dominant-color extraction) don't need to download the image a second time.
///
/// `.task(id: urlString)` automatically cancels/restarts if the URL changes and
/// is cheap to re-run on view re-creation because the cache check is the first thing it does.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let urlString: String?
    var onImageLoaded: ((UIImage) -> Void)? = nil
    @ViewBuilder var content: (Image) -> Content
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: urlString) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let urlString, !urlString.isEmpty else { return }

        // Fast path: already in memory, no network hit at all.
        if let cached = await ImageCacheManager.shared.cachedImage(for: urlString) {
            uiImage = cached
            onImageLoaded?(cached)
            return
        }

        if let loaded = await ImageCacheManager.shared.image(for: urlString) {
            if !Task.isCancelled {
                uiImage = loaded
                onImageLoaded?(loaded)
            }
        }
    }
}
