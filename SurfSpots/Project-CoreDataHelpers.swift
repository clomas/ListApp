//
//  Project-CoreDataHelpers.swift
//  SurfSpots
//
//  Created by Clint Thomas on 18/2/21.
//

import Foundation

extension Project {
	var projectTitle: String {
		title ?? "New Project"
	}
	var projectDetail: String {
		detail ?? ""
	}
	var projectColor: String {
		colour ?? "Light Blue"
	}

	static var example: Project {
		let controller = DataController(inMemory: true)
		let viewContext = controller.container.viewContext
		let project = Project(context: viewContext)
		project.title = "Example Project"
		project.detail = "This is an example project"
		project.closed = true
		project.creationDate = Date()

		return project
	}

	var projectItems: [Item] {
		let itemsArray = items?.allObjects as? [Item] ?? []
		return itemsArray.sorted { first, second in
			if first.completed == true {
				return true
			} else if first.completed == true {
				if second.completed == false {
					return false
				}
			}
			if first.priority > second.priority {
				return true
			} else if first.priority < second.priority {
				return false
			}
			return first.itemCreationDate < second.itemCreationDate
		}

	}

	var completionAmount: Double {
		let originalItems = items?.allObjects as? [Item] ?? []
		guard originalItems.isEmpty == false else { return 0 }

		// look for any items set to true (completed - bool)
		let completedItems = originalItems.filter(\.completed)
		return Double(completedItems.count) / Double(originalItems.count)
	}
}
