//
//  SampleDataTests.swift
//  TastysTests
//
//  Created by Nnagoziem Collins Okegbe on 19/12/2023.
//

import XCTest
@testable import Tastys

final class SampleDataTests: XCTestCase {
    func testEveryRestaurantHasDishes() {
        for restaurant in SampleData.restaurants {
            XCTAssertFalse(restaurant.dishes.isEmpty, restaurant.name)
        }
    }

    func testRatingsAreInRange() {
        for restaurant in SampleData.restaurants {
            XCTAssert((0...5).contains(restaurant.rating))
        }
    }
}
