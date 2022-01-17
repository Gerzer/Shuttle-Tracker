//
//  WhatsNewSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import SwiftUI

struct WhatsNewSheet: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		VStack {
			ScrollView {
				VStack(alignment: .leading) {
					HStack {
						Spacer()
						Text("What’s New")
							.font(.largeTitle)
							.bold()
							.multilineTextAlignment(.center)
						Spacer()
					}
					Text("Announcements")
						.font(.headline)
						.padding(.top)
					Text("Shuttle Tracker can now deliver announcements! We’ll use this feature to provide important, timely information, such as schedule changes. On iOS 15 or iPadOS 15, tap the new announcements icon in the overlay at the top-left corner of the screen; on macOS 12 Monterey, click the new announcements icon in the toolbar.")
					Text("Onboarding")
						.font(.headline)
						.padding(.top)
					Text("Tapping “Board Bus” is the best way to help make Shuttle Tracker more accurate for everyone, so on iOS and iPadOS we’ll now remind you to start crowd-sourcing if you haven’t done so before.")
					Text("Design")
						.font(.headline)
						.padding(.top)
					Text("We’ve implemented some small design tweaks to make Shuttle Tracker even easier to use.")
				}
					.padding(.bottom)
			}
			#if !os(macOS)
			Button {
				self.viewState.sheetType = nil
				self.viewState.handles.whatsNew?.increment()
			} label: {
				Text("Continue")
					.bold()
			}
				.buttonStyle(BlockButtonStyle())
			#endif // !os(macOS)
		}
			.padding()
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .confirmationAction) {
					Button("Close") {
						self.viewState.sheetType = nil
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
	}
	
}
