//
//  ContentView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import Foundation
import MapKit
import SwiftUI

struct ContentView: View {
	
	@State private var announcements: [Announcement] = []
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var appStorageManager: AppStorageManager
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	private var unviewedAnnouncementsCount: Int {
		get {
			return self.announcements
				.filter { (announcement) in
					return !self.appStorageManager.viewedAnnouncementIDs.contains(announcement.id)
				}
				.count
		}
	}
	
	var body: some View {
		SheetPresentationWrapper {
			ZStack {
				self.mapView
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
					default:
						HStack {
							SecondaryOverlay()
								.padding(.top, 5)
								.padding(.leading, 10)
							Spacer()
						}
					}
					Spacer()
					#endif // !APPCLIP
					PrimaryOverlay()
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
								#if os(macOS)
								NSWorkspace.shared.open(url)
								#else // os(macOS)
								UIApplication.shared.open(url)
								#endif
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
				.onAppear {
					API.provider.request(.readVersion) { (result) in
						let version = try? result
							.get()
							.map(Int.self)
						if let version {
							if version > API.lastVersion {
								self.viewState.alertType = .updateAvailable
							}
						} else {
							self.viewState.alertType = .serverUnavailable
						}
					}
				}
		}
	}
	
	#if os(macOS)
	@State private var isRefreshing = false
	
	private let timer = Timer
		.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	private var mapView: some View {
		MapView()
			.toolbar {
				ToolbarItem {
					Button {
						self.sheetStack.push(.announcements)
					} label: {
						ZStack {
							Label("View Announcements", systemImage: "exclamationmark.bubble")
							if self.unviewedAnnouncementsCount > 0 {
								Circle()
									.foregroundColor(.red)
									.frame(width: 15, height: 15)
									.offset(x: 10, y: -10)
								Text("\(self.unviewedAnnouncementsCount)")
									.foregroundColor(.white)
									.font(.caption)
									.offset(x: 10, y: -10)
							}
						}
							.task {
								self.announcements = await [Announcement].download()
							}
					}
				}
				ToolbarItem {
					Button {
						Task {
							await self.mapState.resetVisibleMapRect()
						}
					} label: {
						Label("Re-Center Map", systemImage: "location.fill.viewfinder")
					}
				}
				ToolbarItem {
					if self.isRefreshing {
						ProgressView()
					} else {
						Button {
							NotificationCenter.default.post(name: .refreshBuses, object: nil)
						} label: {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
				}
			}
			.onAppear {
				NSWindow.allowsAutomaticWindowTabbing = false
			}
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses)) { (_) in
				withAnimation {
					self.isRefreshing = true
				}
				Task {
					if #available(macOS 13, *) {
						try await Task.sleep(for: .milliseconds(500))
					} else {
						try await Task.sleep(nanoseconds: 500_000_000)
					}
					await self.mapState.refreshAll()
					withAnimation {
						self.isRefreshing = false
					}
				}
			}
			.onReceive(self.timer) { (_) in
				Task {
					// For “standard” refresh operations, we only refresh the buses.
					await self.mapState.refreshBuses()
				}
			}
	}
	#else // os(macOS)
	private var mapView: some View {
		MapView()
	}
	#endif
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
			.environmentObject(MapState.shared)
			.environmentObject(ViewState.shared)
			.environmentObject(AppStorageManager.shared)
			.environmentObject(SheetStack())
	}
	
}
