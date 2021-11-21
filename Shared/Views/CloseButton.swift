//
//  CloseButton.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct CloseButton: View {
	
	@EnvironmentObject private var viewState: ViewState
	
	var body: some View {
		if #available(iOS 15, macOS 12, *) {
			Button {
				self.viewState.sheetType = nil
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
				self.viewState.sheetType = nil
			} label: {
				Text("Close")
					.bold()
			}
		}
	}
}

struct CloseButtonPreviews: PreviewProvider {
	
	static var previews: some View {
		CloseButton()
			.environmentObject(ViewState.sharedInstance)
	}
	
}
