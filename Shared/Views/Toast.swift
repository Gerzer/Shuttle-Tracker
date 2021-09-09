//
//  Toast.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/8/21.
//

import SwiftUI

struct Toast<StringType, Content>: View where StringType: StringProtocol, Content: View {
	
	private var headlineString: StringType
	
	private var dismissalHandler: () -> Void
	
	private var content: Content
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(self.headlineString)
					.font(.headline)
				Spacer()
				Button {
					self.dismissalHandler()
				} label: {
					Image(systemName: "xmark.circle.fill")
						.resizable()
						.frame(width: ViewUtilities.Toast.closeButtonDimension, height: ViewUtilities.Toast.closeButtonDimension)
				}
					.buttonStyle(.plain)
			}
			self.content
		}
			.layoutPriority(0)
			.padding()
			.background(ViewUtilities.standardVisualEffectView)
			.cornerRadius(ViewUtilities.Toast.cornerRadius)
	}
	
	init(_ headlineString: StringType, dismissalHandler: @escaping () -> Void, @ViewBuilder content: () -> Content) {
		self.headlineString = headlineString
		self.dismissalHandler = dismissalHandler
		self.content = content()
	}
	
}
