//
//  SheetStack.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

enum SheetStack {
	
	enum SheetType: IdentifiableByHashValue {
		
		case welcome, settings, info, busSelection, privacy
		
	}
	
	private static var stack = [SheetType]()
	
	static var top: SheetType? {
		get {
			return self.stack.last
		}
		set {
			if let newValue = newValue {
				self.push(newValue)
			} else {
				self.pop()
			}
		}
	}
	
	static var sheetType: Binding<SheetType?> {
		get {
			let observedIndex = self.stack.count
			return Binding<SheetType?> {
				guard self.stack.count > observedIndex else {
					return nil
				}
				return self.stack[observedIndex]
			} set: { (newValue) in
				if self.stack.count == observedIndex {
					if let newValue = newValue {
						self.push(newValue)
					}
				} else if self.stack.count > observedIndex {
					if let newValue = newValue {
						self.stack[observedIndex] = newValue
					} else if self.stack.count - observedIndex == 1 {
						self.pop()
					}
				}
			}
		}
	}
	
	static func push(_ sheetType: SheetType) {
		self.stack.append(sheetType)
	}
	
	static func pop() {
		self.stack.removeLast()
	}
	
}
