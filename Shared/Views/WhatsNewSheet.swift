//
//  WhatsNewSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import StoreKit
import SwiftUI

struct WhatsNewSheet: View {
	
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
							Text("Version 1.5")
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
						.padding(.top)
					Group {
						Text("Dynamic Routes")
							.font(.headline)
							.padding(.top)
						Text("Shuttle Tracker will now show discrete routes separately, complete with color-coding.")
						Text("Announcements")
							.font(.headline)
							.padding(.top)
						#if os(iOS)
						Text("When you view an announcement, it won’t be included anymore in the badge number. You can reset the record of viewed announcements within the app in Settings > Advanced.")
						#elseif os(macOS) // os(iOS)
						Text("When you view an announcement, it won’t be included anymore in the badge number. You can reset the record of viewed announcements in the announcements sheet.")
						#else // os(macOS)
						Text("When you view an announcement, it won’t be included anymore in the badge number.")
						#endif
						Text("Re-Centering")
							.font(.headline)
							.padding(.top)
						Text("The re-center button and menu item will now ensure that all routes are completely visible on the map.")
					}
				}
					.padding(.bottom)
			}
			#if os(iOS)
			Button {
				self.sheetStack.pop()
				self.viewState.handles.whatsNew?.increment()
			} label: {
				Text("Continue")
					.bold()
			}
				.buttonStyle(.block)
			#endif // os(iOS)
		}
			.padding()
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .confirmationAction) {
					Button("Close") {
						self.sheetStack.pop()
						self.viewState.handles.whatsNew?.increment()
						SKStoreReviewController.requestReview()
					}
				}
				#endif // os(macOS)
			}
	}
	
}

struct WhatsNewSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		WhatsNewSheet()
			.environmentObject(ViewState.shared)
			.environmentObject(SheetStack())
	}
	
}
