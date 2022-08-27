//
//  ContentView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/30/20.
//

import SwiftUI
import MapKit
import Moya

struct ContentView: View {
	
	@EnvironmentObject private var mapState: MapState
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@AppStorage("MaximumStopDistance") private var maximumStopDistance = 50
	
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
				#endif // os(macOS)
			}
				.alert(item: self.$viewState.alertType) { (alertType) -> Alert in
					switch alertType {
					case .noNearbyStop:
						// Displays a message when the user attempts to board bus when there’s no nearby stop
						return Alert(
							title: Text("No Nearby Stop"),
							message: Text("You can‘t board a bus if you’re not within \(self.maximumStopDistance) meter\(self.maximumStopDistance == 1 ? "" : "s") of a stop."),
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
								#endif // os(macOS)
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
						Label("View Announcements", systemImage: "exclamationmark.bubble")
					}
				}
				ToolbarItem {
					Button {
						self.mapState.mapView?.setVisibleMapRect(MapUtilities.mapRect, animated: true)
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
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.refreshBuses()
				}
			}
			.onReceive(self.timer) { (_) in
				self.refreshBuses()
			}
	}
	
	private func refreshBuses() {
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
				withAnimation {
					self.isRefreshing = false
				}
			}
		}
	}
	#else // os(macOS)
	private var mapView: some View {
		MapView()
	}
	#endif // os(macOS)
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
			.environmentObject(MapState.shared)
			.environmentObject(ViewState.shared)
	}
	
}
