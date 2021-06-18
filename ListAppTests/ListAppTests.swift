//
//  ListAppTests.swift
//  ListAppTests
//
//  Created by Clint Thomas on 25/3/21.
//

import CoreData
import XCTest
@testable import ListApp

class BaseTestCase: XCTestCase {
	var dataController: DataController!
	var managedObjectContext: NSManagedObjectContext!

	override func setUpWithError() throws {
		dataController = DataController(inMemory: true)
		managedObjectContext = dataController.container.viewContext
	}

}
