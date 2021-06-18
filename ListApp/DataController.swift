//
//  DataController.swift
//  SurfSpots
//
//  Created by Clint Thomas on 17/2/21.
//

import SwiftUI
import CoreData
import CoreSpotlight
import UserNotifications

/// An environment singleton responsible for managing our Core Data stack, including handling saving
/// counting fetch requests, tracking awards and dealing with sample data
class DataController: ObservableObject {
	/// The lone CloudKit container used to store all of our data
	let container: NSPersistentCloudKitContainer

	/// Initialised a data controller either in memory (for temporary use such as testing and previewing)
	/// or on permanent storage (for use in regular app runs).
	///
	/// Default to permanent storage
	/// - Parameter inMemory: Whether to store this data in temporary memory of not.
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

		// for testing and preview - create a temporary
		// in memory database by writing to /dev/null
		// data will be destroyed after the app closes
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}

		container.loadPersistentStores { _, error in
			if let error = error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}

			#if DEBUG
			if CommandLine.arguments.contains("enable-testing") {
				self.deleteAll()

				// if testing UI disable animations.
				UIView.setAnimationsEnabled(false)
			}
			#endif
		}
	}

	static var preview: DataController = {
		let dataController = DataController(inMemory: true)
		let viewContext = dataController.container.viewContext
		do {
			try dataController.createSampleData()
		} catch {
			fatalError("Fatal error creating preview: \(error.localizedDescription)")
		}
		return dataController
	}()

	// Creating a model to remove ambiguity when testing, duplicate sample data was being created.
	static let model: NSManagedObjectModel = {
		guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
			fatalError("Failed to locate model file.")
		}

		guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
			fatalError("Failed to load model file.")
		}

		return managedObjectModel
	}()

	/// Creates example projects and items to make manual testing easier
	/// - Throws: An NSError sent from calling save() on the NSManagedObjectContext
	func createSampleData() throws {
		let viewContext = container.viewContext

		for projectIndex in 1...5 {
			let project = Project(context: viewContext)
			project.title = "Project\(projectIndex)"
			project.items = []
			project.creationDate = Date()
			project.closed = Bool.random()

			for itemIndex in 1...10 {
				let item = Item(context: viewContext)
				item.title = "Item \(itemIndex)"
				item.creationDate = Date()
				item.completed = Bool.random()
				item.project = project
				item.priority = Int16.random(in: 1...5)
			}
		}
		try viewContext.save()
	}

	/// Saves our Core Data context iff there are changed. This silently ignores
	/// any errors caused by saving, but this should be fine because our attributes
	/// are optional.
	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}

	func delete(_ object: NSManagedObject) {
		let id = object.objectID.uriRepresentation().absoluteString
		if object is Item {
			CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
		} else if object is Project {
			CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
		}
		container.viewContext.delete(object)
	}

	func deleteAll() {
		let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
		let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
		_ = try? container.viewContext.execute(batchDeleteRequest1)

		let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
		let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
		_ = try? container.viewContext.execute(batchDeleteRequest2)
	}

	func count <T>(for fetchRequest: NSFetchRequest<T>) -> Int {
		(try? container.viewContext.count(for: fetchRequest)) ?? 0
	}

	func hasEarned(award: Award) -> Bool {
		switch award.criterion {
		case "items":
			// returns true if user added a certain number of items
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
		case "complete":
			// returns true if they completed a certain number of times
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			fetchRequest.predicate = NSPredicate(format: "completed = true")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
		default:
			// an unknown award criterion - this should never be allowed
			// fatalError("Unkown award critereo: \(award.criterion)")
			return false
		}
	}

	// Add new items to spotlight
	func update(_ item: Item) {
		let itemID = item.objectID.uriRepresentation().absoluteString
		let projectID = item.project?.objectID.uriRepresentation().absoluteString
		let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
		attributeSet.title = item.itemTitle
		attributeSet.contentDescription = item.detail

		let searchableItem = CSSearchableItem(
			uniqueIdentifier: itemID,
			domainIdentifier: projectID,
			attributeSet: attributeSet
		)
		CSSearchableIndex.default().indexSearchableItems([searchableItem], completionHandler: nil)
		save()
	}

	func item(with uniqueIdentifier: String) -> Item? {
		guard let url = URL(string: uniqueIdentifier) else {
			return nil
		}
		guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
			return nil
		}
		return try? container.viewContext.existingObject(with: id) as? Item
	}

	func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {

	}

	func removeReminders(for project: Project) {
		let center = UNUserNotificationCenter.current()
		let id = project.objectID.uriRepresentation().absoluteString

		center.removePendingNotificationRequests(withIdentifiers: [id])
	}

	private func requestNotification(completion: @escaping (Bool) -> Void) {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
			completion(granted)
		}
	}

	private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
		let content = UNMutableNotificationContent()
		content.title = project.projectTitle
		content.sound = .default

		if let projectDetail = project.detail {
			content.subtitle =  projectDetail
		}


	}
}