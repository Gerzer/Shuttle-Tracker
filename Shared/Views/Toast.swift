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
				#if os(iOS)
				if #available(iOS 15, *) {
					Button {
						self.dismissalHandler()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.resizable()
							.frame(width: ViewUtilities.Constants.toastCloseButtonDimension, height: ViewUtilities.Constants.toastCloseButtonDimension)
					}
						.tint(.primary)
				} else {
					Button {
						self.dismissalHandler()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.resizable()
							.frame(width: ViewUtilities.Constants.toastCloseButtonDimension, height: ViewUtilities.Constants.toastCloseButtonDimension)
					}
						.buttonStyle(.plain)
				}
				#else // os(iOS)
				Button {
					self.dismissalHandler()
				} label: {
					Image(systemName: "xmark.circle.fill")
						.resizable()
						.frame(width: ViewUtilities.Constants.toastCloseButtonDimension, height: ViewUtilities.Constants.toastCloseButtonDimension)
				}
					.buttonStyle(.plain)
				#endif
			}
			self.content
		}
			.layoutPriority(0)
			.padding()
			.background(ViewUtilities.standardVisualEffectView)
			.cornerRadius(ViewUtilities.Constants.toastCornerRadius)
			.shadow(radius: 5)
	}
	
	init(_ headlineString: StringType, dismissalHandler: @escaping () -> Void, @ViewBuilder content: () -> Content) {
		self.headlineString = headlineString
		self.dismissalHandler = dismissalHandler
		self.content = content()
	}
	
}
