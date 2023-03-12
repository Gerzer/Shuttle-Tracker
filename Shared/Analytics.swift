//
//  Analytics.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/14/23.
//

import Foundation
import SwiftUI

public enum Analytics {
	
	enum EventType: Codable, Hashable {
		
		case coldLaunch
		
		case boardBusTapped
		
		case leaveBusTapped
		
		case boardBusActivated(manual: Bool)
		
		case boardBusDeactivated(manual: Bool)
		
		case busSelectionCanceled
		
		case announcementsListOpened
		
		case announcementViewed(id: UUID)
		
		case permissionsSheetOpened
		
		case networkToastPermissionsTapped
		
		case colorBlindModeToggled(enabled: Bool)
		
		case debugModeToggled(enabled: Bool)
		
		case serverBaseURLChanged(url: URL)
		
		case locationAuthorizationStatusDidChange(authorizationStatus: Int)
		
		case locationAccuracyAuthorizationDidChange(accuracyAuthorization: Int)
		
	}
	
	struct UserSettings: Codable, Hashable, Equatable {
		
		let colorTheme: String
		
		let colorBlindMode: Bool
		
		let debugMode: Bool?
		
		let logging: Bool?
		
		let maximumStopDistance: Int?
		
		let serverBaseURL: URL?
		
	}
	
	struct Entry: Hashable, Identifiable, RawRepresentableInJSONArray {
		
		enum ClientPlatform: String, Codable, Hashable, Equatable {
			case ios, macos
		}
		
		public fileprivate(set) var id: UUID?
		
		var userID: UUID
		
		let date: Date
		
		let clientPlatform: ClientPlatform
		
		let clientPlatformVersion: String
		
		let appVersion: String
		
		let boardBusCount: Int?
		
		let userSettings: UserSettings
		
		let eventType: EventType
		
		init(_ eventType: EventType) async {
			self.userID = await AppStorageManager.shared.userID
			self.eventType = eventType
			#if os(macOS)
			self.clientPlatform = .macos
			#elseif os(iOS)
			self.clientPlatform = .ios
			#endif
			self.date = .now
			self.clientPlatformVersion = Bundle.main.version ?? ""
			self.appVersion = Bundle.main.build ?? ""
			
			let colorTheme = await AppStorageManager.shared.colorScheme == .dark ? "dark" : "light"
			let colorBlindMode = await AppStorageManager.shared.colorBlindMode
			let logging = await AppStorageManager.shared.doUploadLogs
			let serverBaseURL = await AppStorageManager.shared.baseURL
			var maximumStopDistance: Int?
			var debugMode: Bool?
			#if os(iOS)
			maximumStopDistance = await AppStorageManager.shared.maximumStopDistance
			debugMode = false
			self.boardBusCount = await AppStorageManager.shared.boardBusCount
			#else
			self.boardBusCount = 0
			#endif
			self.userSettings = UserSettings(
				colorTheme: colorTheme,
				colorBlindMode: colorBlindMode,
				debugMode: debugMode,
				logging: logging,
				maximumStopDistance: maximumStopDistance,
				serverBaseURL: serverBaseURL
			)
		}
		
		@available(iOS 16, macOS 13, *)
		func writeToDisk() throws -> URL {
			do {
				let url = FileManager.default.temporaryDirectory.appending(component: "\(self.id!.uuidString).analytics")
				do {
					try toJSONString(self).write(to: url, atomically: false, encoding: .utf8)
				} catch let error {
					Logging.withLogger(doUpload: true) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to save analytics file to temporary directory: \(error, privacy: .public)")
					}
					throw error
				}
				
				return url
			} catch let error {
				Logging.withLogger(doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to obtain analytics id: \(error, privacy: .public)")
				}
				throw error
			}
		}
		
	}
	
	static func upload(eventType: EventType) async throws {
		if(!(await AppStorageManager.shared.doUploadAnalytics)) {
			return;
		}
		do {
			let analyticsEntry = await Entry(eventType)
			try await API.uploadAnalyticsEntry(analyticsEntry: analyticsEntry).perform()
			await MainActor.run {
				#if os(iOS)
				withAnimation {
					AppStorageManager.shared.uploadedAnalyticsEntries.append(analyticsEntry)
				}
				#elseif os(macOS) // os(iOS)
				AppStorageManager.shared.uploadedAnalyticsEntries.append(analyticsEntry)
				#endif // os(macOS)
			}
		} catch {
			Logging.withLogger(for: .api, doUpload: true) { (logger) in
				logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
			}
		}
	}
	
	static func toJSONString(_ analytics: AnalyticsEntry) -> String {
		let encoder = JSONEncoder(dateEncodingStrategy: .iso8601)
		do {
			let json = try encoder.encode(analytics)
			let jsonObject = try JSONSerialization.jsonObject(with: json, options: [])
			let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
			
			return String(data: data, encoding: .utf8) ?? ""
		} catch {
			return ""
		}
	}
	
}
