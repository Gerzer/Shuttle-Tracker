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
		VStack {
			Button {
				print("YAY")
				self.navigationState.sheetType = .settings
			} label: {
				Image(systemName: "gearshape")
					.resizable()
					.aspectRatio(1, contentMode: .fit)
					.opacity(0.5)
			}
				.buttonStyle(.plain)
		}
			.frame(width: 20)
			.padding()
			.background(ViewUtilities.standardVisualEffectView)
			.cornerRadius(10)
			.shadow(radius: 5)
	}
	
}

struct SecondaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		SecondaryOverlay()
	}
	
}
