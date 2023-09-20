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
	private var nodeScale: CGFloat = 0
	
	@State
	private var signalLeftScale: CGFloat = 0
	
	@State
	private var phoneScale: CGFloat = 0
	
	@State
	private var signalRightScale: CGFloat = 0
	
	@State
	private var serverScale: CGFloat = 0
	
	@State
	private var chevron1Opacity: Double = 0
	
	@State
	private var chevron2Opacity: Double = 0
	
	@State
	private var chevron3Opacity: Double = 0
	
	@State
	private var tabViewSelection = 0
	
	@State
	private var firstTabDidDisappear = false
	
	@Environment(\.openURL)
	private var openURL
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text("Improve Accuracy")
					.font(.largeTitle)
					.bold()
					.multilineTextAlignment(.center)
				Spacer()
			}
				.padding(.horizontal)
			HStack {
				Image(systemName: SFSymbol.bus.rawValue)
					.resizable()
					.scaledToFit()
					.frame(width: 50 * self.busScale, height: 50)
					.scaleEffect(self.busScale)
					.overlay(
						ZStack {
							Circle()
								.stroke(.gray, lineWidth: 4)
								.frame(width: 21 * self.nodeScale, height: 20)
							Image(systemName: SFSymbol.onboardingNode.rawValue)
								.resizable()
								.frame(width: 20 * self.nodeScale, height: 20)
								.scaleEffect(self.nodeScale)
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
					Image(systemName: SFSymbol.onboardingSignal.rawValue)
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.busScale, height: 50)
						.scaleEffect(self.signalLeftScale)
					Image(systemName: SFSymbol.onboardingPhone.rawValue)
						.resizable()
						.scaledToFit()
						.frame(width: 50, height: 50)
						.scaleEffect(self.phoneScale)
					Image(systemName: SFSymbol.onboardingSignal.rawValue)
						.resizable()
						.scaledToFit()
						.frame(width: 50 * self.serverScale, height: 50)
						.scaleEffect(self.signalRightScale)
					Image(systemName: SFSymbol.onboardingServer.rawValue)
						.resizable()
						.scaledToFit()
						.frame(width: 70 * self.serverScale, height: 40)
						.scaleEffect(self.serverScale)
				}
			}
				.symbolRenderingMode(.monochrome)
				.frame(maxWidth: .infinity)
				.padding(.vertical)
				.background(
					.gray,
					in: RoundedRectangle(
						cornerRadius: 10,
						style: .continuous
					)
				)
				.padding(.horizontal) // We need to add the horizontal padding after adding the background
				.animation(.default, value: self.tabViewSelection)
			TabView(selection: self.$tabViewSelection) {
				VStack(alignment: .leading) {
					ScrollView {
						HStack {
							Text("Join the Shuttle Tracker Network to help improve tracking accuracy!")
							Spacer()
						}
							.padding(.bottom)
						NetworkTextView()
					}
					if #available(iOS 16.1, *), !firstTabDidDisappear {
						HStack(spacing: -5) {
							Spacer()
							Image(systemName: SFSymbol.onboardingSwipeLeft.rawValue)
								.opacity(self.chevron1Opacity)
								.offset(x: -10)
							Image(systemName: SFSymbol.onboardingSwipeLeft.rawValue)
								.opacity(self.chevron2Opacity)
								.offset(x: -10)
							Image(systemName: SFSymbol.onboardingSwipeLeft.rawValue)
								.opacity(self.chevron3Opacity)
								.offset(x: -10)
							Text("Swipe")
							Spacer()
						}
							.font(.system(size: 24))
							.fontDesign(.rounded)
							.fontWeight(.semibold)
							.foregroundColor(.accentColor)
							.padding(.bottom, 50)
							.onAppear {
								Task {
									while true {
										withAnimation(.linear(duration: 0.5)) {
											self.chevron3Opacity = 1
										}
										try? await Task.sleep(for: .seconds(2))
										withAnimation(.linear(duration: 0.5)) {
											self.chevron3Opacity = 0
										}
										try? await Task.sleep(for: .seconds(1.5))
									}
								}
								Task {
									try? await Task.sleep(for: .seconds(0.5))
									while true {
										withAnimation(.linear(duration: 0.5)) {
											self.chevron2Opacity = 1
										}
										try? await Task.sleep(for: .seconds(2))
										withAnimation(.linear(duration: 0.5)) {
											self.chevron2Opacity = 0
										}
										try? await Task.sleep(for: .seconds(1.5))
									}
								}
								Task {
									try? await Task.sleep(for: .seconds(1))
									while true {
										withAnimation(.linear(duration: 0.5)) {
											self.chevron1Opacity = 1
										}
										try? await Task.sleep(for: .seconds(2))
										withAnimation(.linear(duration: 0.5)) {
											self.chevron1Opacity = 0
										}
										try? await Task.sleep(for: .seconds(1.5))
									}
								}
							}
					}
				}
					.tag(0)
					.padding(.horizontal)
					.onDisappear {
						self.firstTabDidDisappear = true
					}
				ScrollView {
					HStack {
						Text("Previously, you had to tap the Board Bus button whenever you boarded a bus.")
						Spacer()
					}
				}
					.tag(1)
					.padding(.horizontal)
				ScrollView {
					HStack {
						Text("Now, we’ve equipped the buses with Shuttle Tracker Node, a custom bus-tracking device that unlocks Automatic Board Bus.")
						Spacer()
					}
				}
					.tag(2)
					.padding(.horizontal)
				ScrollView {
					HStack {
						Text("When you board a bus, Shuttle Tracker Node sends a message to your phone in the background.")
						Spacer()
					}
				}
					.tag(3)
					.padding(.horizontal)
				ScrollView {
					HStack {
						Text("When your phone receives this message, it automatically sends the bus’s location to the Shuttle Tracker server. You don’t even have to take your phone out of your pocket!")
						Spacer()
					}
				}
					.tag(4)
					.padding(.horizontal)
				ScrollView {
					HStack {
						Text("Join the Shuttle Tracker Network today!")
							.padding(.bottom)
						Spacer()
					}
					NetworkTextView()
				}
					.tag(5)
					.padding(.horizontal)
			}
				.tabViewStyle(.page)
				.indexViewStyle(.page(backgroundDisplayMode: .always))
				.accessibilityShowsLargeContentViewer()
				.padding(.vertical)
				.environment(\.layoutDirection, .leftToRight)
				.onChange(of: self.tabViewSelection) { (newValue) in
					withAnimation {
						switch newValue {
						case 0:
							self.busScale = 1
							self.nodeScale = 0
							self.signalLeftScale = 0
							self.phoneScale = 0
							self.signalRightScale = 0
							self.serverScale = 0
						case 1:
							self.busScale = 1
							self.nodeScale = 0
							self.signalLeftScale = 0
							self.phoneScale = 1
							self.signalRightScale = 0
							self.serverScale = 0
						case 2:
							self.busScale = 1
							self.nodeScale = 1
							self.signalLeftScale = 0
							self.phoneScale = 1
							self.signalRightScale = 0
							self.serverScale = 0
						case 3:
							self.busScale = 1
							self.nodeScale = 1
							self.signalLeftScale = 1
							self.phoneScale = 1
							self.signalRightScale = 0
							self.serverScale = 0
						case 4:
							self.busScale = 1
							self.nodeScale = 1
							self.signalLeftScale = 1
							self.phoneScale = 1
							self.signalRightScale = 1
							self.serverScale = 1
						case 5:
							self.busScale = 1
							self.nodeScale = 1
							self.signalLeftScale = 1
							self.phoneScale = 1
							self.signalRightScale = 1
							self.serverScale = 1
						default:
							Logging.withLogger(doUpload: true) { (logger) in
								logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Invalid tab item")
							}
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
				.environmentObject(ShuttleTrackerSheetStack())
		}
	}
	
}
