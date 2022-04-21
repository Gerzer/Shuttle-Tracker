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
                    Group{
                        Divider()
                        Text("NAVIGATION")
                            .font(.system(size: 16, weight: .light, design: .default))
                            .padding(.top)
                        Text("We’ve significantly improved the app’s navigation structure, so it’s now much easier to find information and additional functionality.")
                        Rectangle().fill(Color.clear).frame(height: 8)
                        Divider()
                    }
                    Group{
                        Text("PERMISSIONS")
                            .font(.system(size: 16, weight: .light, design: .default))
                            .padding(.top)
                        Text("Board Bus requires location access, so we’ll now prompt you to share your location on iOS and iPadOS.")
                        Rectangle().fill(Color.clear).frame(height: 8)
                        Divider()
                    }
                    Group{
                        Text("NOTIFICATIONS")
                            .font(.system(size: 16, weight: .light, design: .default))
                            .padding(.top)
                        Text("On iOS and iPadOS, we’ll notify you if you forget to tap “Leave Bus”.")
                        Rectangle().fill(Color.clear).frame(height: 8)
                        Divider()

                    }
                    Group{
                        Text("RE-CENTER BUTTON")
                            .font(.system(size: 16, weight: .light, design: .default))
                            .padding(.top)
                        Text("You can re-center the map with the new re-center button.")
                        Rectangle().fill(Color.clear).frame(height: 8)
                        Divider()

                        
                    }
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
