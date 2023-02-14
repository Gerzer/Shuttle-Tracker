//
//  Analytics.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/14/23.
//

import Foundation
import SwiftUI

protocol EventPayload : Codable { }

struct Payload : EventPayload { }

extension String : EventPayload { }

extension Int : EventPayload { }

extension Bool : EventPayload { }

struct UserSettings: Codable {
    let colorTheme: String
    let colorBlindMode: Bool
    let debugMode: Bool?
    let logging: Bool
    let maximumStopDistance: Int?
    let serverBaseURL: URL
}

struct Analytics : Codable {
    init(userID: UUID, colorScheme: ColorScheme, eventType: [String : [ String : Payload ]], appStorageManager: AppStorageManager) async {
        self.id = UUID()
        self.userID = userID
        self.eventType = eventType
        #if os(macOS)
        self.clientPlatform = .macos
        #elseif os(iOS) // os(macOS)
        self.clientPlatform = .ios
        #endif // os(iOS)
        self.date = .now
        self.clientPlatformVersion = Bundle.main.version ?? ""
        self.appVersion = Bundle.main.build ?? ""
        
        let colorTheme = colorScheme == .dark ? "dark" : "light"
        let colorBlindMode = await appStorageManager.colorBlindMode
        let logging = await appStorageManager.doUploadLogs
        let serverBaseURL = await appStorageManager.baseURL
        var maximumStopDistance: Int?
        var debugMode: Bool?
        self.boardBusCount = nil
        #if os(iOS)
        maximumStopDistance = await appStorageManager.maximumStopDistance
        debugMode = false
        self.boardBusCount = await appStorageManager.boardBusCount
        #endif
        self.userSettings = UserSettings(colorTheme: colorTheme, colorBlindMode: colorBlindMode,
                                         debugMode: debugMode, logging: logging, maximumStopDistance: maximumStopDistance,
                                         serverBaseURL: serverBaseURL)
    }
    
    enum ClientPlatform: String, Codable {
        case ios, macos
    }
    
    public fileprivate(set) var id: UUID
    let userID: UUID
    let date: Date
    let clientPlatform: ClientPlatform
    let clientPlatformVersion: String
    let appVersion: String
    let boardBusCount: Int?
    let userSettings: UserSettings
    let eventType: [String : [ String : Payload ]]
}
