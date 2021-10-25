//
//  UserNotificationCenterDelegate.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/24/21.
//

import UserNotifications

@available(iOS 15, *) class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		switch response.actionIdentifier {
		case NotificationUtilities.Constants.leaveBusActionIdentifier:
			LocationUtilities.leaveBus()
		default:
			break
		}
	}
	
}

class LegacyUserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.actionIdentifier {
		case NotificationUtilities.Constants.leaveBusActionIdentifier:
			LocationUtilities.leaveBus()
		default:
			break
		}
		completionHandler()
	}
	
}
