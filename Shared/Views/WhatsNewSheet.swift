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
								Text("Version 1.3")
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
					Text("Navigation")
						.font(.headline)
						.padding(.top)
					Text("We’ve significantly improved the app navigation structure, so it’s now much easier to find information and additional functionality.")
					Text("Permissions")
						.font(.headline)
						.padding(.top)
					Text("Board Bus requires location access, so we’ll now prompt you to share your location.")
					Text("Notifications")
						.font(.headline)
						.padding(.top)
					Text("We’ll notify you if you forget to tap “Leave Bus”.")
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
