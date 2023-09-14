//
//  CloseButton.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct CloseButton: View {
	
	@EnvironmentObject
	private var sheetStack: ShuttleTrackerSheetStack
	
	private let dismissHandler: (() -> Void)?
	
	var body: some View {
		Button {
			self.sheetStack.pop()
		} label: {
            Image(systemName: SFSymbols.closeXMark.rawValue)
				.symbolRenderingMode(.hierarchical)
				.resizable()
				.opacity(0.5)
				.frame(width: ViewConstants.sheetCloseButtonDimension, height: ViewConstants.sheetCloseButtonDimension)
		}
			.tint(.primary)
	}
	
	init(_ dismissHandler: (() -> Void)? = nil) {
		self.dismissHandler = dismissHandler
	}
	
}

struct CloseButtonPreviews: PreviewProvider {
	
	static var previews: some View {
		CloseButton()
			.environmentObject(ShuttleTrackerSheetStack())
	}
	
}
