//
//  BusSelectionSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/21/21.
//

import CoreLocation
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
							Divider()
								.background(.secondary)
								.padding(.vertical, 10)
							BusOption(.unknown, selection: self.$selectedBusID)
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
										Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
											logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Temporary full-accuracy location authorization request failed: \(error, privacy: .public)")
										}
										self.sheetStack.pop()
										throw error
									}
									guard case .fullAccuracy = CLLocationManager.default.accuracyAuthorization else {
										Logging.withLogger(for: .permissions) { (logger) in
											logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] User declined full location accuracy authorization")
										}
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
						.compactMap { (id) in
							return BusID(id)
						}
				} catch {
					Logging.withLogger(for: .api, doUpload: true) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to get list of known bus IDs from the server: \(error, privacy: .public)")
					}
				}
				guard let location = CLLocationManager.default.location else {
					Logging.withLogger(for: .location, doUpload: true) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Can’t suggest nearest bus because the user’s location is unavailable")
					}
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
				self.suggestedBusID = closestBus.flatMap { (bus) in
					return BusID(bus.id)
				}
			}
			.onDisappear {
				if !self.didContinueWithSelectedBusID {
					Task {
						do {
							try await Analytics.upload(eventType: .busSelectionCanceled)
						} catch {
							Logging.withLogger(for: .api) { (logger) in
								logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics entry: \(error, privacy: .public)")
							}
						}
					}
				}
			}
	}
	
	/// Works with ``BoardBusManager`` to activate Board Bus.
	/// - Precondition: The user has granted full location accuracy authorization.
	private func boardBus() async {
		precondition(CLLocationManager.default.accuracyAuthorization == .fullAccuracy)
		Logging.withLogger(for: .boardBus) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Activating Board Bus manually…")
		}
		guard let id = self.selectedBusID?.rawValue else {
			Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] No selected bus ID while trying to activate manual Board Bus")
			}
			return
		}
		await self.boardBusManager.boardBus(id: id, manually: true)
		self.sheetStack.pop()
		CLLocationManager.default.startUpdatingLocation()
	}
	
}

#Preview {
	BusSelectionSheet()
		.environmentObject(MapState.shared)
		.environmentObject(ViewState.shared)
		.environmentObject(BoardBusManager.shared)
		.environmentObject(ShuttleTrackerSheetStack())
}
