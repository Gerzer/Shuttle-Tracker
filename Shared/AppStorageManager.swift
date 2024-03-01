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
		
		static let userID = UUID()
		
		static let colorBlindMode = false
		
		static let maximumStopDistance = 50
		
		static let boardBusCount = 0
		
		static let baseURL = URL(string: "https://shuttletracker.app")!
		
		static let viewedAnnouncementIDs: Set<UUID> = []
		
		static let doUploadLogs = true
		
		static let doCollectAnalytics = false
		
		static let uploadedLogs: [Logging.Log] = []
		
		static let uploadedAnalyticsEntries: [Analytics.Entry] = []
		
		static let routeTolerance = 10
		
	}
	
	static let shared = AppStorageManager()
	
	@AppStorage("UserID")
	var userID = Defaults.userID
	
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
	
	@AppStorage("DoCollectAnalytics")
	var doCollectAnalytics = Defaults.doCollectAnalytics
	
	@AppStorage("UploadedLogs")
	var uploadedLogs = Defaults.uploadedLogs
	
	@AppStorage("UploadedAnalyticsEntries")
	var uploadedAnalyticsEntries = Defaults.uploadedAnalyticsEntries
	
	@AppStorage("RouteTolerance")
	var routeTolerance = Defaults.routeTolerance
	
	private init() { }
	
}
