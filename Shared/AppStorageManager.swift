//
//  AppStorageManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/27/22.
//

import SwiftUI

final class AppStorageManager {
	
	static let shared = AppStorageManager()
	
	@AppStorage("MaximumStopDistance") var maximumStopDistance = 50
	
	private init() { }
	
}
