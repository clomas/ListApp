//
//  PerformanceTests.swift
//  ListAppTests
//
//  Created by Clint Thomas on 9/5/21.
//

import XCTest
@testable import ListApp

class PerformanceTests: BaseTestCase {

	func testAwardCalculationPerformance() throws {

		// Create a significant amount of test data
		for _ in 1...100 {
			try dataController.createSampleData()
		}

		// Simulate lots of awards to check
		let awards = Array(repeating: Award.allAwards, count: 25).joined()
		XCTAssertEqual(awards.count, 500, "This checks the awards count, change this if you add awards.")
		measure {
			_ = awards.filter(dataController.hasEarned)
		}
	}
}
