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
                    
                    Task {
                        do {
                            try await Analytics.uploadAnalytics(["networkToastPermissionsTapped": [:]])
                            try await Analytics.uploadAnalytics(["locationAuthorizationStatusDidChange": [ "authorizationStatus" : Payload(Int(CLLocationManager.default.authorizationStatus.rawValue)) ]])
                            try await Analytics.uploadAnalytics(["locationAuthorizationAccuracyDidChange": [ "accuracyAuthorization" : Payload(Int(CLLocationManager.default.accuracyAuthorization.rawValue)) ]])
                        } catch {
                            Logging.withLogger(for: .api, doUpload: true) { (logger) in
                                logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
                            }
                        }
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
