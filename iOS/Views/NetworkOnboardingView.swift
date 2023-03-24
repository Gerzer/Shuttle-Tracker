//
//  NetworkOnboardingView.swift
//  Shuttle Tracker (iOS)
//
//  Created by Ian Evans on 1/31/23.
//


import StoreKit
import SwiftUI
import CoreLocation

struct NetworkOnboardingView: View {
	
	@State
	private var busScale: CGFloat = 0
	
	@State
	private var antennaScale: CGFloat = 0
	
	@State
	private var waveLeftScale: CGFloat = 0
	
	@State
	private var phoneScale: CGFloat = 0
	
	@State
	private var waveRightScale: CGFloat = 0
	
	@State
	private var cloudScale: CGFloat = 0
	
	@State
	private var tabViewSelection = 0
	
	@Environment(\.openURL)
	private var openURL
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text("Shuttle Tracker Network")
					.font(.largeTitle)
					.bold()
					.multilineTextAlignment(.center)
				Spacer()
			}
				.padding(.horizontal)
			HStack {
				Image(systemName: "bus")
					.resizable()
					.scaledToFit()
					.frame(width: 50 * self.busScale, height: 50)
					.scaleEffect(self.busScale)
					.overlay(
						ZStack {
							Circle()
								.stroke(.gray, lineWidth: 4)
								.frame(width: 21 * self.antennaScale, height: 20)
							Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
								.resizable()
								.frame(width: 20 * self.antennaScale, height: 20)
								.scaleEffect(self.antennaScale)
								.background(.gray, in: Circle())
						},
						alignment: .topTrailing
					)
					.onAppear {
						withAnimation() {
							self.busScale = 1
						}
					}
				if self.tabViewSelection != 0 {
					Image(systemName: "wave.3.forward")
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.busScale, height: 50)
						.scaleEffect(self.waveLeftScale)
					Image(systemName: "iphone")
						.resizable()
						.scaledToFit()
						.frame(width: 50, height: 50)
						.scaleEffect(self.phoneScale)
					Image(systemName: "wave.3.forward")
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.cloudScale, height: 50)
						.scaleEffect(self.waveRightScale)
					Image(systemName: "cloud")
						.resizable()
						.scaledToFit()
						.frame(width: 70 * self.cloudScale, height: 40)
						.scaleEffect(self.cloudScale)
				}
			}
				.symbolRenderingMode(.monochrome)
				.padding()
				.background(
					.gray,
					in: RoundedRectangle(
						cornerRadius: 10,
						style: .continuous
					)
				)
				.animation(.default, value: self.tabViewSelection)
			TabView(selection: self.$tabViewSelection) {
				VStack(alignment: .leading) {
					Text(try! AttributedString(markdown: "Join the Shuttle Tracker Network to help improve tracking accuracy and **never tap the Board Bus button again**!"))
						.padding(.bottom)
					NetworkTextView()
					Spacer()
				}
					.tag(0)
					.padding(.horizontal)
				VStack(alignment: .leading) {
					Text("Previously, you had to tap the Board Bus button whenever you boarded a bus.")
					Spacer()
				}
					.tag(1)
					.padding(.horizontal)
				VStack(alignment: .leading) {
					Text("Now, we’ve equipped the buses with Shuttle Tracker Node, a custom bus-tracking device that unlocks Automatic Board Bus.")
					Spacer()
				}
					.tag(2)
					.padding(.horizontal)
				VStack(alignment: .leading) {
					Text("When you board a bus, Shuttle Tracker Node sends a message to your phone in the background.")
					Spacer()
				}
					.tag(3)
					.padding(.horizontal)
				VStack(alignment: .leading) {
					Text("When your phone receives this message, it automatically sends the bus’s location to the Shuttle Tracker server. You don’t even have to take your phone out of your pocket!")
					Spacer()
				}
					.tag(4)
					.padding(.horizontal)
				VStack(alignment: .leading) {
					Text("Join the Shuttle Tracker Network today!")
						.padding(.bottom)
					NetworkTextView()
					Spacer()
				}
					.tag(5)
					.padding(.horizontal)
			}
				.tabViewStyle(.page)
				.indexViewStyle(.page(backgroundDisplayMode: .always))
//				.multilineTextAlignment(.center)
				.accessibilityShowsLargeContentViewer()
				.padding(.vertical)
				.onChange(of: self.tabViewSelection) { (newValue) in
					withAnimation {
						switch newValue {
						case 0:
							self.busScale = 1
							self.antennaScale = 0
							self.waveLeftScale = 0
							self.phoneScale = 0
							self.waveRightScale = 0
							self.cloudScale = 0
						case 1:
							self.busScale = 1
							self.antennaScale = 0
							self.waveLeftScale = 0
							self.phoneScale = 1
							self.waveRightScale = 0
							self.cloudScale = 0
						case 2:
							self.busScale = 1
							self.antennaScale = 1
							self.waveLeftScale = 0
							self.phoneScale = 1
							self.waveRightScale = 0
							self.cloudScale = 0
						case 3:
							self.busScale = 1
							self.antennaScale = 1
							self.waveLeftScale = 1
							self.phoneScale = 1
							self.waveRightScale = 0
							self.cloudScale = 0
						case 4:
							self.busScale = 1
							self.antennaScale = 1
							self.waveLeftScale = 1
							self.phoneScale = 1
							self.waveRightScale = 1
							self.cloudScale = 1
						case 5:
							self.busScale = 1
							self.antennaScale = 1
							self.waveLeftScale = 1
							self.phoneScale = 1
							self.waveRightScale = 1
							self.cloudScale = 1
						default:
							fatalError()
						}
					}
				}
			Spacer()
			Group {
				if case (.authorizedAlways, .fullAccuracy) = (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
					NavigationLink {
						AnalyticsOnboardingView()
					} label: {
						Text("Continue")
							.bold()
							.padding(5)
							.frame(maxWidth: .infinity)
					}
				} else {
					Button {
						if case .notDetermined = CLLocationManager.default.authorizationStatus {
							// We request “when-in-use” authorization even when we actually want “always” authorization because doing so lets us avoid iOS’s usual deferment of the “always” prompt until long after the user closes the app. Instead, iOS shows two prompts in direct succession: firstly for “when-in-use” and secondly for “always”.
							CLLocationManager.default.requestWhenInUseAuthorization()
							CLLocationManager.default.requestAlwaysAuthorization()
						} else {
							self.openURL(URL(string: UIApplication.openSettingsURLString)!)
						}
					} label: {
						Text("Continue")
							.bold()
							.padding(5)
							.frame(maxWidth: .infinity)
					}
				}
			}
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
				.padding(.bottom)
				.animation(.default, value: self.tabViewSelection)
		}
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink("Later") {
						AnalyticsOnboardingView()
					}
				}
			}
	}
	
}

struct NetworkOnboardingViewPreviews: PreviewProvider {
	
	static var previews: some View {
		NavigationView {
			NetworkOnboardingView()
				.environmentObject(SheetStack())
		}
	}
	
}
