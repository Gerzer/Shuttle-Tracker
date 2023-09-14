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
	private var viewState: ViewState
	
	var body: some View {
		VStack {
			VStack(spacing: 0) {
				SecondaryOverlayButton(
                    iconSystemName: SFSymbols.settingsIcon.rawValue,
					sheetType: .settings
				)
				Divider()
					.frame(width: 45, height: 0)
				SecondaryOverlayButton(
                    iconSystemName: SFSymbols.informationsIcon.rawValue,
					sheetType: .info
				)
				Divider()
					.frame(width: 45, height: 0)
				SecondaryOverlayButton(
                    iconSystemName: SFSymbols.announcementsIcon.rawValue,
					sheetType: .announcements,
					badgeNumber: self.viewState.badgeNumber
				)
					.task {
						do {
							try await UNUserNotificationCenter.updateBadge()
						} catch let error {
							Logging.withLogger(for: .apns, doUpload: true) { (logger) in
								logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to update badge: \(error, privacy: .public)")
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
                SecondaryOverlayButton(iconSystemName: SFSymbols.recenterIcon.rawValue) {
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
		.environmentObject(ViewState.shared)
}
