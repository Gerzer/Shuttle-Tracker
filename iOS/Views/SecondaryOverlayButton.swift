//
//  SecondaryOverlayButton.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct SecondaryOverlayButton: View {
	
	let iconSystemName: String
	
	let sheetType: SheetStack.SheetType
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	var body: some View {
		if #available(iOS 15.0, *) {
			Button {
				self.sheetStack.push(self.sheetType)
			} label: {
				Group {
					Image(systemName: self.iconSystemName)
						.resizable()
						.aspectRatio(1, contentMode: .fit)
						.opacity(0.5)
						.frame(width: 20)
				}
					.frame(width: 45, height: 45)
			}
				.tint(.primary)
		} else {
			Button {
				self.sheetStack.push(self.sheetType)
			} label: {
				Group {
					Image(systemName: self.iconSystemName)
						.resizable()
						.aspectRatio(1, contentMode: .fit)
						.opacity(0.5)
						.frame(width: 20)
				}
					.frame(width: 45, height: 45)
			}
				.buttonStyle(.plain)
		}
	}
	
}
