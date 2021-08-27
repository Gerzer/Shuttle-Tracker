//
//  RensselaerShuttleApp.swift
//  Rensselaer Shuttle (App Clip)
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import SwiftUI
import StoreKit

@main struct RensselaerShuttleApp: App {
	
	@State private var doShowAppStoreOverlay = true
	
	var body: some Scene {
		WindowGroup {
			ContentView()
//				.appStoreOverlay(isPresented: self.$doShowAppStoreOverlay) { () -> SKOverlay.Configuration in
//					return SKOverlay.AppClipConfiguration(position: .bottomRaised)
//				}
		}
	}
	
}
