//
//  WhatsNewSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import SwiftUI

struct WhatsNewSheet: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
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
							if #available(iOS 15, macOS 12, *) {
								Text("Version 1.2")
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
						}
						Spacer()
					}
						.padding(.top)
					Text("Announcements")
						.font(.headline)
						.padding(.top)
					Text("Shuttle Tracker can now deliver announcements! We’ll use this feature to provide important, timely information, such as schedule changes. On iOS 15 or iPadOS 15, tap the new Announcements icon in the overlay at the top-left corner of the screen; on macOS 12 Monterey, click the new Announcements icon in the toolbar.")
					Text("Onboarding")
						.font(.headline)
						.padding(.top)
					Text("Tapping “Board Bus” is the best way to help make Shuttle Tracker more accurate for everyone, so on iOS and iPadOS we’ll now remind you to start crowd-sourcing if you haven’t done so before.")
					Text("Advanced Settings")
						.font(.headline)
						.padding(.top)
					Text("On iOS and iPadOS, you can now configure some advanced settings, such as the maximum distance away from a stop at which you can board a bus.")
					Text("Design")
						.font(.headline)
						.padding(.top)
					Text("We’ve implemented some small design tweaks to make Shuttle Tracker even easier to use.")
				}
					.padding(.bottom)
			}
			#if !os(macOS)
			Button {
				self.sheetStack.pop()
				self.viewState.handles.whatsNew?.increment()
			} label: {
				Text("Continue")
					.bold()
			}
				.buttonStyle(.block)
			#endif // !os(macOS)
		}
			.padding()
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .confirmationAction) {
					Button("Close") {
						self.sheetStack.pop()
						self.viewState.handles.whatsNew?.increment()
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
			.environmentObject(SheetStack.shared)
	}
	
}
