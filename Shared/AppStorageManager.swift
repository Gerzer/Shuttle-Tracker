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
        
        static let boardBusCount = 0
		
		static let baseURL = URL(string: "https://shuttletracker.app")!
		
		static let viewedAnnouncementIDs: Set<UUID> = []
		
		static let doUploadLogs = true
		
		static let uploadedLogs: [Logging.Log] = []
		
        static let uploadedAnalytics: [Analytics] = []
	}
	
	static let shared = AppStorageManager()
	
	@AppStorage("ColorBlindMode")
	var colorBlindMode = Defaults.colorBlindMode
	
	@AppStorage("MaximumStopDistance")
	var maximumStopDistance = Defaults.maximumStopDistance
    
    @AppStorage("BoardBusCount")
    var boardBusCount = Defaults.boardBusCount
	
	@AppStorage("BaseURL")
	var baseURL = Defaults.baseURL
	
	@AppStorage("ViewedAnnouncementIDs")
	var viewedAnnouncementIDs = Defaults.viewedAnnouncementIDs
	
	@AppStorage("DoUploadLogs")
	var doUploadLogs = Defaults.doUploadLogs
	
	@AppStorage("UploadedLogs")
	var uploadedLogs = Defaults.uploadedLogs
    
    @AppStorage("UploadedAnalytics")
    var uploadedAnalytics = Defaults.uploadedAnalytics
	
	private init() { }
	
}
