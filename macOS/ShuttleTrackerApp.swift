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
		OnboardingEvent(flags: flags, settingFlagAt: \.sheetType, to: .whatsNew) {
			OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.1", threshold: 0, settingHandleAt: \.whatsNew, in: flags.handles, comparator: ==)
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(MapState.shared)
				.environmentObject(ViewState.shared)
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("Refresh") {
						NotificationCenter.default.post(name: .refreshBuses, object: nil)
					}
						.keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
					Divider()
				}
			}
		Settings {
			SettingsView()
				.padding()
				.frame(width: 400, height: 100)
				.environmentObject(ViewState.shared)
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
}
