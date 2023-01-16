//
//  NetworkToast.swift
//  Shuttle Tracker (iOS)
//
//  Created by John Foster on 12/1/22.
//

import CoreLocation
import SwiftUI

struct NetworkToast: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	var body: some View {
		Toast("Join the Network!", item: self.$viewState.toastType) { (_, dismiss) in
			VStack(alignment: .leading) {
				Text(try! AttributedString(markdown: "The Shuttle Tracker Network unlocks **vastly improved tracking coverage**. Enable location permission to join the Network!"))
				Button {
					switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
					case (.authorizedAlways, .fullAccuracy):
						dismiss()
					default:
						self.sheetStack.push(.permissions)
					}
				} label: {
					Text("Join the Network")
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
			}
		}
	}
	
}
