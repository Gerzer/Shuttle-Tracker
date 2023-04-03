//
//  SecondaryOverlay.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	@EnvironmentObject
	private var mapState: MapState
	
	@EnvironmentObject
	private var viewState: ViewState
	
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
			.environmentObject(ViewState.shared)
	}
	
}
