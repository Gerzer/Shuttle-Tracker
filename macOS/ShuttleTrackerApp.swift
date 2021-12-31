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
	
	private var contentView = ContentView()
	
	private let onboardingManager: OnboardingManager<ViewState> = {
		return OnboardingManager(flags: ViewState.shared) { (flags) in
			OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
				OnboardingConditions.ColdLaunch(threshold: 1)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.onboardingToastHeadlineText, to: .tip) {
				OnboardingConditions.ColdLaunch(threshold: 1)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.onboardingToastHeadlineText, to: .reminder) {
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.sheetType, to: .whatsNew) {
				OnboardingConditions.ManualCounter(defaultsKey: "WhatsNew1.1", threshold: 0, settingHandleAt: \.whatsNewHandle, in: flags, comparator: ==)
			}
		}
	}()
	
	var body: some Scene {
		WindowGroup {
			self.contentView
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

