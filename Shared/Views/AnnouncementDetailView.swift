//
//  AnnouncementDetailView.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/20/21.
//

import SwiftUI

struct AnnouncementDetailView: View {
	
	let announcement: Announcement
	
	var body: some View {
		ScrollView {
			HStack {
				Text(self.announcement.body)
				Spacer()
			}
			Spacer()
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
		}
			.padding(.horizontal)
			.frame(minWidth: 300)
			.navigationTitle(self.announcement.subject)
			.toolbar {
				#if !os(macOS)
				ToolbarItem {
					CloseButton()
				}
				#endif // !os(macOS)
			}
	}
	
}
