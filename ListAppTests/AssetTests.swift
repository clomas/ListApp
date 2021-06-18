//
//  AssetTests.swift
//  ListAppTests
//
//  Created by Clint Thomas on 25/3/21.
//

import XCTest
@testable import ListApp

class AssetTests: XCTestCase {

	func testColorsExist() {
		for color in Project.colors {
			XCTAssertNotNil(UIColor(named: color), "Failed to load color - \(color) from assets")
		}
	}

	func testJSONLoadsCorrectly() {
		XCTAssertFalse(Award.allAwards.isEmpty, "JSON failed to load awards from local JSON")
	}
}
