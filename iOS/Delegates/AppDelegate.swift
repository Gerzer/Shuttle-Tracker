//
//  AppDelegate.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 2/25/23.
//

import UIKit

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		UNUserNotificationCenter.current().delegate = UserNotificationCenterDelegate.default
		application.registerForRemoteNotifications()
		return true
	}
	
	func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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
	
	func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did fail to register for remote notifications with error \(error, privacy: .public)")
		}
		Logging.withLogger(for: .apns, doUpload: true) { (logger) in
			logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to register for remote notifications: \(error, privacy: .public)")
		}
	}
	
	func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
		Logging.withLogger(for: .appDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did receive remote notification \(userInfo, privacy: .public)")
		}
		await UNUserNotificationCenter.handleRemoteNotification(userInfo: userInfo)
		return .newData
	}
	
}
