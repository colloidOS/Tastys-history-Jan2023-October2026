//
//  APIClient.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 07/01/2024.
//

import Foundation

protocol APIClient {
    func fetchRestaurants() async throws -> [Restaurant]
}

enum APIError: LocalizedError {
    case offline

    var errorDescription: String? {
        switch self {
        case .offline: return "You appear to be offline."
        }
    }
}

struct MockAPIClient: APIClient {
    var shouldFail = false
    var delay: UInt64 = 400_000_000

    func fetchRestaurants() async throws -> [Restaurant] {
        try await Task.sleep(nanoseconds: delay)
        if shouldFail { throw APIError.offline }
        return SampleData.restaurants
    }
}
