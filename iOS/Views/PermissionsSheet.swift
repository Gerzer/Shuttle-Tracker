//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

struct PermissionsSheet: View {
	
	@State private var notificationAuthorizationStatus: UNAuthorizationStatus?
	
	@State private var locationScale: CGFloat = 0
	
	@State private var notificationScale: CGFloat = 0
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@Environment(\.openURL) private var openURL
	
	var body: some View {
		SheetPresentationWrapper {
			NavigationView {
				VStack(alignment: .leading) {
					Text("Shuttle Tracker requires access to your location to provide shuttle-tracking features and to improve data accuracy for everyone.")
						.padding(.bottom)
					Button("View Privacy Information") {
						self.sheetStack.push(.privacy)
					}
						.padding(.bottom)
					if #available(iOS 15, *) {
						VStack(alignment: .leading) {
							Group {
								switch (LocationUtilities.locationManager.authorizationStatus, LocationUtilities.locationManager.accuracyAuthorization) {
								case (.authorizedWhenInUse, .fullAccuracy), (.authorizedAlways, .fullAccuracy):
									HStack {
										Image(systemName: "gear.badge.checkmark")
											.resizable()
											.scaledToFit()
											.frame(width: 50, height: 50)
										Text("You’ve already granted location permission. Thanks!")
									}
								case (.restricted, _), (.denied, _):
									HStack {
										Image(systemName: "gear.badge.xmark")
											.resizable()
											.scaledToFit()
											.frame(width: 50, height: 50)
										Text("Shuttle Tracker doesn’t have location permission; you can change this in Settings.")
									}
								case (.notDetermined, _):
									HStack {
										Image(systemName: "gear.badge.questionmark")
											.resizable()
											.scaledToFit()
											.frame(width: 50, height: 50)
										Text("Tap “Continue” and then grant location permission.")
									}
								case (_, .reducedAccuracy):
									HStack {
										Image(systemName: "gear.badge.questionmark")
											.resizable()
											.scaledToFit()
											.frame(width: 50, height: 50)
										Text("Tap “Continue” and then grant full-accuracy location permission.")
									}
								@unknown default:
									fatalError()
								}
							}
								.scaleEffect(self.locationScale)
								.onAppear {
									withAnimation(.easeIn(duration: 0.5)) {
										self.locationScale = 1.3
									}
									withAnimation(.easeOut(duration: 0.2).delay(0.5)) {
										self.locationScale = 1
									}
								}
							if let notificationAuthorizationStatus = self.notificationAuthorizationStatus {
								Group {
									switch notificationAuthorizationStatus {
									case .authorized, .ephemeral:
										HStack {
											Image(systemName: "gear.badge.checkmark")
												.resizable()
												.scaledToFit()
												.frame(width: 50, height: 50)
											Text("You’ve already granted notification permission. Thanks!")
										}
									case .denied:
										HStack {
											Image(systemName: "gear.badge.xmark")
												.resizable()
												.scaledToFit()
												.frame(width: 50, height: 50)
											Text("Shuttle Tracker doesn’t have notification permission; you can change this in Settings.")
										}
									case .notDetermined, .provisional:
										HStack {
											Image(systemName: "gear.badge.questionmark")
												.resizable()
												.scaledToFit()
												.frame(width: 50, height: 50)
											switch (LocationUtilities.locationManager.authorizationStatus, LocationUtilities.locationManager.accuracyAuthorization) {
											case (.authorizedWhenInUse, .fullAccuracy), (.authorizedAlways, .fullAccuracy):
												Text("Tap “Continue” and then grant notification permission.")
											case (.notDetermined, _), (.restricted, _), (.denied, _), (_, .reducedAccuracy):
												Text("You haven’t yet granted notification permission.")
											@unknown default:
												fatalError()
											}
										}
									@unknown default:
										fatalError()
									}
								}
									.scaleEffect(self.notificationScale)
									.onAppear {
										withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
											self.notificationScale = 1.3
										}
										withAnimation(.easeOut(duration: 0.2).delay(1)) {
											self.notificationScale = 1
										}
									}
							}
						}
							.symbolRenderingMode(.multicolor)
							.task {
								self.notificationAuthorizationStatus = await UNUserNotificationCenter
									.current()
									.notificationSettings()
									.authorizationStatus
							}
					}
					Spacer()
					Button {
						switch (LocationUtilities.locationManager.authorizationStatus, LocationUtilities.locationManager.accuracyAuthorization) {
						case (.authorizedAlways, .fullAccuracy), (.authorizedWhenInUse, .fullAccuracy):
							if let notificationAuthorizationStatus = self.notificationAuthorizationStatus {
								switch notificationAuthorizationStatus {
								case .authorized, .ephemeral:
									break
								case .denied:
									let url = try! UIApplication.openSettingsURLString.asURL()
									self.openURL(url)
								case .notDetermined, .provisional:
									Task {
										do {
											try await UserNotificationUtilities.requestAuthorization()
										} catch let error {
											print("[PermissionSheet body] Notification authorization request error: \(error.localizedDescription)")
										}
									}
								@unknown default:
									fatalError()
								}
							}
						case (.restricted, _), (.denied, _):
							let url = try! UIApplication.openSettingsURLString.asURL()
							self.openURL(url)
						case (.notDetermined, _):
							LocationUtilities.locationManager.requestWhenInUseAuthorization()
						case (_, .reducedAccuracy):
							Task {
								do {
									try await LocationUtilities.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "BoardBus")
								} catch let error {
									print("[PermissionsSheet body] Full-accuracy location authorization request error: \(error.localizedDescription)")
								}
							}
						@unknown default:
							fatalError()
						}
						self.sheetStack.pop()
					} label: {
						Text("Continue")
							.bold()
					}
						.buttonStyle(BlockButtonStyle())
				}
					.padding()
					.navigationTitle("Permissions")
					.toolbar {
						ToolbarItem {
							CloseButton()
						}
					}
			}
		}
	}
	
}

struct PermissionsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		PermissionsSheet()
			.environmentObject(SheetStack())
	}
	
}
