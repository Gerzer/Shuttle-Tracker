//
//  WhatsNewItem.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 3/22/23.
//

import SwiftUI

struct WhatsNewItem: View {
	
	let title: String
	
	let description: String
	
	let icon: SFSymbol
	
	let symbolRenderingMode: SymbolRenderingMode
	
	var body: some View {
		HStack(alignment: .top) {
			Image(systemName: self.icon.rawValue)
				.symbolRenderingMode(self.symbolRenderingMode)
				.resizable()
				.scaledToFit()
				.frame(width: 40, height: 40)
				.padding(.trailing, 20)
			VStack(alignment: .leading) {
				Text(self.title)
					.font(.headline)
				Text(self.description)
			}
		}
	}
	
	init(
		title: String,
		description: String,
		icon: SFSymbol,
		symbolRenderingMode: SymbolRenderingMode = .multicolor
	) {
		self.title = title
		self.description = description
		self.icon = icon
		self.symbolRenderingMode = symbolRenderingMode
	}
	
}

struct WhatsNewPreviews: PreviewProvider {
	
	static var previews: some View {
		WhatsNewItem(
			title: "Shuttle Tracker Network",
			description: "The Shuttle Tracker app uses the Shuttle Tracker Network to connect to Shuttle Tracker Node, our custom bus-tracking device, to unlock Automatic Board Bus. Shuttle Tracker never collects your location when you’re not physically riding a bus.",
			icon: .whatsNewNetwork,
			symbolRenderingMode: .hierarchical
		)
	}
	
}
