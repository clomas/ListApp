//
//  Binding-OnChange.swift
//  SurfSpots
//
//  Created by Clint Thomas on 19/2/21.
//

import SwiftUI

extension Binding {
	// escaping to stash away and use when needed
	func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
		Binding(
			get: { self.wrappedValue},
			set: { newValue in
				self.wrappedValue = newValue
				handler()
			}
		)
	}
}
