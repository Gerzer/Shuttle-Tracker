//
//  BusSelectionSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/21/21.
//

import SwiftUI
import CoreLocation

struct BusSelectionSheet: View {
	
	@State private var busIDs: [BusID]?
	
	@State private var suggestedBusID: BusID?
	
	@State private var selectedBusID: BusID?
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var boardbusManager: BoardBusManager
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	var body: some View {
		NavigationView {
			VStack {
				if let allBusIDs = self.busIDs {
					ScrollView {
						VStack {
							HStack {
								Text("Which bus did you board?")
									.font(.title3)
								Spacer()
							}
							Spacer()
							HStack {
								Text("Select the number that’s printed on the side of the bus:")
									.font(.callout)
								Spacer()
							}
							if let suggestedBusID = self.suggestedBusID {
								HStack {
									Label("Suggested", systemImage: "sparkles")
										.font(
											.caption
												.italic()
										)
										.foregroundColor(.secondary)
									VStack {
										Divider()
											.background(.secondary)
									}
								}
								BusOption(suggestedBusID, selection: self.$selectedBusID)
								Divider()
									.background(.secondary)
									.padding(.vertical, 10)
							}
							LazyVGrid(
								columns: [GridItem](
									repeating: GridItem(.flexible()),
									count: 3
								)
							) {
								ForEach(allBusIDs.sorted()) { (busID) in
									BusOption(busID, selection: self.$selectedBusID)
								}
							}
							Spacer(minLength: 20)
						}
						.padding(.horizontal)
					}
				} else {
					ProgressView("Loading")
						.font(.callout)
						.textCase(.uppercase)
				}
			}
				.navigationTitle("Bus Selection")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						CloseButton()
					}
					ToolbarItem(placement: .bottomBar) {
						Button {
							Task {
								switch LocationUtilities.locationManager.accuracyAuthorization {
								case .fullAccuracy:
									await self.boardBus()
								case .reducedAccuracy:
									try await LocationUtilities.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
									guard case .fullAccuracy = LocationUtilities.locationManager.accuracyAuthorization else {
										LoggingUtilities.logger(for: .permissions).log(level: .default, "User declined full accuracy authorization")
										return
									}
									await self.boardBus()
								@unknown default:
									fatalError()
								}
							}
						} label: {
							Text("Continue")
								.bold()
						}
							.buttonStyle(.block)
							.disabled(self.selectedBusID == nil)
							.padding(.vertical)
					}
				}
		}
			.onAppear {
				API.provider.request(.readAllBuses) { (result) in
					self.busIDs = try? result
						.get()
						.map([Int].self)
						.map { (id) in
							return BusID(id)
						}
					guard let location = LocationUtilities.locationManager.location else {
						return
					}
					Task {
						let closestBus = await self.mapState.buses.min { (firstBus, secondBus) -> Bool in
							let firstBusDistance = firstBus.location
								.convertedForCoreLocation()
								.distance(from: location)
							let secondBusDistance = secondBus.location
								.convertedForCoreLocation()
								.distance(from: location)
							return firstBusDistance < secondBusDistance
						}
						self.suggestedBusID = closestBus.map { (bus) in
							return BusID(bus.id)
						}
					}
				}
			}
	}
	
	/// Works with ``BoardBusManager`` to activate Board Bus.
	/// - Precondition: The user has granted full location accuracy authorization.
	private func boardBus() async {
		precondition(LocationUtilities.locationManager.accuracyAuthorization == .fullAccuracy)
		guard let busID = self.selectedBusID?.rawValue else {
			LoggingUtilities.logger(for: .boardBus).log(level: .error, "No selected bus ID")
			return
		}
		await self.boardbusManager.boardBus(id: busID)
		self.viewState.statusText = .locationData
		self.viewState.handles.tripCount?.increment()
		self.sheetStack.pop()
		LocationUtilities.locationManager.startUpdatingLocation()
		
		// Schedule leave-bus notification
		let content = UNMutableNotificationContent()
		content.title = "Leave Bus"
		content.body = "Did you leave the bus? Remember to tap “Leave Bus” next time."
		content.sound = .default
		#if !APPCLIP
		content.interruptionLevel = .timeSensitive
		#endif // !APPCLIP
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1080, repeats: false)
		let request = UNNotificationRequest(identifier: "LeaveBus", content: content, trigger: trigger)
		Task {
			do {
				try await UserNotificationUtilities.requestAuthorization()
			} catch let error {
				LoggingUtilities.logger(for: .permissions).log(level: .error, "\(error)")
			}
			try await UNUserNotificationCenter
				.current()
				.add(request)
		}
	}
	
}

struct BusSelectionSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		BusSelectionSheet()
			.environmentObject(MapState.shared)
			.environmentObject(ViewState.shared)
			.environmentObject(BoardBusManager.shared)
			.environmentObject(SheetStack())
	}
	
}
