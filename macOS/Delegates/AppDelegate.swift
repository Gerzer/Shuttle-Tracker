//
//  AppDelegate.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 2/22/22.
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		return true
	}
	
}
