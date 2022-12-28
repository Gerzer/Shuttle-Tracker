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
							Text("Version 1.6")
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
					VStack(alignment: .leading, spacing: 20) {
						HStack(alignment: .top) {
							Image(systemName: "text.redaction")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Logging")
									.font(.headline)
								Text("Shuttle Tracker now automatically detects errors and uploads diagnostic logs when they occur. You can see a record of recently uploaded logs or disable automatic uploads entirely in Settings > Logging & Analytics.")
							}
						}
						#if os(macOS)
						HStack(alignment: .top) {
							Image(systemName: "exclamationmark.bubble")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Announcements")
									.font(.headline)
								Text("The Announcements button in the toolbar now shows a badge with the number of unviewed announcements.")
							}
						}
						#endif // os(macOS)
						HStack(alignment: .top) {
							Image(systemName: "squareshape.squareshape.dashed")
								.resizable()
								.scaledToFit()
								.frame(width: 40, height: 40)
							VStack(alignment: .leading) {
								Text("Design")
									.font(.headline)
								Text("We’ve made many small design improvements throughout the app.")
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
			Button {
				self.sheetStack.pop()
				self.viewState.handles.whatsNew?.increment()
			} label: {
				Text("Continue")
					.bold()
			}
				.buttonStyle(.block)
				.padding(.horizontal)
				.padding(.bottom)
			#endif // os(iOS)
		}
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .confirmationAction) {
					Button("Close") {
						self.sheetStack.pop()
						self.viewState.handles.whatsNew?.increment()
						
						// TODO: Switch to SwiftUI’s requestReview environment value when we drop support for iOS 15
						// Request a review on the App Store
						// This logic uses the legacy SKStoreReviewController class because the newer SwiftUI requestReview environment value requires iOS 16 or newer, and stored properties can’t be gated on OS version.
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
