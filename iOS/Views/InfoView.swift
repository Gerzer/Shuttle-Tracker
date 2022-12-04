//
//  InfoView.swift
//  Shuttle Tracker (iOS)
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
	private var sheetStack: SheetStack
	
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
		SheetPresentationWrapper {
			ScrollView {
				VStack(alignment: .leading, spacing: 0) {
					Text("Shuttle Tracker shows you the real-time locations of the Rensselaer campus shuttles, powered by crowd-sourced location data.")
						.padding(.bottom)
					if let schedule = self.schedule {
						Section {
							HStack {
								VStack(alignment: .leading, spacing: 0) {
									Text("Monday")
									Text("Tuesday")
									Text("Wednesday")
									Text("Thursday")
									Text("Friday")
									Text("Saturday")
									Text("Sunday")
								}
								VStack(alignment: .leading, spacing: 0) {
									Text("\(schedule.content.monday.start) to \(schedule.content.monday.end)")
									Text("\(schedule.content.tuesday.start) to \(schedule.content.tuesday.end)")
									Text("\(schedule.content.wednesday.start) to \(schedule.content.wednesday.end)")
									Text("\(schedule.content.thursday.start) to \(schedule.content.thursday.end)")
									Text("\(schedule.content.friday.start) to \(schedule.content.friday.end)")
									Text("\(schedule.content.saturday.start) to \(schedule.content.saturday.end)")
									Text("\(schedule.content.sunday.start) to \(schedule.content.sunday.end)")
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
						Button("View Privacy Information") {
							self.sheetStack.push(.privacy)
						}
							.padding(.bottom)
					}
				}
					.padding(.horizontal)
			}
				.navigationTitle("Shuttle Tracker 🚐")
				.toolbar {
					ToolbarItem {
						CloseButton()
					}
				}
		}
			.onAppear {
				Task {
					self.schedule = await Schedule.download()
				}
			}
	}
	
}

struct InfoViewPreviews: PreviewProvider {
	
	static var previews: some View {
		InfoView()
			.environmentObject(ViewState.shared)
			.environmentObject(AppStorageManager.shared)
			.environmentObject(SheetStack())
	}
	
}
