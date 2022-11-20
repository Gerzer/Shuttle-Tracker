//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/11/20.
//

import SwiftUI
import CoreLocation
import OnboardingKit

@main struct ShuttleTrackerApp: App {
	
	private static let sheetStack = SheetStack()
	
	@ObservedObject private var mapState = MapState.shared
	
	@ObservedObject private var viewState = ViewState.shared
	
	@ObservedObject private var boardBusManager = BoardBusManager.shared
	
	@ObservedObject private var appStorageManager = AppStorageManager.shared
	
	private let onboardingManager = OnboardingManager(flags: ViewState.shared) { (flags) in
		OnboardingEvent(flags: flags, value: SheetStack.SheetType.privacy, handler: Self.pushSheet(_:)) {
			OnboardingConditions.ColdLaunch(threshold: 1)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
			OnboardingConditions.ColdLaunch(threshold: 3)
			OnboardingConditions.ColdLaunch(threshold: 5)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .tip) {
			OnboardingConditions.ColdLaunch(threshold: 3)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .reminder) {
			OnboardingConditions.ColdLaunch(threshold: 5)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .boardBus) {
			OnboardingConditions.ManualCounter(defaultsKey: "TripCount", threshold: 0, settingHandleAt: \.tripCount, in: flags.handles, comparator: ==)
			OnboardingConditions.Disjunction {
				OnboardingConditions.ColdLaunch(threshold: 3, comparator: >)
				OnboardingConditions.TimeSinceFirstLaunch(threshold: 172800)
			}
		}
		OnboardingEvent(flags: flags, value: SheetStack.SheetType.whatsNew, handler: Self.pushSheet(_:)) {
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.5", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles, comparator: ==)
			OnboardingConditions.ColdLaunch(threshold: 1, comparator: >)
		}
		OnboardingEvent(flags: flags) { (_) in
			LocationUtilities.registerLocationManagerHandler { (locationManager) in
				switch locationManager.authorizationStatus {
				case .notDetermined, .restricted, .denied:
					Self.pushSheet(.permissions)
				case .authorizedWhenInUse, .authorizedAlways:
					break
				@unknown default:
					fatalError()
				}
			}
		} conditions: {
			OnboardingConditions.ColdLaunch(threshold: 1, comparator: >)
		}
		OnboardingEvent(flags: flags) { (_) in
			if AppStorageManager.shared.maximumStopDistance == 20 {
				AppStorageManager.shared.maximumStopDistance = 50
			}
		} conditions: {
			OnboardingConditions.Once(defaultsKey: "UpdatedMaximumStopDistance")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.boardBusManager)
				.environmentObject(self.appStorageManager)
				.environmentObject(Self.sheetStack)
		}
	}
	
	init() {
		Logging.withLogger { (logger) in
			let formattedVersion: String
			if let version = Bundle.main.version {
				formattedVersion = " \(version)"
			} else {
				formattedVersion = ""
			}
			let formattedBuild: String
			if let build = Bundle.main.build {
				formattedBuild = " (\(build))"
			} else {
				formattedBuild = ""
			}
			logger.log("[\(#fileID):\(#line) \(#function)] Shuttle Tracker for iOS\(formattedVersion)\(formattedBuild)")
		}
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
		LocationUtilities.locationManager.showsBackgroundLocationIndicator = true
		LocationUtilities.locationManager.allowsBackgroundLocationUpdates = true
		Task {
			do {
				try await UserNotificationUtilities.requestAuthorization()
			} catch let error {
				Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function)] Failed to request notification authorization: \(error)")
				}
				throw error
			}
		}
	}
	
	private static func pushSheet(_ sheetType: SheetStack.SheetType) {
		Task {
			do {
				if #available(iOS 16, *) {
					try await Task.sleep(for: .seconds(1))
				} else {
					try await Task.sleep(nanoseconds: 1_000_000_000)
				}
			} catch let error {
				Logging.withLogger(doUpload: true) { (logger) in
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function)] Task sleep error: \(error)")
				}
				throw error
			}
			self.sheetStack.push(sheetType)
		}
	}
	
}
