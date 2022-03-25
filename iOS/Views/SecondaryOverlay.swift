//
//  SecondaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	@State private var announcementsCount = 0
	
	var body: some View {
		VStack(spacing: 0) {
			if #available(iOS 15, *), CalendarUtilities.isAprilFools {
				SecondaryOverlayButton(iconSystemName: "gearshape.fill", sheetType: .plus(featureText: "Changing settings"), badgeNumber: .constant(1))
			} else {
				SecondaryOverlayButton(iconSystemName: "gearshape.fill", sheetType: .settings)
			}
			Divider()
				.frame(width: 45, height: 0)
			if #available(iOS 15, *), CalendarUtilities.isAprilFools {
				SecondaryOverlayButton(iconSystemName: "info.circle.fill", sheetType: .plus(featureText: "Viewing app information"), badgeNumber: .constant(1))
			} else {
				SecondaryOverlayButton(iconSystemName: "info.circle.fill", sheetType: .info)
			}
			if #available(iOS 15, *) {
				Divider()
					.frame(width: 45, height: 0)
				SecondaryOverlayButton(iconSystemName: "exclamationmark.bubble.fill", sheetType: .announcements, badgeNumber: self.$announcementsCount)
					.badge(self.announcementsCount)
					.task {
						let announcements = await [Announcement].download()
						withAnimation {
							self.announcementsCount = announcements.count
						}
					}
			}
            if #available(iOS 15, *) {
            Divider()
                .frame(width: 45, height: 0)
                SecondaryOverlayButton(iconSystemName: "scroll.fill", sheetType: .milestones)
            }
		}
			.background(
				VisualEffectView(.systemThickMaterial)
					.cornerRadius(10)
					.shadow(radius: 5)
			)
	}
	
}

struct SecondaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		SecondaryOverlay()
	}
	
}
