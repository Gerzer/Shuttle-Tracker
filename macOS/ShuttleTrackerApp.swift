//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import CoreLocation
import OnboardingKit
import SwiftUI

@main
struct ShuttleTrackerApp: App {
	
	@ObservedObject
	private var mapState = MapState.shared
	
	@ObservedObject
	private var viewState = ViewState.shared
	
	@ObservedObject
	private var appStorageManager = AppStorageManager.shared
	
	private static let contentViewSheetStack = SheetStack()
	
	private static let settingsViewSheetStack = SheetStack()
	
	@NSApplicationDelegateAdaptor(AppDelegate.self)
	private var appDelegate
	
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
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.6", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles)
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
					Group {
						// Extract commands into separate view to work around a bug in SwiftUI (https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug)
						AnnouncementsCommandView()
						WhatsNewCommandView()
						PrivacyCommandView()
					}
						.environmentObject(Self.contentViewSheetStack)
					Divider()
					Button("Re-Center Map") {
						Task {
							await self.mapState.resetVisibleMapRect()
						}
					}
						.keyboardShortcut(KeyEquivalent("c"), modifiers: [.command, .shift])
					Button("Refresh") {
						if #available(macOS 13, *) {
							Task {
								await self.viewState.refreshSequence.trigger()
							}
						} else {
							NotificationCenter.default.post(name: .refreshBuses, object: nil)
						}
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
			logger.log("[\(#fileID):\(#line) \(#function, privacy: .public)] Shuttle Tracker for macOS\(formattedVersion, privacy: .public)\(formattedBuild, privacy: .public)")
		}
		CLLocationManager.default = CLLocationManager()
		CLLocationManager.default.requestWhenInUseAuthorization()
		CLLocationManager.default.activityType = .automotiveNavigation
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
					logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Task sleep error: \(error, privacy: .public)")
				}
				throw error
			}
			sheetStack.push(sheetType)
		}
	}
	
}

fileprivate struct AnnouncementsCommandView: View {
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		Button("\(self.sheetStack.top ~= .announcements ? "Hide" : "Show") Announcements") {
			if case .announcements = self.sheetStack.top {
				self.sheetStack.pop()
			} else {
				self.sheetStack.push(.announcements)
			}
		}
			.keyboardShortcut(KeyEquivalent("a"), modifiers: [.command, .shift])
			.disabled(self.sheetStack.count > 0 && !(self.sheetStack.top ~= .announcements))
	}
	
}

fileprivate struct WhatsNewCommandView: View {
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		Button("\(self.sheetStack.top ~= .whatsNew ? "Hide" : "Show") What’s New") {
			if case .whatsNew = self.sheetStack.top {
				self.sheetStack.pop()
			} else {
				self.sheetStack.push(.whatsNew)
			}
		}
			.disabled(self.sheetStack.count > 0 && !(self.sheetStack.top ~= .whatsNew))
	}
	
}

fileprivate struct PrivacyCommandView: View {
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		Button("\(self.sheetStack.top ~= .privacy ? "Hide" : "Show") Privacy Information") {
			if case .privacy = self.sheetStack.top {
				self.sheetStack.pop()
			} else {
				self.sheetStack.push(.privacy)
			}
		}
			.disabled(self.sheetStack.count > 0 && !(self.sheetStack.top ~= .privacy))
	}
	
}
