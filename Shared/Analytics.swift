//
//  Analytics.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/14/23.
//

import Foundation
import SwiftUI

protocol EventPayload : Codable, Equatable, Hashable { }

struct Payload : EventPayload { }

extension String : EventPayload { }

extension Int : EventPayload { }

extension Bool : EventPayload { }

struct UserSettings: Codable, Hashable, Equatable {
    let colorTheme: String
    let colorBlindMode: Bool
    let debugMode: Bool?
    let logging: Bool
    let maximumStopDistance: Int?
    let serverBaseURL: URL
}

public enum Analytics {
    struct AnalyticsEntry : DataCollectionProtocol, Hashable, Identifiable, Equatable {
        init(_ eventType: [String : [ String : Payload ]]) async {
            self.id = UUID()
            self.userID = UUID()
            
            #if os(iOS)
            if let id = await UUID(uuidString: UIDevice.current.identifierForVendor?.uuidString ?? "") {
                self.userID = id
            }
            #endif
            
            self.eventType = eventType
            #if os(macOS)
                self.clientPlatform = .macos
            #elseif os(iOS) // os(macOS)
                self.clientPlatform = .ios
            #endif // os(iOS)
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
            #endif
            self.userSettings = UserSettings(colorTheme: colorTheme, colorBlindMode: colorBlindMode,
                                             debugMode: debugMode, logging: logging, maximumStopDistance: maximumStopDistance,
                                             serverBaseURL: serverBaseURL)
        }
        
        enum ClientPlatform: String, Codable, Hashable, Equatable {
            case ios, macos
        }
        
        public fileprivate(set) var id: UUID
        var userID: UUID
        let date: Date
        let clientPlatform: ClientPlatform
        let clientPlatformVersion: String
        let appVersion: String
        let boardBusCount: Int?
        let userSettings: UserSettings
        let eventType: [String : [ String : Payload ]]
    }
    
    func uploadAnalytics(eventType: [String : [ String : Payload ]]) async throws {
        var entry = await AnalyticsEntry(eventType)
        
        entry.id = try await API.uploadAnalytics(analytics: entry).perform(as: UUID.self)
        let immutableSelf = entry
        
        await MainActor.run {
            #if os(iOS)
            withAnimation {
                AppStorageManager.shared.uploadedAnalytics.append(immutableSelf)
            }
            #elseif os(macOS) // os(iOS)
            AppStorageManager.shared.uploadedAnalytics.append(immutableSelf)
            #endif // os(macOS)
        }
    }
}
