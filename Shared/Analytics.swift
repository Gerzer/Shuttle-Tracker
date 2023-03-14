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
		
		let colorScheme: String?
		
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
		
		let id: UUID
		
		let userID: UUID
		
		let date: Date
		
		let clientPlatform: ClientPlatform
		
		let clientPlatformVersion: String
		
		let appVersion: String
		
		let boardBusCount: Int?
		
		let userSettings: UserSettings
		
		let eventType: EventType
		
		var jsonString: String {
			get throws {
				let encoder = JSONEncoder(dateEncodingStrategy: .iso8601)
				let json = try encoder.encode(self)
				let jsonObject = try JSONSerialization.jsonObject(with: json)
				let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
				return String(data: data, encoding: .utf8) ?? ""
			}
		}
		
		init(_ eventType: EventType) async {
			self.id = UUID()
			self.userID = await AppStorageManager.shared.userID
			self.eventType = eventType
			#if os(iOS)
			self.clientPlatform = .ios
			#elseif os(macOS) // os(iOS)
			self.clientPlatform = .macos
			#endif // os(macOS)
			self.date = .now
			self.clientPlatformVersion = Bundle.main.version ?? ""
			self.appVersion = Bundle.main.build ?? ""
			#if os(iOS)
			self.boardBusCount = await AppStorageManager.shared.boardBusCount
			#else // os(iOS)
			self.boardBusCount = 0
			#endif
			let colorScheme: String?
			switch await ViewState.shared.colorScheme {
			case .light:
				colorScheme = "light"
			case .dark:
				colorScheme = "dark"
			case .none:
				colorScheme = nil
			@unknown default:
				fatalError()
			}
			var debugMode: Bool?
			var maximumStopDistance: Int?
			#if os(iOS)
			debugMode = false // TODO: Set properly once the Debug Mode implementation is merged
			maximumStopDistance = await AppStorageManager.shared.maximumStopDistance
			#endif // os(iOS)
			self.userSettings = UserSettings(
				colorScheme: colorScheme,
				colorBlindMode: await AppStorageManager.shared.colorBlindMode,
				debugMode: debugMode,
				logging: await AppStorageManager.shared.doUploadLogs,
				maximumStopDistance: maximumStopDistance,
				serverBaseURL: await AppStorageManager.shared.baseURL
			)
		}
		
		@available(iOS 16, macOS 13, *)
		func writeToDisk() throws -> URL {
			let url = FileManager.default.temporaryDirectory.appending(component: "\(self.id.uuidString).json")
			do {
				try self.jsonString.write(to: url, atomically: false, encoding: .utf8)
			} catch let error {
				Logging.withLogger(doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to save analytics entry file to temporary directory: \(error, privacy: .public)")
				}
			}
			return url
		}
		
	}
	
	static func upload(eventType: EventType) async throws {
		guard await AppStorageManager.shared.doCollectAnalytics else {
			return
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
	
}
