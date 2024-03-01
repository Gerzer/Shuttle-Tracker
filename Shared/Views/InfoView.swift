//
//  InfoView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/4/22.
//

import SwiftUI

struct InfoView: View {
	
	@State
	private var schedule: Schedule?
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	private var highQualityMessage: String {
		get {
			return self.appStorageManager.colorBlindMode ? "The scope icon indicates high-quality location data" : "Green buses indicate high-quality location data" // Capitalization is appropriate for the beginning of a sentence
		}
	}
	
	private var lowQualityMessage: String {
		get {
			return self.appStorageManager.colorBlindMode ? "the dotted-circle icon indicates low-quality location data" : "red buses indicate low-quality location data" // Capitalization is appropriate for the middle of a sentence
		}
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
				#if os(macOS)
				Text("Shuttle Tracker 🚐")
					.font(.largeTitle)
					.bold()
					.padding(.top)
				#endif //os(macOS)
				Text("Shuttle Tracker shows you the real-time locations of the Rensselaer campus shuttle buses, powered by crowdsourced location data.")
					.padding(.bottom)
				if let schedule = self.schedule {
					Section {
						let weekday = Calendar.current.component(.weekday, from: .now)
						HStack {
							VStack(alignment: .leading, spacing: 0) {
								Text("Monday")
									.fontWeight(weekday == 2 ? .bold : .regular)
								Text("Tuesday")
									.fontWeight(weekday == 3 ? .bold : .regular)
								Text("Wednesday")
									.fontWeight(weekday == 4 ? .bold : .regular)
								Text("Thursday")
									.fontWeight(weekday == 5 ? .bold : .regular)
								Text("Friday")
									.fontWeight(weekday == 6 ? .bold : .regular)
								Text("Saturday")
									.fontWeight(weekday == 7 ? .bold : .regular)
								Text("Sunday")
									.fontWeight(weekday == 1 ? .bold : .regular)
							}
							VStack(alignment: .leading, spacing: 0) {
								Text("\(schedule.content.monday.start) to \(schedule.content.monday.end)")
									.fontWeight(weekday == 2 ? .bold : .regular)
								Text("\(schedule.content.tuesday.start) to \(schedule.content.tuesday.end)")
									.fontWeight(weekday == 3 ? .bold : .regular)
								Text("\(schedule.content.wednesday.start) to \(schedule.content.wednesday.end)")
									.fontWeight(weekday == 4 ? .bold : .regular)
								Text("\(schedule.content.thursday.start) to \(schedule.content.thursday.end)")
									.fontWeight(weekday == 5 ? .bold : .regular)
								Text("\(schedule.content.friday.start) to \(schedule.content.friday.end)")
									.fontWeight(weekday == 6 ? .bold : .regular)
								Text("\(schedule.content.saturday.start) to \(schedule.content.saturday.end)")
									.fontWeight(weekday == 7 ? .bold : .regular)
								Text("\(schedule.content.sunday.start) to \(schedule.content.sunday.end)")
									.fontWeight(weekday == 1 ? .bold : .regular)
							}
							Spacer()
						}
							.padding(.bottom)
					} header: {
						Text("Schedule")
							.font(.headline)
					}
				}
				Section {
					Text("The map is automatically refreshed every 5 seconds. \(self.highQualityMessage), and \(self.lowQualityMessage). When boarding a bus, tap “Board Bus”, and when getting off, tap “Leave Bus”. You must be within \(self.appStorageManager.maximumStopDistance) meter\(self.appStorageManager.maximumStopDistance == 1 ? "" : "s") of a stop to board a bus.")
						.padding(.bottom)
				} header: {
					Text("Instructions")
						.font(.headline)
				}
				Section {
					Button("Show Privacy Information") {
						self.sheetStack.push(.privacy)
					}
						.padding(.bottom)
				}
			}
				.padding(.horizontal)
		}
			.navigationTitle("Shuttle Tracker 🚐")
			.toolbar {
				#if os(iOS)
				ToolbarItem {
					CloseButton()
				}
				#elseif os(macOS) // os(iOS)
				ToolbarItem(placement: .confirmationAction) {
					if case .some(.info) = self.sheetStack.top {
						Button("Close") {
							self.sheetStack.pop()
						}
					}
				}
				#endif // os(macOS)
			}
			.onAppear {
				Task {
					self.schedule = await Schedule.download()
				}
			}
			.sheetPresentation(
				provider: ShuttleTrackerSheetPresentationProvider(sheetStack: self.sheetStack),
				sheetStack: self.sheetStack
			)
	}
	
}

#Preview {
	InfoView()
		.environmentObject(ViewState.shared)
		.environmentObject(AppStorageManager.shared)
		.environmentObject(ShuttleTrackerSheetStack())
}
