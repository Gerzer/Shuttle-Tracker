//
//  CloseButton.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct CloseButton: View {
	
	private let dismissHandler: (() -> Void)?
	
	var body: some View {
		if #available(iOS 15.0, *) {
			Button {
				SheetStack.pop()
			} label: {
				Image(systemName: "xmark.circle.fill")
					.symbolRenderingMode(.hierarchical)
					.resizable()
					.opacity(0.5)
					.frame(width: ViewUtilities.Constants.sheetCloseButtonDimension, height: ViewUtilities.Constants.sheetCloseButtonDimension)
			}
				.tint(.primary)
		} else {
			Button {
				if let dismissHandler = self.dismissHandler {
					dismissHandler()
				} else {
					SheetStack.pop()
				}
			} label: {
				Text("Close")
					.bold()
			}
		}
	}
	
	init(_ dismissHandler: (() -> Void)? = nil) {
		self.dismissHandler = dismissHandler
	}
	
}

struct CloseButtonPreviews: PreviewProvider {
	
	static var previews: some View {
		CloseButton()
			.environmentObject(ViewState.sharedInstance)
	}
	
}
