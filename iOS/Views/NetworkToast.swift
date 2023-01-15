//
//  NetworkToast.swift
//  Shuttle Tracker (iOS)
//
//  Created by John Foster on 12/1/22.
//

import SwiftUI

struct NetworkToast: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@Environment(\.openURL) private var openURL
	
	var body: some View {
		Toast("Join the Network!") {
			withAnimation {
				self.viewState.toastType = nil
			}
		} content: {
			VStack {
				Text("The Shuttle Tracker Network unlocks vastly improved tracking coverage. Enable location permission to join the Network!")
				Button {
					switch (LocationUtilities.locationManager.authorizationStatus, LocationUtilities.locationManager.accuracyAuthorization) {
					case (.authorizedAlways, .fullAccuracy), (.authorizedWhenInUse, .fullAccuracy):
						break
					case (.restricted, _), (.denied, _):
						let url = URL(string: UIApplication.openSettingsURLString)!
						self.openURL(url)
					case (.notDetermined, _):
						LocationUtilities.locationManager.requestAlwaysAuthorization()
					case (_, .reducedAccuracy):
						Task {
							do {
								try await LocationUtilities.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
							} catch let error {
								print("[NetworkToast body] Full-accuracy location authorization request error: \(error.localizedDescription)")
							}
						}
					@unknown default:
						fatalError()
					}
					self.viewState.toastType = nil
					
				} label: {
					Text("Join the Network")
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
			}
		}
	}
	
}
