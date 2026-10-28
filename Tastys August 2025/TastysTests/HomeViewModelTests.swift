//
//  HomeViewModelTests.swift
//  TastysTests
//
//  Created by Nnagoziem Collins Okegbe on 17/12/2024.
//

import XCTest
@testable import Tastys

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadUsesClient() async {
        let viewModel = HomeViewModel(client: MockAPIClient())
        await viewModel.load()
        XCTAssertEqual(viewModel.restaurants.count, SampleData.restaurants.count)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadSurfacesErrors() async {
        let viewModel = HomeViewModel(client: MockAPIClient(shouldFail: true))
        await viewModel.load()
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
