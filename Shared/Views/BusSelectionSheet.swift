//
//  BusSelectionSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/21/21.
//

import CoreLocation
import STLogging
import SwiftUI
import UserNotifications

struct BusSelectionSheet: View {
	
	@State
	private var busIDs: [BusID]?
	
	@State
	private var suggestedBusID: BusID?
	
	@State
	private var selectedBusID: BusID?
	
	@State
	private var didContinueWithSelectedBusID = false
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var boardBusManager: BoardBusManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
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
									if #available(iOS 16, *) {
										Label("Suggested", systemImage: "sparkles")
											.font(.caption)
											.italic()
											.foregroundColor(.secondary)
									} else {
										Label("Suggested", systemImage: "sparkles")
											.font(.caption.italic())
											.foregroundColor(.secondary)
									}
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
							self.didContinueWithSelectedBusID = true
							Task {
								switch CLLocationManager.default.accuracyAuthorization {
								case .fullAccuracy:
									await self.boardBus()
								case .reducedAccuracy:
									do {
										try await CLLocationManager.default.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
									} catch {
										#log(system: Logging.system, category: .permissions, level: .error, doUpload: true, "Temporary full-accuracy location authorization request failed: \(error, privacy: .public)")
										self.sheetStack.pop()
										throw error
									}
									guard case .fullAccuracy = CLLocationManager.default.accuracyAuthorization else {
										#log(system: Logging.system, category: .permissions, "User declined full location accuracy authorization")
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
			.task {
				do {
					self.busIDs = try await API.readAllBuses.perform(as: [Int].self)
						.map { (id) in
							return BusID(id)
						}
				} catch {
					#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to get list of known bus IDs from the server: \(error, privacy: .public)")
				}
				guard let location = CLLocationManager.default.location else {
					#log(system: Logging.system, category: .location, level: .error, doUpload: true, "Can’t suggest nearest bus because the user’s location is unavailable")
					return
				}
				let closestBus = await self.mapState.buses.min { (first, second) in
					let firstBusDistance = first.location
						.convertedForCoreLocation()
						.distance(from: location)
					let secondBusDistance = second.location
						.convertedForCoreLocation()
						.distance(from: location)
					return firstBusDistance < secondBusDistance
				}
				self.suggestedBusID = closestBus.map { (bus) in
					return BusID(bus.id)
				}
			}
			.onDisappear {
				if !self.didContinueWithSelectedBusID {
					Task {
						do {
							try await Analytics.upload(eventType: .busSelectionCanceled)
						} catch {
							#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics entry: \(error, privacy: .public)")
						}
					}
				}
			}
	}
	
	/// Works with ``BoardBusManager`` to activate Board Bus.
	/// - Precondition: The user has granted full location accuracy authorization.
	private func boardBus() async {
		precondition(CLLocationManager.default.accuracyAuthorization == .fullAccuracy)
		#log(system: Logging.system, category: .boardBus, level: .info, "Activating Board Bus manually…")
		guard let id = self.selectedBusID?.rawValue else {
			#log(system: Logging.system, category: .boardBus, level: .error, doUpload: true, "No selected bus ID while trying to activate manual Board Bus")
			return
		}
		await self.boardBusManager.boardBus(id: id, manually: true)
		self.sheetStack.pop()
		CLLocationManager.default.startUpdatingLocation()
	}
	
}

struct BusSelectionSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		BusSelectionSheet()
			.environmentObject(MapState.shared)
			.environmentObject(ViewState.shared)
			.environmentObject(BoardBusManager.shared)
			.environmentObject(ShuttleTrackerSheetStack())
	}
	
}
