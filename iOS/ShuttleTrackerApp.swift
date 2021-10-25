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
	
	private var contentView = ContentView()
	
	private var onboardingManager: OnboardingManager<ViewState> = {
		OnboardingManager(flags: ViewState.sharedInstance) { (flags) in
			OnboardingEvent(flags: flags, settingFlagAt: \.sheetType, to: .privacy) {
				OnboardingConditions.ColdLaunch(threshold: 1)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.onboardingToastHeadlineText, to: .tip) {
				OnboardingConditions.ColdLaunch(threshold: 3)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.toastType, to: .legend) {
				OnboardingConditions.ColdLaunch(threshold: 5)
			}
			OnboardingEvent(flags: flags, settingFlagAt: \.onboardingToastHeadlineText, to: .reminder) {
				OnboardingConditions.ColdLaunch(threshold: 5)
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
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestAlwaysAuthorization()
		LocationUtilities.locationManager.allowsBackgroundLocationUpdates = true
		LocationUtilities.locationManager.activityType = .automotiveNavigation
		if #available(iOS 15, *) {
			Task(priority: .high) {
				try await UNUserNotificationCenter.current()
					.requestAuthorization(options: [.alert, .badge, .sound])
			}
		} else {
			UNUserNotificationCenter.current()
				.requestAuthorization(options: [.alert, .badge, .sound]) { (wasGranted, error) in
					if let error = error {
						LoggingUtilities.logger.log(level: .error, "\(error.localizedDescription)")
					}
					LoggingUtilities.logger.log(level: .info, "Notification permission \(wasGranted ? "was" : "wasn't") granted")
				}
		}
		let longTripCategory = UNNotificationCategory(
			identifier: NotificationUtilities.Constants.longTripCategoryIdentifier,
			actions: [
				UNNotificationAction(
					identifier: NotificationUtilities.Constants.leaveBusActionIdentifier,
					title: "Leave Bus",
					options: []
				)
			],
			intentIdentifiers: [],
			options: []
		)
		UNUserNotificationCenter.current()
			.setNotificationCategories([longTripCategory])
		UNUserNotificationCenter.current()
			.delegate = NotificationUtilities.userNotificationCenterDelegate
	}
	
}
