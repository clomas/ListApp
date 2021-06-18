//
//  ItemRowView.swift
//  SurfSpots
//
//  Created by Clint Thomas on 19/2/21.
//

import SwiftUI

struct ItemRowView: View {
	@StateObject var viewModel: ViewModel
	// need this here as well as viewModel for NavigationLink and Observable.
	@ObservedObject var item: Item

    var body: some View {
		NavigationLink(destination: EditItemView(item: item)) {
			Label {
				Text(item.itemTitle)
			} icon: {
				Image(systemName: viewModel.icon)
					// optional map here given string is optional.
					.foregroundColor(viewModel.color.map { Color($0) } ?? .clear)
			}
		}.accessibilityLabel(viewModel.label)
    }

	init(project: Project, item: Item) {
		let viewModel = ViewModel(project: project, item: item)
		_viewModel = StateObject(wrappedValue: viewModel)
		self.item = item
	}
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
		ItemRowView(project: Project.example, item: Item.example)
    }
}
