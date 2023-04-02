//
//  AppDelegate.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 2/22/22.
//

import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did finish launching")
		}
		UNUserNotificationCenter.current().delegate = UserNotificationCenterDelegate.default
		NSApplication.shared.registerForRemoteNotifications()
	}
	
	func application(_: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did register for remote notifications with device token \(deviceToken, privacy: .public)")
		}
		let tokenString = deviceToken
			.map { (byte) in
				return String(format: "%02.2hhx", byte)
			}
			.joined()
		Task {
			do {
				try await API.uploadAPNSToken(token: tokenString).perform()
			} catch let error {
				Logging.withLogger(for: .api) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload APNS device token: \(error, privacy: .public)")
				}
			}
		}
	}
	
	func application(_: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did fail to register for remote notifications with error \(error, privacy: .public)")
		}
		Logging.withLogger(for: .apns, doUpload: true) { (logger) in
			logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to register for remote notifications: \(error, privacy: .public)")
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Should terminate after last window closed")
		}
		return true
	}
	
	func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did receive remote notification \(userInfo, privacy: .public)")
		}
		Task { @MainActor in
			if ShuttleTrackerApp.contentViewSheetStack.top == nil {
				ShuttleTrackerApp.contentViewSheetStack.push(.announcements)
			}
		}
	}
	
}
