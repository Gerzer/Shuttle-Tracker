//
//  SecondaryOverlay.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	@State
	private var announcements: [Announcement] = []
	
	@Binding
	private var mapCameraPosition: MapCameraPositionWrapper
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var appStorageManager: AppStorageManager
	
	private var unviewedAnnouncementsCount: Int {
		get {
			return self.announcements
				.filter { (announcement) in
					return !self.appStorageManager.viewedAnnouncementIDs.contains(announcement.id)
				}
				.count
		}
	}
	
	var body: some View {
		VStack {
			VStack(spacing: 0) {
				SecondaryOverlayButton(
					iconSystemName: "gearshape.fill",
					sheetType: .settings
				)
				Divider()
					.frame(width: 45, height: 0)
				SecondaryOverlayButton(
					iconSystemName: "info.circle.fill",
					sheetType: .info
				)
				Divider()
					.frame(width: 45, height: 0)
				SecondaryOverlayButton(
					iconSystemName: "exclamationmark.bubble.fill",
					sheetType: .announcements,
					badgeNumber: self.unviewedAnnouncementsCount
				)
					.task {
						self.announcements = await [Announcement].download()
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
						await self.mapState.recenter(position: self.$mapCameraPosition)
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
	
	init(mapCameraPosition: Binding<MapCameraPositionWrapper>) {
		self._mapCameraPosition = mapCameraPosition
	}
	
}

@available(iOS 17, *)
#Preview {
	SecondaryOverlay(mapCameraPosition: .constant(MapCameraPositionWrapper(MapConstants.defaultCameraPosition)))
		.environmentObject(MapState.shared)
}
