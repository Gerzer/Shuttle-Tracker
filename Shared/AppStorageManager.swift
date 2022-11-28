//
//  AppStorageManager.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/27/22.
//

import SwiftUI

@MainActor
final class AppStorageManager: ObservableObject {
	
	enum Defaults {
		
		static let colorBlindMode = false
		
		static let maximumStopDistance = 50
		
		static let baseURL = URL(string: "https://shuttletracker.app")!
		
		static let viewedAnnouncementIDs: Set<UUID> = []
		
		static let doUploadLogs = true
		
		static let uploadedLogs: [Logging.Log] = []
		
	}
	
	static let shared = AppStorageManager()
	
	@AppStorage("ColorBlindMode")
	var colorBlindMode = Defaults.colorBlindMode
	
	@AppStorage("MaximumStopDistance")
	var maximumStopDistance = Defaults.maximumStopDistance
	
	@AppStorage("BaseURL")
	var baseURL = Defaults.baseURL
	
	@AppStorage("ViewedAnnouncementIDs")
	var viewedAnnouncementIDs = Defaults.viewedAnnouncementIDs
	
	@AppStorage("DoUploadLogs")
	var doUploadLogs = Defaults.doUploadLogs
	
	@AppStorage("UploadedLogs")
	var uploadedLogs = Defaults.uploadedLogs
	
	private init() { }
	
}
