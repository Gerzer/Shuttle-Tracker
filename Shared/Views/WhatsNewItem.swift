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
	
	let iconSystemName: String
	
	let symbolRenderingMode: SymbolRenderingMode
	
	var body: some View {
		HStack(alignment: .top) {
			Image(systemName: self.iconSystemName)
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
		iconSystemName: String,
		symbolRenderingMode: SymbolRenderingMode = .multicolor
	) {
		self.title = title
		self.description = description
		self.iconSystemName = iconSystemName
		self.symbolRenderingMode = symbolRenderingMode
	}
	
}

struct WhatsNewPreviews: PreviewProvider {
	
	static var previews: some View {
		WhatsNewItem(
			title: "Shuttle Tracker Network",
			description: "The Shuttle Tracker app uses the Shuttle Tracker Network to connect to Shuttle Tracker Node, our custom bus-tracking device, to unlock Automatic Board Bus. Shuttle Tracker never collects your location when you’re not physically riding a bus.",
			iconSystemName: "point.3.connected.trianglepath.dotted",
			symbolRenderingMode: .hierarchical
		)
	}
	
}
