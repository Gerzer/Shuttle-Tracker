//
//  SettingsView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import STLogging
import SwiftUI

struct SettingsView: View {
	
	#if os(macOS)
	@State
	private var didResetServerBaseURL = false
	#endif // os(macOS)
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		#if os(iOS)
		Form {
			Section {
				HStack {
					ZStack {
						Circle()
							.fill(.green)
						Image(systemName: self.appStorageManager.colorBlindMode ? SFSymbol.colorBlindHighQualityLocation.systemName : SFSymbol.bus.systemName)
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
		}
			.onChange(of: self.appStorageManager.colorBlindMode) { (enabled) in
				withAnimation {
					self.viewState.toastType = .legend
					self.viewState.legendToastHeadlineText = nil
				}
				
				Task {
					do {
						try await Analytics.upload(eventType: .colorBlindModeToggled(enabled: enabled))
					} catch {
						#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics: \(error, privacy: .public)")
					}
				}
			}
			.sheetPresentation(
				provider: ShuttleTrackerSheetPresentationProvider(sheetStack: self.sheetStack),
				sheetStack: self.sheetStack
			)
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
							.onChange(of: self.appStorageManager.baseURL) { (url) in
								if self.appStorageManager.baseURL != AppStorageManager.Defaults.baseURL {
									self.didResetServerBaseURL = false
								}
								
								Task {
									do {
										try await Analytics.upload(eventType: .serverBaseURLChanged(url: url))
									} catch {
										#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics: \(error, privacy: .public)")
									}
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
					Label("General", systemImage: SFSymbol.settings.systemName)
				}
			LoggingAnalyticsSettingsView()
				.tabItem {
					Label("Logging & Analytics", systemImage: SFSymbol.loggingAnalytics.systemName)
				}
		}
			.padding()
			.onChange(of: self.appStorageManager.colorBlindMode) { (enabled) in
				withAnimation {
					self.viewState.toastType = .legend
					self.viewState.legendToastHeadlineText = nil
				}
				
				Task {
					do {
						try await Analytics.upload(eventType: .colorBlindModeToggled(enabled: enabled))
					} catch {
						#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics: \(error, privacy: .public)")
					}
				}
			}
		#endif // os(macOS)
	}
	
}

struct SettingsViewPreviews: PreviewProvider {
	
	static var previews: some View {
		SettingsView()
			.environmentObject(ViewState.shared)
			.environmentObject(AppStorageManager.shared)
			.environmentObject(ShuttleTrackerSheetStack())
	}
	
}
