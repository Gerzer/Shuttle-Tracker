//
//  VisualEffectView.swift
//  Rensselaer Shuttle (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
	
	var blendingMode: NSVisualEffectView.BlendingMode
	
	var material: NSVisualEffectView.Material
	
	func makeNSView(context: Context) -> NSVisualEffectView {
		return NSVisualEffectView()
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		nsView.blendingMode = self.blendingMode
		nsView.material = self.material
	}
	
}
