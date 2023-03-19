//
//  WhatsNewView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import StoreKit
import SwiftUI

struct WhatsNewView: View {
	
	let onboarding: Bool
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		VStack {
			ScrollView {
				VStack(alignment: .leading) {
					HStack {
						Spacer()
						VStack {
							Text("What’s New")
								.font(.largeTitle)
								.bold()
								.multilineTextAlignment(.center)
							Text("Version 2.0")
								.font(
									.system(
										.callout,
										design: .monospaced
									)
								)
								.bold()
								.padding(5)
								.background(
									.tertiary,
									in: RoundedRectangle(
										cornerRadius: 10,
										style: .continuous
									)
								)
						}
						Spacer()
					}
						.padding(.vertical)
					Text("Shuttle Tracker 2.0 is a massive update that delivers dramatically improved accuracy and tracking coverage!")
					VStack(alignment: .leading, spacing: 20) {
						#if os(iOS)
						HStack(alignment: .top) {
							Image(systemName: "bus")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Automatic Board Bus")
									.font(.headline)
								Text("With Automatic Board Bus, you can use Board Bus without even taking your phone out of your pocket! Shuttle Tracker automatically detects when you board a bus and starts crowd-sourcing until you leave the bus.")
							}
						}
						HStack(alignment: .top) {
							Image(systemName: "point.3.connected.trianglepath.dotted")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Shuttle Tracker Network")
									.font(.headline)
								Text("The Shuttle Tracker app uses the Shuttle Tracker Network to connect to Shuttle Tracker Node, our custom bus-tracking device, to unlock Automatic Board Bus. Shuttle Tracker never collects your location when you’re not physically riding a bus.")
							}
						}
						#endif // os(iOS)
						HStack(alignment: .top) {
							Image(systemName: "exclamationmark.bubble")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Announcements")
									.font(.headline)
								Text("You’ll now receive a push notification whenever a new announcement is posted. You can configure this in Settings > Notifications.")
							}
						}
						HStack(alignment: .top) {
							Image(systemName: "squareshape.squareshape.dashed")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Design")
									.font(.headline)
								Text("To mark the biggest update to Shuttle Tracker since the introduction of Board Bus, we’re introducing a new logo, a new app icon, and a new color scheme.")
							}
						}
						HStack(alignment: .top) {
							Image(systemName: "text.redaction")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Analytics")
									.font(.headline)
								Text("Opt in to analytics sharing to help the Shuttle Tracker team improve the app. You can see a record of recently uploaded analytics entries or enable or disable the feature in Settings > Logging & Analytics.")
							}
						}
					}
						.symbolRenderingMode(.hierarchical)
				}
					.padding(.horizontal)
					.padding(.bottom)
					#if os(iOS)
					.padding(.top)
					#endif // os(iOS)
			}
			#if os(iOS)
			Group {
				if self.onboarding {
					NavigationLink {
						NetworkOnboardingView()
					} label: {
						Text("Continue")
							.bold()
							.padding(5)
							.frame(maxWidth: .infinity)
					}
				} else {
					Button {
						self.sheetStack.pop()
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
			#endif // os(iOS)
		}
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .confirmationAction) {
					Button(self.onboarding ? "Continue" : "Close") {
						self.sheetStack.pop()
						if self.onboarding {
							self.sheetStack.push(.analyticsOnboarding)
						} else {
							// TODO: Switch to SwiftUI’s requestReview environment value when we drop support for macOS 12
							// Request a review on the App Store
							// This logic uses the legacy SKStoreReviewController class because the newer SwiftUI requestReview environment value requires macOS 13 or newer, and stored properties can’t be gated on OS version.
							SKStoreReviewController.requestReview()
						}
					}
				}
				#endif // os(macOS)
			}
			.onAppear {
				if self.onboarding {
					self.viewState.handles.whatsNew?.increment()
				}
			}
	}
	
}

struct WhatsNewViewPreviews: PreviewProvider {
	
	static var previews: some View {
		WhatsNewView(onboarding: false)
			.environmentObject(ViewState.shared)
			.environmentObject(SheetStack())
	}
	
}
