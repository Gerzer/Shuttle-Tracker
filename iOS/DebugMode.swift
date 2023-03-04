//
//  DebugMode.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 12/25/22.
//

import HTTPStatus
import SwiftUI
import ActivityKit

actor DebugMode {
	
	static let shared = DebugMode()
    
    var currentLiveActivity : Activity<DebugModeActivityAttributes>?
	
	static let toastTimeInterval: TimeInterval = 3
	
	private var toastActivationDate: Date?
    
    func startLiveActivity(busID : Int){
        /// Debug Mode Live Activity
        if #available(iOS 16.2, *) {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            
            let initialContentState = DebugModeActivityAttributes.ContentState(status: "No bugs")
            let debugModeActivityAttributes = DebugModeActivityAttributes(busID: busID)
            let activityContent = ActivityContent(state: initialContentState,
                                                  staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()))
            // Start the Live Activity.
            do {
                    try currentLiveActivity = Activity.request(attributes: debugModeActivityAttributes ,
                                                               content: activityContent)
                print("Started debug mode for live activity")
            } catch (let error) {
                print("Error requesting Live Activity. Reason is: \(error.localizedDescription).")
                }
            }
        } else {
            print("No live activity available on this device .\n")
        }
    }
    
    func updateSession(statusCode newStatusCode: any HTTPStatusCode, busID: Int) async {
        // Make sure we are in debug mode
        guard await AppStorageManager.shared.debugMode else {
            return
        }
        if case .debugMode = await ViewState.shared.toastType {
            return
        }
        /// Debug Mode Toast
        if let toastActivationDate = self.toastActivationDate {
            guard abs(toastActivationDate.timeIntervalSinceNow + 1) > Self.toastTimeInterval else {
                return
            }
        }
        self.toastActivationDate = .now
        await MainActor.run {
            withAnimation {
                ViewState.shared.toastType = .debugMode(statusCode: newStatusCode)
            }
        }
        /// LiveActivity
        if #available(iOS 16.2, *) {
            let updatedDebugStatus = DebugModeActivityAttributes.ContentState(status: newStatusCode.message)
//            let alertConfiguration = AlertConfiguration(title: "", body: "", sound: .default) // we don't want sound
            let updatedContent = ActivityContent(state: updatedDebugStatus, staleDate: nil)
            
            await currentLiveActivity?.update(updatedContent)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    // func updateSession() + showToast
    func endSession() {
        Task {
            if #available(iOS 16.2, *) {
                for activity in Activity<DebugModeActivityAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                    print("Ending the Live Activity: \(activity.id)")
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
	
	func showToast(statusCode newStatusCode: any HTTPStatusCode) async {
		guard await AppStorageManager.shared.debugMode else {
			return
		}
		if case .debugMode = await ViewState.shared.toastType {
			return
		}
		if let toastActivationDate = self.toastActivationDate {
			guard abs(toastActivationDate.timeIntervalSinceNow + 1) > Self.toastTimeInterval else {
				return
			}
		}
		self.toastActivationDate = .now
		await MainActor.run {
			withAnimation {
				ViewState.shared.toastType = .debugMode(statusCode: newStatusCode)
			}
		}
	}
	
	private init() { }
	
}
