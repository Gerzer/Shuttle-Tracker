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
						self.mapState.mapView?.setVisibleMapRect(
							self.mapState.routes.boundingMapRect,
							edgePadding: MapUtilities.Constants.mapRectInsets,
							animated: true
						)
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
				.frame(minWidth: 300, minHeight: 150)
				.environmentObject(self.viewState)
				.environmentObject(Self.settingsViewSheetStack)
		}
	}
	
	init() {
		LocationUtilities.locationManager = CLLocationManager()
		LocationUtilities.locationManager.requestWhenInUseAuthorization()
		LocationUtilities.locationManager.activityType = .automotiveNavigation
	}
	
	private static func pushSheet(_ sheetType: SheetStack.SheetType, to sheetStack: SheetStack) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			sheetStack.push(sheetType)
		}
	}
	
}
