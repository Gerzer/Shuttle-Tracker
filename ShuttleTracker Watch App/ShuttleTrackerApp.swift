//
//  ShuttleTrackerApp.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/3/24.
//

import SwiftUI
import CoreLocation
import UserNotifications

@main
struct ShuttleTrackerApp: App {
    
    @State
    private var mapCameraPosition: MapCameraPositionWrapper = .default
    
    @ObservedObject
    private var mapState = MapState.shared
    
    @ObservedObject
    private var appStorageManager = AppStorageManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(mapCameraPosition: self.$mapCameraPosition)
                .environmentObject(self.mapState)
                .environmentObject(self.appStorageManager)
        }
    }
    
    init() {
        CLLocationManager.default = CLLocationManager()
        CLLocationManager.default.activityType = .automotiveNavigation
        Task {
            do {
                try await UNUserNotificationCenter.requestDefaultAuthorization()
            } catch let error {
                Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
                    logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to request notification authorization: \(error, privacy: .public)")
                }
                throw error
            }
        }
    }
}
