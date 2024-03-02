//
//  AppDelegate.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 2/25/23.
//

import STLogging
import UIKit

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		if let launchOptions {
			#log(system: Logging.system, category: .appDelegate, level: .info, "Did finish launching with options \(launchOptions, privacy: .public)")
		} else {
			#log(system: Logging.system, category: .appDelegate, level: .info, "Did finish launching with options")
		}
		UNUserNotificationCenter.current().delegate = UserNotificationCenterDelegate.default
		application.registerForRemoteNotifications()
		return true
	}
	
	func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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
	
	func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Did fail to register for remote notifications with error \(error, privacy: .public)")
		#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to register for remote notifications: \(error, privacy: .public)")
	}
	
	func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
		#log(system: Logging.system, category: .appDelegate, level: .info, "Did receive remote notification \(userInfo, privacy: .public)")
		await UNUserNotificationCenter.handleNotification(userInfo: userInfo)
		return .newData
	}
	
}
