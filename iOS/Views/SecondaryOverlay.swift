//
//  SecondaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	@EnvironmentObject private var navigationState: NavigationState
	
	var body: some View {
		VStack(spacing: 0) {
			Button {
				self.navigationState.sheetType = .settings
			} label: {
				Image(systemName: "gearshape.fill")
					.styledForSecondaryOverlay()
			}
				.styledForSecondaryOverlay()
			Divider()
				.frame(width: 45, height: 0)
			Button {
				self.navigationState.sheetType = .info
			} label: {
				Image(systemName: "info.circle.fill")
					.styledForSecondaryOverlay()
			}
				.styledForSecondaryOverlay()
		}
			.background(VisualEffectView(.systemThickMaterial))
			.cornerRadius(10)
			.shadow(radius: 5)
	}
	
}

struct SecondaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		SecondaryOverlay()
			.environmentObject(NavigationState.sharedInstance)
	}
	
}

fileprivate extension Button {
	
	func styledForSecondaryOverlay() -> some View {
		return self
			.buttonStyle(.plain)
			.frame(width: 45, height: 45)
			.contentShape(Rectangle())
	}
	
}

fileprivate extension Image {
	
	func styledForSecondaryOverlay() -> some View {
		return self
			.resizable()
			.aspectRatio(1, contentMode: .fit)
			.opacity(0.5)
			.frame(width: 20)
	}
	
}
