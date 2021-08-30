//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import SwiftUI

@main struct ShuttleTrackerApp: App {
	
	private var contentView = ContentView()
	
	var body: some Scene {
		WindowGroup {
			self.contentView
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("Refresh") {
						self.contentView.refreshBuses()
					}
						.keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
				}
			}
	}
	
	init() {
		let coldLaunchCount = UserDefaults.standard.integer(forKey: DefaultsKeys.coldLaunchCount)
		UserDefaults.standard.set(coldLaunchCount + 1, forKey: DefaultsKeys.coldLaunchCount)
	}
	
}
