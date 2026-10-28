//
//  ImageCacheManager.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 18/09/2026.
//

import UIKit
import SwiftUI

/// Single shared cache for downloaded images + the dominant color computed from them.
/// - Avoids re-downloading the same URL every time a card view is re-created
///   (e.g. switching tabs, scrolling a List, popping a NavigationLink).
/// - Avoids re-downloading the SAME image a second time just to sample its color:
///   `image(for:)` is the only network call; color is derived from the UIImage
///   it returns.
/// - Coalesces concurrent requests for the same URL into a single network call.
actor ImageCacheManager {
    static let shared = ImageCacheManager()

    private let memoryCache = NSCache<NSString, UIImage>()
    private var colorCache: [String: Color] = [:]
    private var inFlightTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {
        memoryCache.countLimit = 300
        memoryCache.totalCostLimit = 150 * 1024 * 1024 // ~150MB of decoded pixel data
    }

    /// Synchronous-from-the-actor cache lookup. Returns nil on a miss (does not fetch).
    func cachedImage(for key: String) -> UIImage? {
        memoryCache.object(forKey: key as NSString)
    }

    func cachedColor(for key: String) -> Color? {
        colorCache[key]
    }

    func setColor(_ color: Color, for key: String) {
        colorCache[key] = color
    }

    /// Returns the cached image if present, otherwise downloads it once, caches it,
    /// and returns it. Concurrent callers for the same key await the same download.
    func image(for urlString: String) async -> UIImage? {
        if let cached = memoryCache.object(forKey: urlString as NSString) {
            return cached
        }

        if let existing = inFlightTasks[urlString] {
            return await existing.value
        }

        let cache = memoryCache
        let task = Task<UIImage?, Never> {
            guard let url = URL(string: urlString) else { return nil }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else { return nil }
                cache.setObject(image, forKey: urlString as NSString, cost: data.count)
                return image
            } catch {
                return nil
            }
        }

        inFlightTasks[urlString] = task
        let result = await task.value
        inFlightTasks[urlString] = nil
        return result
    }
}
