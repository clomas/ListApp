//
//  ProjectsView.swift
//  SurfSpots
//
//  Created by Clint Thomas on 17/2/21.
//

import SwiftUI

struct ProjectsView: View {
	static let openTag: String? = "Open"
	static let closedTag: String? = "Closed"

	@StateObject var viewModel: ViewModel
	@State private var showingSortOrder = false

	var projectsList: some View {
		List {
			ForEach(viewModel.projects) { project in
				Section(header: ProjectHeaderView(project: project)) {
					ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
						ItemRowView(project: project, item: item)
					}
					// offsets is an IndexSet- always sorted
					.onDelete { offsets in
						viewModel.delete(offsets, from: project)
					}
					if viewModel.showClosedProjects == false {
						Button {
							withAnimation {
								viewModel.addItem(to: project)
							}
						} label: {
							Label("Add New Item", systemImage: "plus")
						}
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
	}

	var addProjectToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			if viewModel.showClosedProjects == false {
				Button {
					withAnimation {
						viewModel.addProject()
					}
				} label: {
				// In iOS14.3 VoiceOver has a glitch that reads the label
				// "Add Project" as Add no matter what accessibility label
				// we give tis a toolbar button when using a label.
				// As a result, when VoiceOver is running, we use a text view
				// for the button instead, forcing a correct reading without
				// losing the original layout. 

					if UIAccessibility.isVoiceOverRunning {
						Text("Add Project")
					} else {
						Label("Add Project", systemImage: "plus")
					}
				}
			}
		}
	}

	var sortOrderToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				showingSortOrder.toggle()
			} label: {
				Label("Sort", systemImage: "arrow.up.arrow.down")
			}
		}
	}

    var body: some View {
		NavigationView {
			Group {
				if viewModel.projects.isEmpty {
					Text("There is nothing here right now")
						.foregroundColor(.secondary)
				} else {
					projectsList
				}
			}
			.navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
			.toolbar {
				addProjectToolbarItem
				sortOrderToolbarItem
			}
			.actionSheet(isPresented: $showingSortOrder) {
				ActionSheet(title: Text("Sort Items"), message: nil, buttons: [
					.default(Text("Optimised")) { viewModel.sortOrder = .optimised },
					.default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
					.default(Text("Title")) { viewModel.sortOrder = .title }
				])
			}
			SelectSomethingView()
		}
    }

	init(dataController: DataController, showClosedProjects: Bool) {
		let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
}

struct ProjectsView_Previews: PreviewProvider {
	static var dataController = DataController.preview
    static var previews: some View {
		ProjectsView(dataController: DataController.preview, showClosedProjects: false)
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
    }
}
