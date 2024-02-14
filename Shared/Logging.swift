//
//  Logging.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/17/22.
//

import Foundation
import STLogging

enum Logging {
	
	typealias Log = LoggingSystem<Category>.Log
	
	enum Category: String, LoggingCategory {
		
		case api = "API"
		
		/// The category for logging interactions with the Apple Push Notification Service.
		case apns = "APNS"
		
		/// The category for logging method invocations in ``AppDelegate``.
		case appDelegate = "AppDelegate"
		
		case boardBus = "BoardBus"
		
		/// The default category.
		case general = "General"
		
		case location = "Location"
		
		/// The category for logging method invocations in ``LocationManagerDelegate``.
		case locationManagerDelegate = "LocationManagerDelegate"
		
		case mailCompose = "MailCompose"
		
		/// The category for logging method invocations in ``MailComposeViewControllerDelegate``.
		case mailComposeViewControllerDelegate = "MailComposeViewControllerDelegate"
		
		case permissions = "Permissions"
		
		/// The category for logging method invocations in ``UserNotificationCenterDelegate``.
		case userNotificationCenterDelegate = "UserNotificationCenterDelegate"
		
		static var `default`: Self = .general
		
	}
	
	static let system = LoggingSystem(configurationProvider: AppStorageManager.shared, uploader: API.self)
	
}

extension Logging.Log: RawRepresentableInJSONArray { }

extension API: LogUploader {
	
	typealias CategoryType = Logging.Category
	
	static func upload(log: Logging.Log) async throws -> UUID {
		return try await self.uploadLog(log: log).perform(as: UUID.self)
	}
	
}
