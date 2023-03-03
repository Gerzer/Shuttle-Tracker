//
//  CloseButton.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct CloseButton: View {
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	private let dismissHandler: (() -> Void)?
	
	var body: some View {
		Button {
            #if os(iOS)
            if self.sheetStack.top == SheetStack.SheetType.busSelection {
                Task {
                    do {
                        try await Analytics.upload(eventType: .busSelectionCanceled)
                    } catch {
                        Logging.withLogger(for: .api, doUpload: true) { (logger) in
                            logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to upload analytics: \(error, privacy: .public)")
                        }
                    }
                }
            }
            #endif
            
			self.sheetStack.pop()
		} label: {
			Image(systemName: "xmark.circle.fill")
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
			.environmentObject(SheetStack())
	}
	
}
