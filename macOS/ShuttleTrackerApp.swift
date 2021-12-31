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
		OnboardingManager(flags: ViewState.sharedInstance) { (flags) in
			OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
				OnboardingConditions.ColdLaunch(threshold: 1)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .tip) {
				OnboardingConditions.ColdLaunch(threshold: 1)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.legendToastHeadlineText, to: .reminder) {
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
		}
	}()
	
	var body: some Scene {
		WindowGroup {
			self.contentView
				.environmentObject(MapState.sharedInstance)
				.environmentObject(ViewState.sharedInstance)
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("Refresh") {
						NotificationCenter.default.post(name: .refreshBuses, object: nil)
					}
						.keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
				}
			}
		Settings {
			SettingsView()
				.padding()
				.frame(width: 400, height: 100)
				.environmentObject(ViewState.sharedInstance)
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
}

