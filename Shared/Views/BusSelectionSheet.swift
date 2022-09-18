//
//  BusSelectionSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/21/21.
//

import ActivityKit
import SwiftUI
import CoreLocation

struct BusSelectionSheet: View {
	
	@State private var busIDs: [BusID]?
	
	@State private var suggestedBusID: BusID?
	
	@State private var selectedBusID: BusID?
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
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
										if #available(iOS 15, *) {
											Divider()
												.background(.secondary)
										} else {
											Divider()
												.background(Color.secondary)
										}
									}
								}
								BusOption(suggestedBusID, selection: self.$selectedBusID)
								if #available(iOS 15, *) {
									Divider()
										.background(.secondary)
										.padding(.vertical, 10)
								} else {
									Divider()
										.background(Color.secondary)
										.padding(.vertical, 10)
								}
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
							switch LocationUtilities.locationManager.accuracyAuthorization {
							case .fullAccuracy:
								self.boardBus()
							case .reducedAccuracy:
								Task {
									try await LocationUtilities.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
									self.boardBus()
								}
							@unknown default:
								fatalError()
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
					let closestBus = self.mapState.buses.min { (firstBus, secondBus) -> Bool in
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
	
	/// Starts sending bus location data to the server.
	/// - Precondition: The user has authorized full location accuracy.
	private func boardBus() {
		precondition(LocationUtilities.locationManager.accuracyAuthorization == .fullAccuracy)
		self.mapState.busID = self.selectedBusID?.rawValue
		self.mapState.travelState = .onBus
		self.viewState.statusText = .locationData
		self.viewState.handles.tripCount?.increment()
		self.sheetStack.pop()
		LocationUtilities.locationManager.startUpdatingLocation()
		if #available(iOS 16.1, *) {
			do {
				_ = try Activity.request(
					attributes: BoardBusAttributes(
						stops: self.mapState.stops,
						routes: self.mapState.routes
					),
					contentState: BoardBusAttributes.ContentState(
						travelState: self.mapState.travelState,
						coordinate: LocationUtilities.locationManager.location?.coordinate.convertedToCoordinate()
					)
				)
			} catch let error {
				LoggingUtilities.logger.log(level: .error, "Live Activity request failed: \(error)")
			}
		}
		
		// Schedule leave-bus notification
		let content = UNMutableNotificationContent()
		content.title = "Leave Bus"
		content.body = "Did you leave the bus? Remember to tap “Leave Bus” next time."
		content.sound = .default
		#if !APPCLIP
		if #available(iOS 15, *) {
			content.interruptionLevel = .timeSensitive
		}
		#endif // !APPCLIP
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1080, repeats: false)
		let request = UNNotificationRequest(identifier: "LeaveBus", content: content, trigger: trigger)
		Task {
			do {
				try await UserNotificationUtilities.requestAuthorization()
			} catch let error {
				print("[\(#fileID):\(#line) \(#function)] \(error)")
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
	}
	
}
