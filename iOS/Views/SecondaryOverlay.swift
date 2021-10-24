//
//  SecondaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/7/21.
//

import SwiftUI

struct SecondaryOverlay: View {
	
	var body: some View {
		VStack(spacing: 0) {
			SecondaryOverlayButton(iconSystemName: "gearshape.fill", sheetType: .settings)
			Divider()
				.frame(width: 45, height: 0)
			SecondaryOverlayButton(iconSystemName: "info.circle.fill", sheetType: .info)
		}
			.background(VisualEffectView(.systemThickMaterial))
			.cornerRadius(10)
			.shadow(radius: 5)
	}
	
}

struct SecondaryOverlayPreviews: PreviewProvider {
	
	static var previews: some View {
		SecondaryOverlay()
	}
	
}
