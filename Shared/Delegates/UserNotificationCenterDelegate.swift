//
//  UserNotificationCenterDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/31/23.
//

import UserNotifications

final class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
	
	static let `default` = UserNotificationCenterDelegate()
	
	@MainActor
	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		Logging.withLogger(for: .userNotificationCenterDelegate) { (logger) in
			logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Did receive \(response, privacy: .public)")
		}
		#if os(iOS)
		let sheetStack = ShuttleTrackerApp.sheetStack
		#elseif os(macOS) // os(iOS)
		let sheetStack = ShuttleTrackerApp.contentViewSheetStack
		#endif // os(macOS)
		if sheetStack.top == nil {
			sheetStack.push(.announcements)
		}
	}
	
}
