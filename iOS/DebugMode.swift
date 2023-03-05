//
//  DebugMode.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 12/25/22.
//

import HTTPStatus
import SwiftUI
import ActivityKit

@available(iOS 16.2, *)
actor DebugMode {
	
	static let shared = DebugMode()
    
    var currentLiveActivity : Activity<DebugModeActivityAttributes>?
	
	static let toastTimeInterval: TimeInterval = 3
	
	private var toastActivationDate: Date?
    
    /// Debug Mode Live Activity
    func startLiveActivity(busID : Int){
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            
            let initialContentState = DebugModeActivityAttributes.ContentState(submissionStatus: true,
                                                                               code: "-1",
                                                                               status: "Start debugging")
            let debugModeActivityAttributes = DebugModeActivityAttributes(busID: busID)
            let activityContent = ActivityContent(state: initialContentState,
                                                  staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date()))
            do {
                try currentLiveActivity = Activity.request(attributes: debugModeActivityAttributes ,
                                                               content: activityContent)
                print("Started debug mode for live activity \(currentLiveActivity?.id ?? "no id")")
            } catch (let error) {
                print("Error requesting Live Activity. Reason is: \(error.localizedDescription).")
                }
            }
    }
    
    /// Update Live Activity session with latest status.
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
        /// LiveActivity update
        let updatedDebugStatus = DebugModeActivityAttributes.ContentState(submissionStatus: newStatusCode is any Error ? false : true,
                                                                              code: "\(newStatusCode.rawValue)",
                                                                              status: newStatusCode.message)
            let updatedContent = ActivityContent(state: updatedDebugStatus, staleDate: nil)
            
            await currentLiveActivity?.update(updatedContent)
    }
    
    /// End live activity session.
    func endSession() {
        Task {
            for activity in Activity<DebugModeActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("Ending the Live Activity: \(activity.id)")
            }
        }
    }
	
    /// Deprecated, we start the debug mode directly with the Live Activity.
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
