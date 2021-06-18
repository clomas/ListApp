//
//  ListAppUITests.swift
//  ListAppUITests
//
//  Created by Clint Thomas on 9/5/21.
//

import XCTest

class ListAppUITests: XCTestCase {
	var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

		app = XCUIApplication()
		app.launchArguments = ["enable-testing"]
		app.launch()
    }

    func testAppHas4Tabs() throws {
		XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }

	func testOpenTabAddsItems() {
		app.buttons["Open"].tap()
		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

		for tapCount in 1...5 {
			// native button named "app"
			app.buttons["add"].tap()
			XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) list row(s) initially")
		}
	}

	func testAddingItemInsertsRows() {
		app.buttons["Open"].tap()
		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

		app.buttons["add"].tap()
		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 row after tapping add.")

		app.buttons["Add New Item"].tap()
		XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding new item.")
	}

	func testEditingProjectUpdatesCorrectly() {
		app.buttons["Open"].tap()
		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

		app.buttons["add"].tap()
		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 row after tapping add.")

		app.buttons["NEW PROJECT"].tap()
		app.textFields["Project name"].tap()

		app.keys["space"].tap()
		app.keys["more"].tap() // change to special characters/numbers
		app.keys["2"].tap()
		app.buttons["Return"].tap()

		app.buttons["Open Projects"].tap()
		XCTAssertTrue(app.buttons["NEW PROJECT 2"].exists, "The new project name should be visible in the list")
	}

	func testEditingItemUpdatesCorrectly() {
		// Go to open projects and open 1 project and 1 item
		testAddingItemInsertsRows()

		app.buttons["New Item"].tap()
		app.textFields["Item Name"].tap()

		app.keys["space"].tap()
		app.keys["more"].tap() // change to special characters/numbers
		app.keys["2"].tap()
		app.buttons["Return"].tap()

		app.buttons["Open Projects"].tap()
		XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item should be visible in the list")
	}

	func testAllAwardsShowLockedAlert() {
		app.buttons["Awards"].tap()

		for award in app.scrollViews.buttons.allElementsBoundByIndex {
			award.tap()
			XCTAssertTrue(app.alerts["Locked"].exists, "There should be a locked alert showing for awards")
			app.buttons["OK"].tap()
		}
	}
}
