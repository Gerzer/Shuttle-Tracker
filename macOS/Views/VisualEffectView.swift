//
//  VisualEffectView.swift
//  Shuttle Tracker (macOS)
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
	
	let material: NSVisualEffectView.Material
	
	let blendingMode: NSVisualEffectView.BlendingMode
	
	func makeNSView(context: Context) -> NSVisualEffectView {
		return NSVisualEffectView()
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		nsView.material = self.material
		nsView.blendingMode = self.blendingMode
	}
	
}
