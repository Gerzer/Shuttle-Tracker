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
		VStack(alignment: .leading) {
			HStack {
				Spacer()
				Text("What’s New")
					.font(.largeTitle)
					.bold()
					.multilineTextAlignment(.center)
				Spacer()
			}
				.padding(.bottom)
			Text("Announcements")
				.font(.headline)
			Text("Shuttle Tracker can now deliver announcements! We’ll use this feature to provide important, timely information, such as schedule changes. On iOS 15 or iPadOS 15, tap the new announcements icon in the overlay at the top-left corner of the screen; on macOS 12 Monterey, click the new announcements icon in the toolbar.")
			Spacer()
			#if !os(macOS)
			Button {
				self.viewState.whatsNewHandle?.increment()
				self.viewState.sheetType = nil
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
						self.viewState.whatsNewHandle?.increment()
						self.viewState.sheetType = nil
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
