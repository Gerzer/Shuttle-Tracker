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
	
	@ObservedObject private var mapState = MapState.shared
	
	@ObservedObject private var viewState = ViewState.shared
	
	@ObservedObject private var sheetStack = SheetStack.shared
	
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
			Self.pushSheet(value)
		} conditions: {
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.4", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles, comparator: ==)
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(self.mapState)
				.environmentObject(self.viewState)
				.environmentObject(self.sheetStack)
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("\(self.sheetStack.top == .announcements ? "Hide" : "Show") Announcements") {
						if self.sheetStack.top == .announcements {
							self.sheetStack.pop()
						} else {
							self.sheetStack.push(.announcements)
						}
					}
						.keyboardShortcut(KeyEquivalent("a"), modifiers: [.command, .shift])
						.disabled(self.sheetStack.count > 0 && self.sheetStack.top != .announcements)
					Button("\(self.sheetStack.top == .whatsNew ? "Hide" : "Show") What’s New") {
						if self.sheetStack.top == .whatsNew {
							self.sheetStack.pop()
						} else {
							self.sheetStack.push(.whatsNew)
						}
					}
						.keyboardShortcut(KeyEquivalent("w"), modifiers: [.command, .shift])
						.disabled(self.sheetStack.count > 0 && self.sheetStack.top != .whatsNew)
					Divider()
					Button("Re-Center Map") {
						self.mapState.mapView?.setVisibleMapRect(MapUtilities.mapRect, animated: true)
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
				.frame(width: 400, height: 100)
				.environmentObject(self.viewState)
				.environmentObject(self.sheetStack)
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
	private static func pushSheet(_ sheetType: SheetStack.SheetType) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			SheetStack.shared.push(sheetType)
		}
	}
	
}
