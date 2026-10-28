//
//  FavoritesStoreTests.swift
//  TastysTests
//
//  Created by Nnagoziem Collins Okegbe on 08/12/2023.
//

import XCTest
@testable import Tastys

@MainActor
final class FavoritesStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        defaults = UserDefaults(suiteName: #file)
        defaults.removePersistentDomain(forName: #file)
    }

    func testToggleAddsAndRemoves() {
        let store = FavoritesStore(defaults: defaults)
        let restaurant = SampleData.restaurants[0]
        store.toggle(restaurant)
        XCTAssertTrue(store.contains(restaurant))
        store.toggle(restaurant)
        XCTAssertFalse(store.contains(restaurant))
    }

    func testPersistsAcrossInstances() {
        let restaurant = SampleData.restaurants[1]
        FavoritesStore(defaults: defaults).toggle(restaurant)
        XCTAssertTrue(FavoritesStore(defaults: defaults).contains(restaurant))
    }
}
