//
//  SecondaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	@State private var unviewedAnnouncementsCount = 0
	
	@EnvironmentObject private var mapState: MapState
	
	@AppStorage("ViewedAnnouncementIDs") private var viewedAnnouncementIDs: Set<UUID> = []
	
	var body: some View {
		VStack {
			VStack(spacing: 0) {
				if #available(iOS 15, *), CalendarUtilities.isAprilFools {
					SecondaryOverlayButton(
						iconSystemName: "gearshape.fill",
						sheetType: .plus(featureText: "Changing settings"),
						badgeNumber: .constant(1)
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
						badgeNumber: .constant(1)
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
						badgeNumber: self.$unviewedAnnouncementsCount
					)
						.badge(self.unviewedAnnouncementsCount)
						.task {
							let announcements = await [Announcement].download()
							withAnimation {
								self.unviewedAnnouncementsCount = announcements.reduce(into: 0) { (partialResult, announcement) in
									if !self.viewedAnnouncementIDs.contains(announcement.id) {
										partialResult += 1
									}
								}
							}
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
					self.mapState.mapView?.setVisibleMapRect(
						self.mapState.routes.boundingMapRect,
						edgePadding: MapUtilities.Constants.mapRectInsets,
						animated: true
					)
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
