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
	
	@Environment(\.openURL) private var openURL
	
	var body: some View {
		Toast("Join the Network!", item: self.$viewState.toastType) { (_, dismiss) in
			VStack {
				Text("The Shuttle Tracker Network unlocks vastly improved tracking coverage. Enable location permission to join the Network!")
				Button {
					switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
					case (.authorizedAlways, .fullAccuracy), (.authorizedWhenInUse, .fullAccuracy):
						break
					case (.restricted, _), (.denied, _):
						self.openURL(URL(string: UIApplication.openSettingsURLString)!)
					case (.notDetermined, _):
						CLLocationManager.default.requestAlwaysAuthorization()
					case (_, .reducedAccuracy):
						Task {
							do {
								try await CLLocationManager.default.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
							} catch let error {
								Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
									logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Full-accuracy location authorization request failed: \(error, privacy: .public)")
								}
							}
						}
					@unknown default:
						fatalError()
					}
					dismiss()
				} label: {
					Text("Join the Network")
						.bold()
				}
					.buttonStyle(BlockButtonStyle())
			}
		}
	}
	
}
