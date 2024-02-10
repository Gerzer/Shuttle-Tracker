//
//  ShuttleTrackerApp.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/3/24.
//

import SwiftUI

@main
struct ShuttleTrackerApp: App {
    
    @State
    private var mapCameraPosition: MapCameraPositionWrapper = .default
    
    @ObservedObject
    private var mapState = MapState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(mapCameraPosition: self.$mapCameraPosition)
                .environmentObject(self.mapState)
        }
    }
}
