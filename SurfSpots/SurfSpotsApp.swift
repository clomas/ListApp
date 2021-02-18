//
//  SurfSpotsApp.swift
//  SurfSpots
//
//  Created by Clint Thomas on 17/2/21.
//

import SwiftUI

@main
struct SurfSpotsApp: App {

	// Keep alive while app is running
	@StateObject var dataController: DataController

	init() {
		let dataController = DataController()
		_dataController = StateObject(wrappedValue: dataController)
	}

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, dataController.container.viewContext)
				.environmentObject(dataController)
        }
    }
}
