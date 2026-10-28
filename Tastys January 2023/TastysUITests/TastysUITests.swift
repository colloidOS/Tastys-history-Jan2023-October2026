//
//  TastysUITests.swift
//  TastysUITests
//
//  Created by Nnagoziem Collins Okegbe on 14/01/2023.
//

import XCTest

final class TastysUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Tastys"].exists)
    }
}
