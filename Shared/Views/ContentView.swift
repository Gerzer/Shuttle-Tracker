//
//  ContentView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import AsyncAlgorithms
import MapKit
import STLogging
import SwiftUI
import UserNotifications

struct ContentView: View {
	
	@State
	private var announcements: [Announcement] = []
	
	@Binding
	private var mapCameraPosition: MapCameraPositionWrapper
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	@Environment(\.colorScheme)
	private var colorScheme
	
	var body: some View {
			ZStack {
				self.mapView
					.tint(.blue)
					.ignoresSafeArea()
				#if os(macOS)
				VStack {
					HStack {
						switch self.viewState.toastType {
						case .legend:
							LegendToast()
								.frame(maxWidth: 250, maxHeight: 100)
								.padding(.top, 50)
								.padding(.leading, 10)
						default:
							EmptyView()
						}
						Spacer()
					}
					Spacer()
				}
				#else // os(macOS)
				VStack {
					VisualEffectView(.systemUltraThinMaterial)
						.ignoresSafeArea()
						.frame(height: 0)
					#if !APPCLIP
					switch self.viewState.toastType {
					case .legend:
						LegendToast()
							.padding()
					case .boardBus:
						BoardBusToast()
							.padding()
					case .debugMode:
                        if #available(iOS 16.2, *) {
							DebugModeToast()
								.padding()
						}
					case .network:
						NetworkToast()
							.padding()
					default:
						HStack {
							SecondaryOverlay(mapCameraPosition: self.$mapCameraPosition)
								.padding(.top, 5)
								.padding(.leading, 10)
							Spacer()
						}
					}
					Spacer()
					#endif // !APPCLIP
					PrimaryOverlay(mapCameraPosition: self.$mapCameraPosition)
						.padding(.bottom)
					#if APPCLIP
					Spacer()
					#endif // APPCLIP
				}
				#endif
			}
				.alert(item: self.$viewState.alertType) { (alertType) -> Alert in
					switch alertType {
					case .noNearbyStop:
						// Displays a message when the user attempts to board bus when there’s no nearby stop
						return Alert(
							title: Text("No Nearby Stop"),
							message: Text("You can’t board a bus if you’re not within \(self.appStorageManager.maximumStopDistance) meter\(self.appStorageManager.maximumStopDistance == 1 ? "" : "s") of a stop."),
							dismissButton: .default(Text("Dismiss"))
						)
					case .updateAvailable:
						return Alert(
							title: Text("Update Available"),
							message: Text("An update to the app is available. Please update to the latest version to continue using Shuttle Tracker."),
							dismissButton: .default(Text("Update")) {
								let url = URL(string: "itms-apps://apps.apple.com/us/app/shuttle-tracker/id1583503452")!
								#if canImport(AppKit)
								NSWorkspace.shared.open(url)
								#elseif canImport(UIKit) // canImport(AppKit)
								UIApplication.shared.open(url)
								#endif // canImport(UIKit)
							}
						)
					case .serverUnavailable:
						return Alert(
							title: Text("Server Unavailable"),
							message: Text("Shuttle Tracker can’t connect to its server; please try again later."),
							dismissButton: .default(Text("Dismiss"))
						)
					}
				}
				.task {
					ViewState.shared.colorScheme = self.colorScheme
					
					do {
						let version = try await API.readVersion.perform(as: Int.self)
						if version > API.lastVersion {
							self.viewState.alertType = .updateAvailable
						}
					} catch {
						self.viewState.alertType = .serverUnavailable
						#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to get server version number: \(error, privacy: .public)")
					}
					
					do {
						try await Analytics.upload(eventType: .coldLaunch)
					} catch {
						#log(system: Logging.system, category: .api, level: .error, doUpload: true, "Failed to upload analytics: \(error, privacy: .public)")
					}
				}
				.onChange(of: self.colorScheme) { (newValue) in
					ViewState.shared.colorScheme = newValue
				}
				.sheetPresentation(
					provider: ShuttleTrackerSheetPresentationProvider(sheetStack: self.sheetStack),
					sheetStack: self.sheetStack
				)
	}
	
	#if os(macOS)
	@State
	private var isRefreshing = false
	
	private let timer = Timer
		.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	private var mapView: some View {
		Group {
			if #available(macOS 14, *) {
				MapContainer(position: self.$mapCameraPosition)
			} else {
				LegacyMapView(position: self.$mapCameraPosition)
			}
		}
			.toolbar {
				Button {
					self.sheetStack.push(.announcements)
				} label: {
					ZStack {
						Label("Show Announcements", systemImage: SFSymbol.announcements.systemName)
						if self.viewState.badgeNumber > 0 {
							Circle()
								.foregroundColor(.red)
								.frame(width: 15, height: 15)
								.offset(x: 10, y: -10)
							Text("\(self.viewState.badgeNumber)")
								.foregroundColor(.white)
								.font(.caption)
								.offset(x: 10, y: -10)
						}
					}
						.task {
							do {
								try await UNUserNotificationCenter.updateBadge()
							} catch {
								#log(system: Logging.system, category: .apns, level: .error, doUpload: true, "Failed to update badge: \(error, privacy: .public)")
							}
						}
				}
				Button {
					self.sheetStack.push(.info)
				} label: {
					Label("Schedule", systemImage: "info.circle")
				}
				Button {
					Task {
						await self.mapState.recenter(position: self.$mapCameraPosition)
					}
				} label: {
					Label("Re-Center Map", systemImage: SFSymbol.recenter.systemName)
				}
				if self.isRefreshing {
					ProgressView()
				} else {
					Button {
						if #available(macOS 13, *) {
							Task {
								await self.viewState.refreshSequence.trigger()
							}
						} else {
							NotificationCenter.default.post(name: .refreshBuses, object: nil)
						}
					} label: {
						Label("Refresh", systemImage: SFSymbol.refresh.systemName)
					}
				}
			}
			.task {
				if #available(macOS 13, *) {
					await self.mapState.refreshAll()
					await self.mapState.recenter(position: self.$mapCameraPosition)
					for await refreshType in self.viewState.refreshSequence {
						switch refreshType {
						case .manual:
							self.isRefreshing = true
							do {
								try await Task.sleep(for: .milliseconds(500))
							} catch {
								#log(system: Logging.system, level: .error, doUpload: true, "Task sleep failed: \(error, privacy: .public)")
							}
							await self.mapState.refreshAll()
							self.isRefreshing = false
						case .automatic:
							// For automatic refresh operations, we only refresh the buses.
							await self.mapState.refreshBuses()
						}
					}
				} else {
					Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
						Task {
							// For automatic refresh operations, we only refresh the buses.
							await self.mapState.refreshBuses()
						}
					}
				}
			}
			.onAppear {
				NSWindow.allowsAutomaticWindowTabbing = false
			}
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses)) { (_) in // TODO: Remove when we drop support for macOS 12
				if #available(macOS 13, *) {
					#log(system: Logging.system, level: .error, doUpload: true, "Combine publisher for refreshing buses was used even though macOS 13 is available!")
				} else {
					withAnimation {
						self.isRefreshing = true
					}
					Task {
						do {
							try await Task.sleep(nanoseconds: 500_000_000)
						} catch {
							#log(system: Logging.system, level: .error, doUpload: true, "Task sleep failed: \(error, privacy: .public)")
							throw error
						}
						await self.mapState.refreshAll()
						withAnimation {
							self.isRefreshing = false
						}
					}
				}
			}
	}
	#else // os(macOS)
	private var mapView: some View {
		Group {
			if #available(iOS 17, *) {
				MapContainer(position: self.$mapCameraPosition)
			} else {
				LegacyMapView(position: self.$mapCameraPosition)
			}
		}
	}
	#endif
	
	init(mapCameraPosition: Binding<MapCameraPositionWrapper>) {
		self._mapCameraPosition = mapCameraPosition
	}
	
}

@available(iOS 17, macOS 14, *)
#Preview {
	ContentView(mapCameraPosition: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
		.environmentObject(MapState.shared)
		.environmentObject(ViewState.shared)
		.environmentObject(AppStorageManager.shared)
		.environmentObject(ShuttleTrackerSheetStack())
}
