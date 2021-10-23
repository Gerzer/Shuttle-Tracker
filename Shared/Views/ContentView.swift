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
					if #available(iOS 15.0, *) {
						PrivacySheet()
							.interactiveDismissDisabled()
					} else {
						PrivacySheet()
					}
					#else // os(iOS) && !APPCLIP
					EmptyView()
					#endif // os(iOS) && !APPCLIP
				case .settings:
					#if os(iOS) && !APPCLIP
					SettingsSheet()
					#else // os(iOS) && !APPCLIP
					EmptyView()
					#endif // os(iOS) && !APPCLIP
				case .info:
					#if os(iOS) && !APPCLIP
					InfoSheet()
					#else // os(iOS) && !APPCLIP
					EmptyView()
					#endif // os(iOS) && !APPCLIP
				case .busSelection:
					#if os(iOS)
					if #available(iOS 15.0, *) {
						BusSelectionSheet()
							.interactiveDismissDisabled()
					} else {
						BusSelectionSheet()
					}
					#else // os(iOS)
					EmptyView()
					#endif // os(iOS)
				}
			}
			.alert(item: self.$viewState.alertType) { (alertType) -> Alert in
				switch alertType {
				case .noNearbyStop:
					let title = Text("No Nearby Stop")
					let message = Text("You can't board a bus if you're not within ten meters of a stop.")
					let dismissButton = Alert.Button.default(Text("Continue"))
					return Alert(title: title, message: message, dismissButton: dismissButton)
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
						NotificationCenter.default.post(name: .refreshBuses, object: nil)
					} label: {
						Image(systemName: "arrow.clockwise.circle.fill")
							.resizable()
							.aspectRatio(1, contentMode: .fit)
					}
				}
			}
			.onAppear {
				NSWindow.allowsAutomaticWindowTabbing = false
			}
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses, object: nil)) { (_) in
				self.refreshBuses()
			}
			.onReceive(self.timer) { (_) in
				self.refreshBuses()
			}
	}
	
	private func refreshBuses() {
		[Bus].download { (buses) in
			DispatchQueue.main.async {
				self.mapState.buses = buses
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
