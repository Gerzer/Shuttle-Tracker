//
//  Analytics.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/14/23.
//

import Foundation
import SwiftUI

struct Payload: Codable, Hashable {
    var value: AnyHashable

    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        init?(stringValue: String) { self.stringValue = stringValue }
    }

    init(_ value: AnyHashable) {
        self.value = value
    }
    
    init(from decoder: Decoder) {
        if let container = try? decoder.singleValueContainer() {
            if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                value = "invalid"
            }
        } else {
            value = "invalid"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        }
    }
}

struct UserSettings: Codable, Hashable, Equatable {
    let colorTheme: String
    let colorBlindMode: Bool
    let debugMode: Bool?
    let logging: Bool?
    let maximumStopDistance: Int?
    let serverBaseURL: URL?
}

public enum Analytics {
    struct AnalyticsEntry : DataCollectionProtocol, Hashable, Identifiable, Equatable {
        
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
        let eventType: [String : [ String : Payload ]]
        
        init(_ eventType: [String : [ String : Payload ]]) async {
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
            self.userSettings = UserSettings(colorTheme: colorTheme, colorBlindMode: colorBlindMode,
                                             debugMode: debugMode, logging: logging, maximumStopDistance: maximumStopDistance,
                                             serverBaseURL: serverBaseURL)
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
    
    static func uploadAnalytics(_ eventType: [String : [ String : Payload ]]) async throws {
        if(!(await AppStorageManager.shared.doUploadAnalytics)) {
            return;
        }
        
        do {
            let entry = try await API.uploadAnalytics(analytics: await AnalyticsEntry(eventType)).perform(as: AnalyticsEntry.self)
            
            await MainActor.run {
                #if os(iOS)
                withAnimation {
                    AppStorageManager.shared.uploadedAnalytics.append(entry)
                }
                #elseif os(macOS) // os(iOS)
                AppStorageManager.shared.uploadedAnalytics.append(entry)
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
