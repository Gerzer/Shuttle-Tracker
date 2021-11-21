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
	
	var body: some View {
		ZStack {
			self.mapView
				.ignoresSafeArea()
			#if os(macOS)
			VStack {
				HStack {
					switch self.viewState.toastType {
					case .some(.legend):
						LegendToast()
							.frame(maxWidth: 250, maxHeight: 100)
							.padding(.top, 50)
							.padding(.leading, 10)
					case .none:
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
				case .some(.legend):
					LegendToast()
						.padding()
				case .none:
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
			.sheet(item: self.$viewState.sheetType) {
				[Route].download { (routes) in
					DispatchQueue.main.async {
						self.mapState.routes = routes
					}
				}
			} content: { (sheetType) in
				switch sheetType {
				case .privacy:
					#if os(iOS) && !APPCLIP
					if #available(iOS 15, *) {
						PrivacySheet()
							.interactiveDismissDisabled()
					} else {
						PrivacySheet()
					}
					#endif // os(iOS) && !APPCLIP
				case .settings:
					#if os(iOS) && !APPCLIP
					SettingsSheet()
					#endif // os(iOS) && !APPCLIP
				case .info:
					#if os(iOS) && !APPCLIP
					InfoSheet()
					#endif // os(iOS) && !APPCLIP
				case .busSelection:
					#if os(iOS)
					if #available(iOS 15, *) {
						BusSelectionSheet()
							.interactiveDismissDisabled()
					} else {
						BusSelectionSheet()
					}
					#endif // os(iOS)
				case .announcements:
					if #available(iOS 15, macOS 12, *) {
						AnnouncementsSheet()
							.frame(idealWidth: 500, idealHeight: 500)
					}
				case .whatsNew:
					#if !APPCLIP
					WhatsNewSheet()
						.frame(idealWidth: 500, idealHeight: 500)
					#endif // !APPCLIP
				}
			}
			.alert(item: self.$viewState.alertType) { (alertType) -> Alert in
				switch alertType {
				case .noNearbyStop:
					return Alert(
						title: Text("No Nearby Stop"),
						message: Text("You can‘t board a bus if you’re not within 20 meters of a stop."),
						dismissButton: .default(Text("Continue"))
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
				}
			}
			.onAppear {
				API.provider.request(.readVersion) { (result) in
					let version = (try? result.value?.map(Int.self)) ?? Int.max
					if version > API.lastVersion {
						self.viewState.alertType = .updateAvailable
					}
				}
			}
	}
	
	#if os(macOS)
	private let timer = Timer.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	private var mapView: some View {
		MapView()
			.toolbar {
				ToolbarItem {
					Button {
						self.viewState.sheetType = .announcements
					} label: {
						Label("View Announcements", systemImage: "exclamationmark.bubble")
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
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses, object: nil)) { (_) in
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
	
	@State private var isRefreshing = false
	
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
			.environmentObject(MapState.sharedInstance)
			.environmentObject(ViewState.sharedInstance)
	}
	
}
