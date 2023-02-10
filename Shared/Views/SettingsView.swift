//
//  SettingsView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI
import ActivityKit
import Live_Activity

struct SettingsView: View {
	
	#if os(macOS)
	@State
	private var didResetServerBaseURL = false
	#endif // os(macOS)
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	var body: some View {
		#if os(iOS)
		SheetPresentationWrapper {
			Form {
				Section {
					HStack {
						ZStack {
							Circle()
								.fill(.green)
							Image(systemName: self.appStorageManager.colorBlindMode ? "scope" : "bus")
								.resizable()
								.frame(width: 15, height: 15)
								.foregroundColor(.white)
						}
							.frame(width: 30)
							.animation(.default, value: self.appStorageManager.colorBlindMode)
						Toggle("Color-Blind Mode", isOn: self.appStorageManager.$colorBlindMode)
							.accessibilityShowsLargeContentViewer()
					}
						.frame(height: 30)
				} footer: {
					Text("Modifies bus markers so that they’re distinguishable by icon in addition to color.")
				}
				#if !APPCLIP
				Section {
					Button("Show Permissions") {
						self.sheetStack.push(.permissions)
					}
				}
				#endif // !APPCLIP
				Section {
					NavigationLink("Logging & Analytics") {
						LoggingAnalyticsSettingsView()
					}
					NavigationLink("Advanced") {
						AdvancedSettingsView()
					}
				}
				Section {
					NavigationLink("About") {
						AboutView()
					}
				}
                
                if #available(iOS 16.2, *) {
//                    Section  {
//                        Button("Activate live activity") {
//                            if ActivityAuthorizationInfo().areActivitiesEnabled {
//                                // Create the activity attributes and activity content objects.
//                                // ...
//
//                               //let activityAttributes = ActivityAttributes(
//                                // Start the Live Activity.
//                                do {
//
//
//                                    deliveryActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
//                                    print("Requested a pizza delivery Live Activity \(String(describing: deliveryActivity?.id)).")
//                                } catch (let error) {
//                                    print("Error requesting pizza delivery Live Activity \(error.localizedDescription).")
//                                }
//                            }
//                        }
//                    }
                }
                
			}
		}
			.onChange(of: self.appStorageManager.colorBlindMode) { (_) in
				withAnimation {
					self.viewState.toastType = .legend
					self.viewState.legendToastHeadlineText = nil
				}
			}
		#elseif os(macOS) // os(iOS)
		TabView {
			Form {
				Section {
					Toggle("Distinguish bus markers by icon", isOn: self.appStorageManager.$colorBlindMode)
				}
				Divider()
				Section {
					HStack {
						// URL.FormatStyle’s integration with TextField seems to be broken currently, so we fall back on our custom URL format style
						TextField("Server Base URL", value: self.appStorageManager.$baseURL, format: .compatibilityURL)
							.labelsHidden()
						Button(role: .destructive) {
							self.appStorageManager.baseURL = AppStorageManager.Defaults.baseURL
							self.didResetServerBaseURL = true
						} label: {
							HStack {
								Text("Reset")
								if self.didResetServerBaseURL {
									Text("✓")
								}
							}
								.frame(minWidth: 50)
						}
							.disabled(self.appStorageManager.baseURL == AppStorageManager.Defaults.baseURL)
							.onChange(of: self.appStorageManager.baseURL) { (_) in
								if self.appStorageManager.baseURL != AppStorageManager.Defaults.baseURL {
									self.didResetServerBaseURL = false
								}
							}
					}
				} header: {
					Text("Server Base URL")
						.bold()
				} footer: {
					Text("Changing this setting could make the rest of the app stop working properly.")
				}
				Spacer()
			}
				.tabItem {
					Label("General", systemImage: "gear")
				}
			LoggingAnalyticsSettingsView()
				.tabItem {
					Label("Logging & Analytics", systemImage: "text.redaction")
				}
		}
			.padding()
			.onChange(of: self.appStorageManager.colorBlindMode) { (_) in
				withAnimation {
					self.viewState.toastType = .legend
					self.viewState.legendToastHeadlineText = nil
				}
			}
		#endif // os(macOS)
	}
	
}

struct SettingsViewPreviews: PreviewProvider {
	
	static var previews: some View {
		SettingsView()
			.environmentObject(ViewState.shared)
			.environmentObject(SheetStack())
			.environmentObject(AppStorageManager.shared)
	}
	
}
