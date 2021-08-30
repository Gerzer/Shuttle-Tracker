//
//  RouteSelectionSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 8/30/21.
//

import SwiftUI

struct RouteSelectionSheet: View {
	
	@Binding private(set) var travelState: TravelState
	
	@Binding private(set) var parentSheetType: ContentView.SheetType?
	
	@Binding private(set) var parentStatusText: ContentView.StatusText
	
	let updateButtonStateHandler: () -> Void
	
	var body: some View {
		ZStack {
			VStack {
				HStack {
					Spacer()
					Button("Close") {
						self.parentSheetType = nil
					}
						.padding()
				}
				Spacer()
			}
			VStack {
				Text("Which route did you board?")
				HStack {
					Button {
						self.parentSheetType = nil
						self.travelState = .onWestRoute
						self.parentStatusText = .locationData
						self.updateButtonStateHandler()
					} label: {
						Text("West Route")
							.padding()
					}
						.buttonStyle(BlockButtonStyle(color: .blue))
						.padding(.leading)
					Button {
						self.parentSheetType = nil
						self.travelState = .onNorthRoute
						self.parentStatusText = .locationData
						self.updateButtonStateHandler()
					} label: {
						Text("North Route")
							.padding()
					}
						.buttonStyle(BlockButtonStyle(color: .red))
						.padding(.trailing)
				}
			}
		}
	}
	
}
