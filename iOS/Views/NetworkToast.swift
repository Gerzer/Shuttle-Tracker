//
//  NetworkToast.swift
//  Shuttle Tracker (iOS)
//
//  Created by John Foster on 12/1/22.
//

import CoreLocation
import SwiftUI

struct NetworkToast: View {
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		Toast("Join the Network!", item: self.$viewState.toastType) { (_, dismiss) in
			VStack(alignment: .leading) {
				Text(try! AttributedString(markdown: "The Shuttle Tracker Network unlocks **dramatically improved tracking coverage**. Enable location access to join the Network!"))
				Button {
					switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
					case (.authorizedAlways, .fullAccuracy):
						dismiss()
					default:
						self.sheetStack.push(.permissions)
					}
					
					Task {
						do {
							try await Analytics.upload(eventType: .networkToastPermissionsTapped)
						} catch let error {
							Logging.withLogger(for: .api, doUpload: true) { (logger) in
								logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
							}
						}
					}
				} label: {
					Text("Join the Network")
						.bold()
						.padding(5)
						.frame(maxWidth: .infinity)
				}
					.buttonStyle(.borderedProminent)
					.buttonBorderShape(.roundedRectangle(radius: 15))
			}
				.onChange(of: CLLocationManager.default.authorizationStatus) { (authorizationStatus) in
					Task {
						do {
							try await Analytics.upload(eventType: .locationAuthorizationStatusDidChange(authorizationStatus: Int(authorizationStatus.rawValue)))
						} catch let error {
							Logging.withLogger(for: .api, doUpload: true) { (logger) in
								logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
							}
						}
					}
				}
				.onChange(of: CLLocationManager.default.accuracyAuthorization) { (accuracyAuthorization) in
					Task {
						do {
							try await Analytics.upload(eventType: .locationAccuracyAuthorizationDidChange(accuracyAuthorization: Int(accuracyAuthorization.rawValue)))
						} catch let error {
							Logging.withLogger(for: .api, doUpload: true) { (logger) in
								logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
							}
						}
					}
				}
		}
	}
	
}
