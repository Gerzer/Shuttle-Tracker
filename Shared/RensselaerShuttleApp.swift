//
//  RensselaerShuttleApp.swift
//  Shared
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import SwiftUI

@main struct RensselaerShuttleApp: App {
	
	#if os(macOS)
	static let barPlacement = ToolbarItemPlacement.automatic
	#else
	static let barPlacement = ToolbarItemPlacement.bottomBar
	#endif
	
	var mapState = MapState()
	let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
	
	var body: some Scene {
		WindowGroup {
			MapView()
				.environmentObject(self.mapState)
				.ignoresSafeArea()
				.toolbar {
					ToolbarItem(placement: Self.barPlacement) {
						Button(action: self.refresh) {
							Image(systemName: "arrow.clockwise.circle.fill")
						}
					}
				}
				.onReceive(self.timer) { (_) in
					self.refresh()
				}
		}
	}
	
	func refresh() {
		self.mapState.buses.removeAll()
		Set<Bus>.download { (bus) in
			self.mapState.buses.insert(bus)
		}
	}
	
}
