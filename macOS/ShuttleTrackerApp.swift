//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI
import CoreLocation
import OnboardingKit

@main struct ShuttleTrackerApp: App {
	
	private static let contentViewSheetStack = SheetStack()
	
	private static let settingsViewSheetStack = SheetStack()
	
	@ObservedObject private var mapState = MapState.shared
	
	@ObservedObject private var viewState = ViewState.shared
	
	@ObservedObject private var appStorageManager = AppStorageManager.shared
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	
	private let onboardingManager = OnboardingManager(flags: ViewState.shared) { (flags) in
		OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
			OnboardingConditions.Disjunction {
				OnboardingConditions.ColdLaunch(threshold: 1)
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .tip) {
			OnboardingConditions.ColdLaunch(threshold: 1)
		}
		OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .reminder) {
			OnboardingConditions.ColdLaunch(threshold: 3)
		}
		OnboardingEvent(flags: flags, value: SheetStack.SheetType.whatsNew) { (value) in
			Self.pushSheet(value, to: Self.contentViewSheetStack)
		} conditions: {
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.5", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles, comparator: ==)
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.appStorageManager)
				.environmentObject(Self.contentViewSheetStack)
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("\(Self.contentViewSheetStack.top == .announcements ? "Hide" : "Show") Announcements") {
						if Self.contentViewSheetStack.top == .announcements {
							Self.contentViewSheetStack.pop()
						} else {
							Self.contentViewSheetStack.push(.announcements)
						}
					}
						.keyboardShortcut(KeyEquivalent("a"), modifiers: [.command, .shift])
						.disabled(Self.contentViewSheetStack.count > 0 && Self.contentViewSheetStack.top != .announcements)
					Button("\(Self.contentViewSheetStack.top == .whatsNew ? "Hide" : "Show") What’s New") {
						if Self.contentViewSheetStack.top == .whatsNew {
							Self.contentViewSheetStack.pop()
						} else {
							Self.contentViewSheetStack.push(.whatsNew)
						}
					}
						.keyboardShortcut(KeyEquivalent("w"), modifiers: [.command, .shift])
						.disabled(Self.contentViewSheetStack.count > 0 && Self.contentViewSheetStack.top != .whatsNew)
					Divider()
					Button("Re-Center Map") {
						Task {
							await self.mapState.resetVisibleMapRect()
						}
					}
						.keyboardShortcut(KeyEquivalent("c"), modifiers: [.command, .shift])
					Button("Refresh") {
						NotificationCenter.default.post(name: .refreshBuses, object: nil)
					}
						.keyboardShortcut(KeyEquivalent("r"), modifiers: [.command])
					Divider()
				}
				CommandGroup(replacing: .newItem) { }
			}
		Settings {
			SettingsView()
				.padding()
				.frame(minWidth: 700, minHeight: 300)
				.environmentObject(self.viewState)
				.environmentObject(self.appStorageManager)
				.environmentObject(Self.settingsViewSheetStack)
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
			logger.log("[\(#fileID):\(#line) \(#function)] Shuttle Tracker for macOS\(formattedVersion)\(formattedBuild)")
		}
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
	private static func pushSheet(_ sheetType: SheetStack.SheetType, to sheetStack: SheetStack) {
		Task {
			do {
				if #available(macOS 13, *) {
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
			sheetStack.push(sheetType)
		}
	}
	
}
