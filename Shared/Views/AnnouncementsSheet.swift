//
//  AnnouncementsSheet.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import SwiftUI

@available(iOS 15, macOS 12, *)
struct AnnouncementsSheet: View {
	
	@State private var announcements: [Announcement]?
	
	@State private var didResetViewedAnnouncements = false
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	@AppStorage("ViewedAnnouncementIDs") private var viewedAnnouncementIDs: Set<UUID> = []
	
	var body: some View {
		NavigationView {
			Group {
				if let announcements = self.announcements {
					if announcements.count > 0 {
						List(announcements) { (announcement) in
							NavigationLink {
								AnnouncementDetailView(
									didResetViewedAnnouncements: self.$didResetViewedAnnouncements,
									announcement: announcement
								)
							} label: {
								HStack {
									let isUnviewed = !self.viewedAnnouncementIDs.contains(announcement.id)
									Circle()
									.fill(isUnviewed ? .blue : .clear)
										.frame(width: 10, height: 10)
									if #available(iOS 16, macOS 13, *) {
										Text(announcement.subject)
											.bold(isUnviewed)
									} else {
										Text(announcement.subject)
									}
								}
							}
						}
					} else {
						#if os(macOS)
						Text("No Announcements")
							.font(.callout)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.frame(minWidth: 100)
							.padding()
						#else // os(macOS)
						Text("No Announcements")
							.font(.title2)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.padding()
						#endif // os(macOS)
					}
				} else {
						ProgressView("Loading")
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
				.frame(minHeight: 300)
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
				ToolbarItem {
					Button(
						"Reset Viewed Announcements" + (self.didResetViewedAnnouncements ? " ✓" : ""),
						role: .destructive
					) {
						self.viewedAnnouncementIDs.removeAll()
						self.didResetViewedAnnouncements = true
					}
						.disabled(self.viewedAnnouncementIDs.isEmpty)
						.focusable(false)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Close") {
						self.sheetStack.pop()
					}
						.buttonStyle(.bordered)
						.keyboardShortcut(.cancelAction)
				}
				#endif // os(macOS)
			}
	}
	
}

@available(iOS 15, macOS 12, *)
struct AnnouncementsSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		AnnouncementsSheet()
			.environmentObject(ViewState.shared)
			.environmentObject(SheetStack())
	}
	
}
