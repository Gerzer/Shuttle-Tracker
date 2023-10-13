//
//  UserNotificationCenterDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/31/23.
//

import UserNotifications

/// The standard `UNUserNotificationCenterDelegate` implementation.
@MainActor
final class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
	
	/// The default delegate object.
	///
	/// Generally, there’s no need to create new delegate objects; just use the default one.
	static let `default` = UserNotificationCenterDelegate()
	
	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		Logging.withLogger(for: .userNotificationCenterDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did receive \(response, privacy: .public)")
		}
		await UNUserNotificationCenter.handleNotification(userInfo: response.notification.request.content.userInfo)
	}
	
}
