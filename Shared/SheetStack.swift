//
//  SheetStack.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import Combine
import SwiftUI

final class SheetStack: ObservableObject {
	
	enum SheetType: IdentifiableByHashValue {
		
		case welcome, settings, info, busSelection, permissions, privacy, announcements, whatsNew, plus(featureText: String)
		
	}
	
	struct Handle {
		
		let observedIndex: Int
		
		fileprivate init(observedIndex: Int) {
			self.observedIndex = observedIndex
		}
		
	}
	
	static let shared = SheetStack()
	
	private var stack: [SheetType] = []
	
	let publisher = PassthroughSubject<[SheetType?], Never>()
	
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
	
	var count: Int {
		get {
			return self.stack.count
		}
	}
	
	private init() { }
	
	func push(_ sheetType: SheetType) {
		self.stack.append(sheetType)
		self.publisher.send(self.stack)
		self.objectWillChange.send()
	}
	
	func pop() {
		if !self.stack.isEmpty {
			self.stack.removeLast()
			self.publisher.send(self.stack)
			self.objectWillChange.send()
		}
	}
	
	func register() -> Handle {
		let observedIndex = self.stack.count
		let handle = Handle(observedIndex: observedIndex)
		return handle
	}
	
}
