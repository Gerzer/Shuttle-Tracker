//
//  BlockButton.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/22/20.
//

import SwiftUI

struct BlockButtonStyle: ButtonStyle {
	
	@State var color = Color.accentColor
	
	struct BlockButton: View {
		
		let configuration: BlockButtonStyle.Configuration
		
		@State var color: Color
		
		@Environment(\.isEnabled) var isEnabled
		
		var body: some View {
			self.configuration.label
				.frame(maxWidth: .infinity)
				.background(self.isEnabled ? self.color : Color.gray)
				.foregroundColor(.white)
				.opacity(self.configuration.isPressed ? 0.5 : 1)
				.cornerRadius(10)
		}
		
	}
	
	func makeBody(configuration: Configuration) -> some View {
		return BlockButton(configuration: configuration, color: self.color)
	}
	
}

struct BlockButtonPreviews: PreviewProvider {
	
	static var previews: some View {
		Button {
			
		} label: {
			Text("Do Something")
				.padding(10)
		}
			.buttonStyle(BlockButtonStyle())
			.padding()
	}
	
}
