//
//  DevelopmentTests.swift
//  ListAppTests
//
//  Created by Clint Thomas on 30/3/21.
//

import XCTest
import CoreData
@testable import ListApp

class DevelopmentTests: BaseTestCase {

	func testSampleDataCreationWorks() throws {
		try dataController.createSampleData()
		XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects")
		XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items")
	}

	func testDeleteAllClearsEverything() throws {
		try dataController.createSampleData()
		dataController.deleteAll()
		XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "deleteAll() should leave 0 projects")
		XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "deleteAll() should leave 0 items")
	}

	func testExampleProjectIsClosed() {
		let project = Project.example
		XCTAssertTrue(project.closed, "The project should be closed.")
	}

	func testExampleItemIsHighPriority() {
		let item = Item.example
		XCTAssertEqual(item.priority, 3, "The item priority should be high")
	}
}// using preview here rather than
