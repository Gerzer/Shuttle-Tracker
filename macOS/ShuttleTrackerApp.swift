//
//  ShuttleTrackerApp.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import CoreLocation
import OnboardingKit
import STLogging
import SwiftUI
import UserNotifications

@main
struct ShuttleTrackerApp: App {
	
	@State
	private var mapCameraPosition: MapCameraPositionWrapper = .default
	
	@ObservedObject
	private var mapState = MapState.shared
	
	@ObservedObject
	private var viewState = ViewState.shared
	
	@ObservedObject
	private var appStorageManager = AppStorageManager.shared
	
	static let contentViewSheetStack = ShuttleTrackerSheetStack()
	
	static let settingsViewSheetStack = ShuttleTrackerSheetStack()
	
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
		OnboardingEvent(flags: flags, value: ShuttleTrackerSheetPresentationProvider.SheetType.whatsNew(onboarding: true)) { (value) in
			Self.pushSheet(value, to: Self.contentViewSheetStack)
		} conditions: {
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew2.0", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles)
		}
		OnboardingEvent(flags: flags) { (_) in
			if #available(macOS 13, *) {
				if AppStorageManager.shared.baseURL.host() == "shuttletracker.app" {
					guard var components = URLComponents(url: AppStorageManager.shared.baseURL, resolvingAgainstBaseURL: false) else {
						#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Can’t get components of current server base URL (“\(AppStorageManager.shared.baseURL, privacy: .public)”)")
						return
					}
					components.host = "shuttles.rpi.edu"
					do {
						AppStorageManager.shared.baseURL = try components.asURL()
					} catch {
						#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to construct new server base URL: \(error, privacy: .public)")
					}
				}
			}
		} conditions: {
			OnboardingConditions.Once(defaultsKey: "UpdatedServerBaseURL")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(mapCameraPosition: self.$mapCameraPosition)
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
							await self.mapState.recenter(position: self.$mapCameraPosition)
						}
					}
						.keyboardShortcut(KeyEquivalent("C"), modifiers: [.command, .shift])
					Button("Refresh") {
						if #available(macOS 13, *) {
							Task {
								await self.viewState.refreshSequence.trigger()
							}
						} else {
							NotificationCenter.default.post(name: .refreshBuses, object: nil)
						}
					}
						.keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
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
		let formattedVersion = if let version = Bundle.main.version { " \(version)" } else { "" }
		let formattedBuild = if let build = Bundle.main.build { " (\(build))" } else { "" }
		#log(system: Logging.system, "Shuttle Tracker for macOS\(formattedVersion, privacy: .public)\(formattedBuild, privacy: .public)")
		CLLocationManager.default = CLLocationManager()
		CLLocationManager.default.requestWhenInUseAuthorization()
		CLLocationManager.default.activityType = .automotiveNavigation
		NSApplication.shared.registerForRemoteNotifications()
		Task {
			do {
				try await UNUserNotificationCenter.requestDefaultAuthorization()
			} catch {
				#log(system: Logging.system, category: .permissions, level: .error, doUpload: true, "Failed to request notification authorization: \(error, privacy: .public)")
			}
		}
	}
	
	private static func pushSheet(_ sheetType: ShuttleTrackerSheetPresentationProvider.SheetType, to sheetStack: ShuttleTrackerSheetStack) {
		Task {
			do {
				if #available(macOS 13, *) {
					try await Task.sleep(for: .seconds(1))
				} else {
					try await Task.sleep(nanoseconds: 1_000_000_000)
				}
			} catch {
				#log(system: Logging.system, level: .error, doUpload: true, "Task sleep failed: \(error, privacy: .public)")
				throw error
			}
			sheetStack.push(sheetType)
		}
	}
	
}

fileprivate struct AnnouncementsCommandView: View {
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		Button("\(.announcements ~= self.sheetStack.top ? "Hide" : "Show") Announcements") {
			if case .announcements = self.sheetStack.top {
				self.sheetStack.pop()
			} else {
				self.sheetStack.push(.announcements)
			}
		}
			.keyboardShortcut(KeyEquivalent("a"), modifiers: [.command, .shift])
			.disabled(self.sheetStack.count > 0 && !(.announcements ~= self.sheetStack.top))
	}
	
}

fileprivate struct WhatsNewCommandView: View {
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	private var isWhatsNewSheetOnTop: Bool {
		get {
			switch self.sheetStack.top {
			case .whatsNew:
				return true
			default:
				return false
			}
		}
	}
	
	var body: some View {
		Button("\(self.isWhatsNewSheetOnTop ? "Hide" : "Show") What’s New") {
			if case .whatsNew = self.sheetStack.top {
				self.sheetStack.pop()
			} else {
				self.sheetStack.push(.whatsNew(onboarding: false))
			}
		}
			.disabled(self.sheetStack.count > 0 && !self.isWhatsNewSheetOnTop)
	}
	
}

fileprivate struct PrivacyCommandView: View {
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		Button("\(.privacy ~= self.sheetStack.top ? "Hide" : "Show") Privacy Information") {
			if case .privacy = self.sheetStack.top {
				self.sheetStack.pop()
			} else {
				self.sheetStack.push(.privacy)
			}
		}
			.disabled(self.sheetStack.count > 0 && !(.privacy ~= self.sheetStack.top))
	}
	
}
