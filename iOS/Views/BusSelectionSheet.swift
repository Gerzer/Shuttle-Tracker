//
//  BusSelectionSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/21/21.
//

import SwiftUI

struct BusSelectionSheet: View {
	
	@State private var allBusIDs: [BusID]?
	
	@State private var suggestedBusID: BusID?
	
	@State private var selectedBusID: BusID?
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		NavigationView {
			VStack {
				if let allBusIDs = self.allBusIDs {
					ScrollView {
						VStack {
							HStack {
								Text("Which bus did you board?")
									.font(.title3)
								Spacer()
							}
							Spacer()
							HStack {
								Text("Select the number that's printed on the side of the bus:")
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
										if #available(iOS 15.0, *) {
											Divider()
												.background(.secondary)
										} else {
											Divider()
												.background(Color.secondary)
										}
									}
								}
								BusOption(suggestedBusID, selectedBusID: self.$selectedBusID)
								if #available(iOS 15.0, *) {
									Divider()
										.background(.secondary)
										.padding(.vertical, 10)
								} else {
									Divider()
										.background(Color.secondary)
										.padding(.vertical, 10)
								}
							}
							LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible()), count: 3)) {
								ForEach(allBusIDs.sorted()) { (busID) in
									BusOption(busID, selectedBusID: self.$selectedBusID)
								}
							}
							Spacer(minLength: 20)
						}
							.padding(.horizontal)
					}
				} else {
					ProgressView("Loading...")
				}
			}
				.navigationTitle("Bus Selection")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						CloseButton()
					}
					ToolbarItem(placement: .bottomBar) {
						Button {
							self.mapState.busID = self.selectedBusID?.rawValue
							self.mapState.travelState = .onBus
							self.viewState.statusText = .locationData
							self.viewState.sheetType = nil
							LocationUtilities.locationManager.startUpdatingLocation()
						} label: {
							Text("Continue")
								.bold()
						}
							.buttonStyle(BlockButtonStyle())
							.disabled(self.selectedBusID == nil)
							.padding(.vertical)
					}
				}
		}
			.onAppear {
				API.provider.request(.readAllBuses) { (result) in
					self.allBusIDs = try? result.value?
						.map([Int].self)
						.map { (id) in
							return BusID(id)
						}
					guard let location = LocationUtilities.locationManager.location else {
						return
					}
					let closestBus = self.mapState.buses.min { (firstBus, secondBus) -> Bool in
						let firstBusDistance = firstBus.location.convertForCoreLocation().distance(from: location)
						let secondBusDistance = secondBus.location.convertForCoreLocation().distance(from: location)
						return firstBusDistance < secondBusDistance
					}
					guard let rawID = closestBus?.id else {
						return
					}
					let closestBusID = BusID(rawID)
					self.allBusIDs?.removeAll { (element) in
						return element == closestBusID
					}
					self.suggestedBusID = closestBusID
				}
			}
	}
	
}

struct BusSelectionSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		BusSelectionSheet()
	}
	
}
