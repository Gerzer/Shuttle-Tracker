//
//  NetworkOnboardingView.swift
//  Shuttle Tracker
//
//  Created by Ian Evans on 1/31/23.
//


import StoreKit
import SwiftUI
import CoreLocation

struct NetworkOnboardingView: View {
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	@ScaledMetric
	var textScale: CGFloat = 1 //used for dynamic type sizing for logos
	
	@Environment(\.openURL)
	private var openURL
	
	@State
	private var busScale: CGFloat = 0
	
	@State
	private var deviceScale: CGFloat = 0
	
	@State
	private var phoneScale: CGFloat = 1
	
	@State
	private var cloudScale: CGFloat = 0
	
	@State
	private var waveLeftScale: CGFloat = 0
	
	@State
	private var waveRightScale: CGFloat = 0
	
	@State
	private var textValue: AttributedString = ""
	
	@State
	private var didBeginAnimation = false
	
	var body: some View {
		SheetPresentationWrapper {
			VStack {
				HStack {
					Spacer()
					Text("Shuttle Tracker Network")
						.font(.largeTitle)
						.bold()
						.multilineTextAlignment(.center)
					Spacer()
				}
				HStack {
					Image(systemName: "bus")
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.busScale, height: 50)
						.scaleEffect(self.busScale)
						.onAppear() {
							withAnimation(.easeIn(duration: 0.4).delay(5)) {
								self.busScale = 1
							}
						}
						.overlay(
							ZStack {
								Circle()
									.stroke(.gray, lineWidth: 4)
									.frame(width: 21 * self.deviceScale, height: 20)
								Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
									.resizable()
									.frame(width: 20 * self.deviceScale, height: 20)
									.scaleEffect(self.deviceScale)
									.background(.gray, in: Circle())
							},
							alignment: .topTrailing
						)
					Image(systemName: "wave.3.forward")
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.busScale, height: 50)
						.scaleEffect(self.waveLeftScale)
						.onAppear() {
							withAnimation(.easeIn(duration: 0.4).delay(15)) {
								self.waveLeftScale = 0.8
							}
						}
					Image(systemName: "iphone")
						.resizable()
						.scaledToFit()
						.frame(width: 50, height: 50)
						.scaleEffect(self.phoneScale)
						.onAppear() {
							withAnimation(.easeIn(duration: 0.4).delay(0)) {
								self.phoneScale = 1
							}
						}
					Image(systemName: "wave.3.forward")
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.cloudScale, height: 50)
						.scaleEffect(self.waveRightScale)
						.onAppear() {
							withAnimation(.easeIn(duration: 0.4).delay(25)) {
								self.waveRightScale = 0.8
							}
						}
					Image(systemName: "cloud")
						.resizable()
						.scaledToFit()
						.frame(width: 70 * self.cloudScale, height: 40)
						.scaleEffect(self.cloudScale)
						.onAppear() {
							Task {
								if #available(iOS 16, *) {
									try await Task.sleep(for: .seconds(20))
								} else {
									try await Task.sleep(nanoseconds: 20_000_000_000)
								}
								withAnimation(.easeIn(duration: 0.4)) {
									self.cloudScale = 1
								}
							}
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
				Text(self.textValue)
					.multilineTextAlignment(.center)
					.transition(.opacity)
					.padding(.vertical)
					.onAppear {
						if !self.didBeginAnimation {
							self.didBeginAnimation = true
							Task {
								withAnimation(.easeIn(duration: 0.4).delay(1)) {
									self.textValue = "Welcome to the Shuttle Tracker Network!"
								}
								if #available(iOS 16, *) {
									try await Task.sleep(for: .seconds(5))
								} else {
									try await Task.sleep(nanoseconds: 5_000_000_000)
								}
								withAnimation(.easeIn(duration: 0.4)) {
									self.textValue = "Previously, you had to tap the Board Bus button whenever you boarded a bus."
								}
								if #available(iOS 16, *) {
									try await Task.sleep(for: .seconds(5))
								} else {
									try await Task.sleep(nanoseconds: 5_000_000_000)
								}
								withAnimation(.easeIn(duration: 0.4)) {
									self.deviceScale = 1
									self.textValue = "Now, we’ve equipped the buses with Shuttle Tracker Node, a custom bus-tracking device that unlocks Automatic Board Bus."
								}
								if #available(iOS 16, *) {
									try await Task.sleep(for: .seconds(5))
								} else {
									try await Task.sleep(nanoseconds: 5_000_000_000)
								}
								withAnimation(.easeIn(duration: 0.4)) {
									self.textValue = "When you board a bus, Shuttle Tracker Node sends a message to your phone in the background."
								}
								if #available(iOS 16, *) {
									try await Task.sleep(for: .seconds(5))
								} else {
									try await Task.sleep(nanoseconds: 5_000_000_000)
								}
								withAnimation(.easeIn(duration: 0.4)) {
									self.textValue = "When your phone receives this message, it automatically sends the bus’s location to the Shuttle Tracker server. You don’t even have to take your phone out of your pocket!"
								}
								if #available(iOS 16, *) {
									try await Task.sleep(for: .seconds(5))
								} else {
									try await Task.sleep(nanoseconds: 5_000_000_000)
								}
								withAnimation(.easeIn(duration: 0.4)) {
									switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
									case (.authorizedAlways, .fullAccuracy):
										self.textValue = "Tap the button below to join the Shuttle Tracker Network!"
									case (.notDetermined, _):
										self.textValue = try! AttributedString(markdown: "The Shuttle Tracker Network requires location access to work properly. Select **Allow While Using App** and then **Change to Always Allow** to join the Network!")
									default:
										self.textValue = try! AttributedString(markdown: "The Shuttle Tracker Network requires location access to work properly. Select **Always** location access and enable **Precise Location** to join the Network!")
									}
								}
							}
						}
					}
				Spacer()
				NavigationLink {
					AnalyticsOnboardingView()
				} label: {
					Text("Join the Network")
						.bold()
						.padding(5)
						.frame(maxWidth: .infinity)
				}
					.buttonStyle(.borderedProminent)
					.padding(.bottom)
					.simultaneousGesture(
						TapGesture()
							.exclusively(before: DragGesture())
							.onEnded { (_) in
								switch (CLLocationManager.default.authorizationStatus, CLLocationManager.default.accuracyAuthorization) {
								case (.authorizedAlways, .fullAccuracy):
									break
								case (.notDetermined, _):
									// We request “when-in-use” authorization even when we actually want “always” authorization because doing so lets us avoid iOS’s usual deferment of the “always” prompt until long after the user closes the app. Instead, iOS shows two prompts in direct succession: firstly for “when-in-use” and secondly for “always”.
									CLLocationManager.default.requestWhenInUseAuthorization()
									CLLocationManager.default.requestAlwaysAuthorization()
								default:
									self.openURL(URL(string: UIApplication.openSettingsURLString)!)
								}
							}
					)
			}
		}
			.padding(.horizontal)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink("Skip") {
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
