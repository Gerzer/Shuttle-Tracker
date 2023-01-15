//
//  SecondaryOverlayButton.swift
//  Shuttle Tracker (iOS)
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct SecondaryOverlayButton: View {
	
	let iconSystemName: String
	
	let sheetType: SheetStack.SheetType?
	
	let action: (() -> Void)?
	
	let badgeNumber: Int
	
	@EnvironmentObject
	private var viewState: ViewState
	
	@EnvironmentObject
	private var sheetStack: SheetStack
	
	var body: some View {
		Button {
			if let sheetType = self.sheetType {
				self.sheetStack.push(sheetType)
			} else {
				self.action?()
			}
		} label: {
			Group {
				Image(systemName: self.iconSystemName)
					.resizable()
					.aspectRatio(1, contentMode: .fit)
					.opacity(0.5)
					.frame(width: 20)
			}
				.frame(width: 45, height: 45)
				.overlay {
					if self.badgeNumber > 0 {
						ZStack {
							Circle()
								.foregroundColor(.red)
							Text("\(self.badgeNumber)")
								.foregroundColor(.white)
								.font(.caption)
								.dynamicTypeSize(...DynamicTypeSize.accessibility1)
						}
							.frame(width: 20, height: 20)
							.offset(x: 20, y: -20)
					}
				}
		}
			.tint(.primary)
	}
	
	init(iconSystemName: String, sheetType: SheetStack.SheetType, badgeNumber: Int = 0) {
		self.iconSystemName = iconSystemName
		self.sheetType = sheetType
		self.action = nil
		self.badgeNumber = badgeNumber
	}
	
	init(iconSystemName: String, badgeNumber: Int = 0, _ action: @escaping () -> Void) {
		self.iconSystemName = iconSystemName
		self.sheetType = nil
		self.action = action
		self.badgeNumber = badgeNumber
	}
	
}
