//
//  VisualEffectView.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
	
	var effect: UIVisualEffect?
	
	func makeUIView(context: Context) -> UIVisualEffectView {
		return UIVisualEffectView()
	}
	
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		uiView.effect = self.effect
	}
	
}
