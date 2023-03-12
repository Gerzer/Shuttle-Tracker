//
//  PermissionsSheet.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import CoreLocation
import SwiftUI

struct PermissionsSheet: View {
	
	@State
	private var notificationAuthorizationStatus: UNAuthorizationStatus?
	
	@State
	private var locationScale: CGFloat = 0
	
	@State
	private var notificationScale: CGFloat = 0
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	@Environment(\.openURL)
	private var openURL
	
	var body: some View {
		SheetPresentationWrapper {
			NavigationView {
				VStack(alignment: .leading) {
					Text("Shuttle Tracker requires access to your location to connect to the Shuttle Tracker Network, thereby improving data accuracy and tracking coverage for everyone.")
						.padding(.bottom)
						.accessibilityShowsLargeContentViewer()
					Button("Show Privacy Information") {
						self.sheetStack.push(.privacy)
					}
						.padding(.bottom)
					VStack(alignment: .leading) {
						Group {
							if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
								HStack(alignment: .top) {
									Image(systemName: "gear.badge.checkmark")
										.resizable()
										.scaledToFit()
										.frame(width: 40, height: 40)
									VStack(alignment: .leading) {
										Text("Location")
											.font(.headline)
										Text("You’ve already granted location access. Thanks!")
											.accessibilityShowsLargeContentViewer()
									}
								}
							} else {
								HStack(alignment: .top) {
									Image(systemName: "gear.badge.xmark")
										.resizable()
										.scaledToFit()
										.frame(width: 40, height: 40)
									VStack(alignment: .leading) {
										Text("Location")
											.font(.headline)
										Text(try! AttributedString(markdown: "Select **Always** location access and enable **Precise Location** in Settings."))
											.accessibilityShowsLargeContentViewer()
									}
								}
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
								case .authorized, .ephemeral, .provisional:
									HStack(alignment: .top) {
										Image(systemName: "gear.badge.checkmark")
											.resizable()
											.scaledToFit()
											.frame(width: 40, height: 40)
										VStack(alignment: .leading) {
											Text("Notifications")
												.font(.headline)
											Text("You’ve already enabled notification delivery. Thanks!")
												.accessibilityShowsLargeContentViewer()
										}
									}
								case .denied:
									HStack(alignment: .top) {
										Image(systemName: "gear.badge.xmark")
											.resizable()
											.scaledToFit()
											.frame(width: 40, height: 40)
										VStack(alignment: .leading) {
											Text("Notifications")
												.font(.headline)
											if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
												Text(try! AttributedString(markdown: "Enable **Allow Notifications** in Settings."))
													.accessibilityShowsLargeContentViewer()
											} else {
												Text("You haven’t yet enabled notification delivery.")
													.accessibilityShowsLargeContentViewer()
											}
										}
									}
								case .notDetermined:
									HStack(alignment: .top) {
										Image(systemName: "gear.badge.questionmark")
											.resizable()
											.scaledToFit()
											.frame(width: 40, height: 40)
										VStack(alignment: .leading) {
											Text("Notifications")
												.font(.headline)
											if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
												Text(try! AttributedString(markdown: "Tap **Continue** and then enable notification delivery."))
													.accessibilityShowsLargeContentViewer()
											} else {
												Text("You haven’t yet enabled notification delivery.")
													.accessibilityShowsLargeContentViewer()
											}
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
					Spacer()
					Button {
						if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
							if let notificationAuthorizationStatus = self.notificationAuthorizationStatus {
								switch notificationAuthorizationStatus {
								case .authorized, .ephemeral, .provisional:
									break
								case .denied:
									if #available(iOS 16, *) {
										self.openURL(URL(string: UIApplication.openNotificationSettingsURLString)!)
									} else {
										self.openURL(URL(string: UIApplication.openSettingsURLString)!)
									}
								case .notDetermined:
									Task {
										do {
											try await UNUserNotificationCenter.requestDefaultAuthorization()
										} catch let error {
											Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
												logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Notification authorization request failed: \(error, privacy: .public)")
											}
										}
									}
								@unknown default:
									fatalError()
								}
							} else {
								Logging.withLogger(for: .permissions, doUpload: true) { (logger) in
									logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Notification authorization status is not available")
								}
							}
						} else {
							self.openURL(URL(string: UIApplication.openSettingsURLString)!)
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
			.task {
				do {
					try await Analytics.upload(eventType: .permissionsSheetOpened)
				} catch let error {
					Logging.withLogger(for: .api, doUpload: true) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
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
