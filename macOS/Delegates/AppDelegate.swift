//
//  AppDelegate.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 2/22/22.
//

import AppKit
import STLogging
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Did finish launching")
		UNUserNotificationCenter.current().delegate = UserNotificationCenterDelegate.default
		NSApplication.shared.registerForRemoteNotifications()
	}
	
	func application(_: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Did register for remote notifications with device token \(deviceToken, privacy: .public)")
		let tokenString = deviceToken
			.map { (byte) in
				return String(format: "%02.2hhx", byte)
			}
			.joined()
		Task {
			do {
				try await API.uploadAPNSToken(token: tokenString).perform()
			} catch {
				#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload APNS device token: \(error, privacy: .public)")
			}
		}
	}
	
	func application(_: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Did fail to register for remote notifications with error \(error, privacy: .public)")
		#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to register for remote notifications: \(error, privacy: .public)")
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Should terminate after last window closed")
		return true
	}
	
	func application(_: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Did receive remote notification \(userInfo, privacy: .public)")
		Task {
			await UNUserNotificationCenter.handleNotification(userInfo: userInfo)
		}
	}
	
}
