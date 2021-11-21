//
//  AnnouncementsSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import SwiftUI

@available(iOS 15, macOS 12, *) struct AnnouncementsSheet: View {
	
	@State private var announcements: [Announcement]?
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		NavigationView {
			Group {
				if let announcements = self.announcements {
					if announcements.count > 0 {
						List(announcements) { (announcement) in
							NavigationLink(announcement.subject) {
								AnnouncementDetailView(announcement: announcement)
							}
						}
					} else {
						#if os(macOS)
						Text("No Announcements")
							.font(.callout)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.padding()
						#else // os(macOS)
						Text("No Announcements")
							.font(.title2)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.padding()
						#endif
					}
				} else {
						ProgressView("Loading…")
							.font(.callout)
							.textCase(.uppercase)
							.foregroundColor(.secondary)
							.padding()
				}
				Text("No Announcement Selected")
					.font(.title2)
					.multilineTextAlignment(.center)
					.foregroundColor(.secondary)
					.padding()
			}
				.navigationTitle("Announcements")
				.toolbar {
					#if !os(macOS)
					ToolbarItem {
						CloseButton()
					}
					#endif // !os(macOS)
				}
		}
			.task {
				self.announcements = await [Announcement].download()
			}
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .cancellationAction) {
					Button("Close") {
						self.viewState.sheetType = nil
					}
						.buttonStyle(.bordered)
						.keyboardShortcut(.cancelAction)
				}
				#endif // os(macOS)
			}
	}
	
}

@available(iOS 15, macOS 12, *) struct AnnouncementsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		AnnouncementsSheet()
			.environmentObject(ViewState.sharedInstance)
	}
	
}
