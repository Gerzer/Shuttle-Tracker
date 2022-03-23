//
//  SecondaryOverlayButton.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/23/21.
//

import SwiftUI

struct SecondaryOverlayButton: View {
	
	private let iconSystemName: String
	
	private let sheetType: SheetStack.SheetType?
	
	private let action: (() -> Void)?
	
	@Binding private(set) var badgeNumber: Int
	
	@EnvironmentObject private var viewState: ViewState
	
	@EnvironmentObject private var sheetStack: SheetStack
	
	var body: some View {
		if #available(iOS 15, *) {
			Button {
				if let sheetType = self.sheetType {
					self.sheetStack.push(sheetType)
				} else {
					self.action?()
				}
				withAnimation {
					self.badgeNumber = 0
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
							}
								.frame(width: 20, height: 20)
								.offset(x: 20, y: -20)
						}
					}
			}
				.tint(.primary)
		} else {
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
			}
				.buttonStyle(.plain)
		}
	}
	
	init(iconSystemName: String, sheetType: SheetStack.SheetType, badgeNumber: Binding<Int> = .constant(0)) {
		self.iconSystemName = iconSystemName
		self.sheetType = sheetType
		self.action = nil
		self._badgeNumber = badgeNumber
	}
	
	init(iconSystemName: String, badgeNumber: Binding<Int> = .constant(0), _ action: @escaping () -> Void) {
		self.iconSystemName = iconSystemName
		self.sheetType = nil
		self.action = action
		self._badgeNumber = badgeNumber
	}
	
}
