//
//  EditProjectView.swift
//  SurfSpots
//
//  Created by Clint Thomas on 20/2/21.
//
import CoreHaptics
import SwiftUI

struct EditProjectView: View {
	@ObservedObject var project: Project

	@EnvironmentObject var dataController: DataController
	@Environment(\.presentationMode) var presentationMode

	@State private var title: String
	@State private var detail: String
	@State private var colour: String
	@State private var showingDeleteConfirm = false
	@State private var remindMe: Bool
	@State private var reminderTime: Date

	// @State to keep alive between refreshes of view.
	@State private var engine = try? CHHapticEngine()

	let colorColumns = [
		GridItem(.adaptive(minimum: 44))
	]

	init(project: Project) {
		self.project = project

		_title = State(wrappedValue: project.projectTitle)
		_detail = State(wrappedValue: project.projectDetail)
		_colour = State(wrappedValue: project.projectColour)

		if let projectReminderTime = project.reminderTime {
			_reminderTime = State(wrappedValue: projectReminderTime)
			_remindMe = State(wrappedValue: true)
		} else {
			_reminderTime = State(wrappedValue: Date())
			_remindMe = State(wrappedValue: false)
		}
	}

    var body: some View {
		Form {
			Section(header: Text("Basic Settings")) {
				TextField("Project name", text: $title.onChange(update))
				TextField("Description of this project", text: $detail.onChange(update))
			}
			Section(header: Text("Custom project colour")) {
				LazyVGrid(columns: colorColumns) {
					ForEach(Project.colors, id: \.self, content: colourButton)
				}
				.padding(.vertical)
			}

			Section(header: Text("Project reminders")) {
				Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))

				if remindMe {
					DatePicker(
						"Reminder time",
						selection: $reminderTime.onChange(update),
						displayedComponents: .hourAndMinute
					)
				}
			}

			// swiftlint:disable:next line_length
			Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project entirely")) {
				Button(project.closed ? "Reopen this project" : "Close this project", action: toggleClosed)
				Button("Delete this project") {
					showingDeleteConfirm.toggle()
				}
				.accentColor(.red)
			}
		}
		.navigationTitle("Edit Project")
		.onDisappear(perform: dataController.save)
		.alert(isPresented: $showingDeleteConfirm) {
			Alert(
				title: Text("Delete Project"),
				message: Text(
					"Are you sure you want to delete this project? You will also delete all the items it contains."), // swiftlint:disable:this line_length
				primaryButton: .default(Text("Delete"), action: delete),
				secondaryButton: .cancel())
		}
    }

	func toggleClosed() {
		project.closed.toggle()

		if project.closed {
			do {
				try engine?.start()
				let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
				let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
				let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
				let end = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
				let parameter = CHHapticParameterCurve(
					parameterID: .hapticIntensityControl,
				    controlPoints: [start, end],
					relativeTime: 0
				)

				let event1 = CHHapticEvent(
					eventType: .hapticTransient,
					parameters: [intensity, sharpness],
					relativeTime: 0
				)

				let event2 = CHHapticEvent(
					eventType: .hapticContinuous,
					parameters: [sharpness, intensity],
					relativeTime: 0.125,
					duration: 1
				)
				let pattern = try CHHapticPattern(
					events: [event1, event2],
					parameterCurves: [parameter]
				)

				let player = try engine?.makePlayer(with: pattern)
				try player?.start(atTime: 0)
			} catch {
				// haptics didn't work.
			}
		}
	}

	func colourButton(for item: String) -> some View {
		ZStack {
			Color(item)
				.aspectRatio(1, contentMode: .fit)
				.cornerRadius(6)

			if item == colour {
				Image(systemName: "checkmark.circle")
					.foregroundColor(.white)
					.font(.largeTitle)
			}
		}
		.onTapGesture {
			colour = item
			update()
		}
		.accessibilityElement(children: .ignore)
		.accessibilityAddTraits(
			item == colour ? [.isButton, .isSelected] : .isButton
		)
		.accessibilityLabel(LocalizedStringKey(item))
	}

	func update() {
		project.title = title
		project.detail = detail
		project.colour = colour
		if remindMe {
			project.reminderTime = reminderTime
		} else {
			project.reminderTime = nil
		}
	}

	func delete() {
		dataController.delete(project)
		presentationMode.wrappedValue.dismiss()
	}
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
		EditProjectView(project: Project.example)
    }
}
