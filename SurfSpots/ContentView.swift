//
//  ContentView.swift
//  SurfSpots
//
//  Created by Clint Thomas on 17/2/21.
//

import SwiftUI

struct ContentView: View {
	@SceneStorage("selectedView") var selectedView: String?

    var body: some View {
		TabView(selection: $selectedView) {

			HomeView()
				.tag(HomeView.tag)
				.tabItem {
					Image(systemName: "house")
					Text("Home")
				}
			ProjectsView(showClosedProjects: false)
				.tag(ProjectsView.openTag)
				.tabItem {
					Image(systemName: "list.bullet")
					Text("Open")
				}
			ProjectsView(showClosedProjects: true)
				.tag(HomeView.tag)
				.tabItem {
					Image(systemName: "checkmark")
					Text("Closed")
				}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
	static var dataController = DataController.preview
    static var previews: some View {
		ContentView()
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
    }
}
