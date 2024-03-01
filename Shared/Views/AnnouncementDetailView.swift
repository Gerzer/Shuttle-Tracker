//
//  AnnouncementDetailView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import SwiftUI
import UserNotifications

struct AnnouncementDetailView: View {
	
	let announcement: Announcement
	
	@Binding
	private(set) var didResetViewedAnnouncements: Bool
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	var body: some View {
		ScrollView {
			#if os(macOS)
			HStack {
				Text(self.announcement.subject)
					.font(.headline)
				Spacer()
			}
				.padding(.top)
			#endif // os(macOS)
			HStack {
				Text(self.announcement.body)
				Spacer()
			}
			HStack {
				switch self.announcement.scheduleType {
				case .none:
					EmptyView()
				case .startOnly:
					Text("Posted \(self.announcement.startString)")
				case .endOnly:
					Text("Expires \(self.announcement.endString)")
				case .startAndEnd:
					Text("Posted \(self.announcement.startString); expires \(self.announcement.endString)")
				}
				Spacer()
			}
				.font(.footnote)
				.foregroundColor(.secondary)
				.padding(.bottom)
		}
			.padding(.horizontal)
			.frame(minWidth: 300)
			.navigationTitle(self.announcement.subject)
			.toolbar {
				#if os(iOS)
				ToolbarItem {
					CloseButton()
				}
				#elseif os(macOS) // os(iOS)
				// TODO: Move conditional outside the ToolbarItem’s closure when we drop support for macOS 12
				// macOS 13 doesn’t support conditional toolbar builders, so we need to put the conditional inside the ToolbarItem’s closure for now, even though it’s not quite semantically correct to do so.
				ToolbarItem(placement: .confirmationAction) {
					if case .some(.announcement) = self.sheetStack.top {
						Button("Close") {
							self.sheetStack.pop()
						}
					}
				}
				#endif // os(macOS)
			}
			.task {
				self.didResetViewedAnnouncements = false
				self.appStorageManager.viewedAnnouncementIDs.insert(self.announcement.id)
				
				do {
					try await UNUserNotificationCenter.updateBadge()
				} catch let error {
					Logging.withLogger(for: .apns, doUpload: true) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to update badge: \(error, privacy: .public)")
					}
				}
				
				do {
					try await Analytics.upload(eventType: .announcementViewed(id: self.announcement.id))
				} catch {
					Logging.withLogger(for: .api) { (logger) in
						logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics entry: \(error, privacy: .public)")
					}
				}
			}
	}
	
	init(announcement: Announcement, didResetViewedAnnouncements: Binding<Bool> = .constant(false)) {
		self.announcement = announcement
		self._didResetViewedAnnouncements = didResetViewedAnnouncements
	}
	
}
