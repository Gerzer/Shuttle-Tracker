//
//  SheetStack.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import SwiftUI

class SheetStack: ObservableObject {
	
	enum SheetType: IdentifiableByHashValue {
		
		case welcome, settings, info, busSelection, privacy
		
	}
	
	struct Handle: Hashable {
		
		fileprivate let id: UUID
		
		fileprivate init() {
			self.id = UUID()
		}
		
	}
	
	static let shared = SheetStack()
	
	private var stack: [SheetType] = []
	
	private var bindings: [Handle: Binding<SheetType?>] = [:]
	
	var top: SheetType? {
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
	
	private init() { }
	
	subscript(_ handle: Handle) -> Binding<SheetType?> {
		get {
			return self.bindings[handle]!
		}
	}
	
	func push(_ sheetType: SheetType) {
		self.stack.append(sheetType)
		self.objectWillChange.send()
	}
	
	func pop() {
		if !self.stack.isEmpty {
			self.stack.removeLast()
			self.objectWillChange.send()
		}
	}
	
	func register() -> Handle {
		let observedIndex = self.stack.count
		let binding = Binding<SheetType?> {
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
		let handle = Handle()
		self.bindings[handle] = binding
		return handle
	}
	
}
