//
//  SecondaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	private var unviewedAnnouncementsCount: Int {
		get {
			return self.announcements.reduce(into: 0) { (partialResult, announcement) in
				if !self.viewedAnnouncementIDs.contains(announcement.id) {
					partialResult += 1
				}
			}
		}
	}
	
	@State private var announcements: [Announcement] = []
	
	@EnvironmentObject private var mapState: MapState
	
	@AppStorage("ViewedAnnouncementIDs") private var viewedAnnouncementIDs: Set<UUID> = []
	
	var body: some View {
		VStack {
			VStack(spacing: 0) {
				if #available(iOS 15, *), CalendarUtilities.isAprilFools {
					SecondaryOverlayButton(
						iconSystemName: "gearshape.fill",
						sheetType: .plus(featureText: "Changing settings"),
						badgeNumber: 1
					)
				} else {
					SecondaryOverlayButton(
						iconSystemName: "gearshape.fill",
						sheetType: .settings
					)
				}
				Divider()
					.frame(width: 45, height: 0)
				if #available(iOS 15, *), CalendarUtilities.isAprilFools {
					SecondaryOverlayButton(
						iconSystemName: "info.circle.fill",
						sheetType: .plus(featureText: "Viewing app information"),
						badgeNumber: 1
					)
				} else {
					SecondaryOverlayButton(
						iconSystemName: "info.circle.fill",
						sheetType: .info
					)
				}
				if #available(iOS 15, *) {
					Divider()
						.frame(width: 45, height: 0)
					SecondaryOverlayButton(
						iconSystemName: "exclamationmark.bubble.fill",
						sheetType: .announcements,
						badgeNumber: self.unviewedAnnouncementsCount
					)
						.badge(self.unviewedAnnouncementsCount)
						.task {
							self.announcements = await [Announcement].download()
						}
				}
			}
				.background(
					VisualEffectView(.systemThickMaterial)
						.cornerRadius(10)
						.shadow(radius: 5)
				)
			VStack(spacing: 0) {
				SecondaryOverlayButton(iconSystemName: "location.fill.viewfinder") {
					Task {
						await self.mapState.resetVisibleMapRect()
					}
				}
			}
				.background(
					VisualEffectView(.systemThickMaterial)
						.cornerRadius(10)
						.shadow(radius: 5)
				)
		}
	}
	
}

struct SecondaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		SecondaryOverlay()
			.environmentObject(MapState.shared)
	}
	
}
