//
//  BusSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/21/21.
//

import SwiftUI

struct BusSheet: View {
	
	@State private var allBusIDs: [BusID]?
	
	@State private var selectedBusID: BusID?
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				Text("Which bus did you board?")
					.font(.title3)
				Spacer()
				if let allBusIDs = self.allBusIDs {
					ScrollView {
						Text("Select the number that's printed on the side of the bus:")
							.font(.callout)
						LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible()), count: 3)) {
							ForEach(allBusIDs.sorted()) { (busID) in
								Text("\(busID.rawValue)")
									.bold()
									.frame(maxWidth: .infinity, idealHeight: 100)
									.innerShadow(
										using: RoundedRectangle(cornerRadius: 10),
										color: .primary,
										width: busID == self.selectedBusID ? 5 : 0
									)
									.overlay(
										RoundedRectangle(cornerRadius: 10)
											.stroke(
												busID == self.selectedBusID ? .blue : .primary,
												lineWidth: busID == self.selectedBusID ? 5 : 2
											)
									)
									.onTapGesture {
										withAnimation {
											self.selectedBusID = busID
										}
									}
							}
						}
							.padding(.horizontal, 10)
					}
				} else {
					
				}
				Spacer()
				Button {
					self.mapState.busID = self.selectedBusID?.rawValue
					self.viewState.sheetType = nil
				} label: {
					Text("Continue")
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
					.disabled(self.selectedBusID == nil)
					.padding(.vertical)
			}
				.padding(.horizontal)
				.navigationTitle("Bus Selection")
				.toolbar {
					Button {
						self.viewState.sheetType = nil
					} label: {
						if #available(iOS 15.0, *) {
							Image(systemName: "xmark.circle.fill")
								.symbolRenderingMode(.hierarchical)
								.resizable()
								.opacity(0.5)
								.frame(width: ViewUtilities.Constants.sheetCloseButtonDimension, height: ViewUtilities.Constants.sheetCloseButtonDimension)
						} else {
							Text("Close")
								.fontWeight(.semibold)
						}
					}
						.buttonStyle(.plain)
				}
		}
			.onAppear {
				API.provider.request(.readAllBuses) { (result) in
					self.allBusIDs = try? result.value?
						.map([Int].self)
						.map { (id) in
							return BusID(id)
						}
				}
			}
	}
	
}

struct BusSheetPreviews: PreviewProvider {
	static var previews: some View {
		BusSheet()
			.preferredColorScheme(.light)
	}
}

fileprivate final class BusID: Equatable, Comparable, Identifiable, RawRepresentable {
	
	let id: Int
	
	var rawValue: Int {
		get {
			return self.id
		}
	}
	
	init(_ id: Int) {
		self.id = id
	}
	
	required init(rawValue: Int) {
		self.id = rawValue
	}
	
	static func == (_ leftBusID: BusID, _ rightBusID: BusID) -> Bool {
		return leftBusID.id == rightBusID.id
	}
	
	static func < (_ leftBusID: BusID, _ rightBusID: BusID) -> Bool {
		return leftBusID.id < rightBusID.id
	}
	
}
