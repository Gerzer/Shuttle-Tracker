//
//  SheetStack.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 11/14/21.
//

import Combine
import OrderedCollections

@MainActor
final class SheetStack: ObservableObject {
	
	enum SheetType: Hashable, Identifiable {
		
		case announcements
		
		#if os(iOS)
		case busSelection
		#endif // os(iOS)
		
		#if os(iOS)
		case info
		#endif // os(iOS)
		
		#if os(iOS)
		case mailCompose(
			subject: String = "",
			toRecipients: OrderedSet<String> = [],
			ccRecipients: OrderedSet<String> = [],
			bccRecipients: OrderedSet<String> = [],
			messageBody: String = "",
			isHTMLMessageBody: Bool = false,
			attachments: [MailComposeView.Attachment] = []
		)
		#endif // os(iOS)
		
		#if os(iOS) && !APPCLIP
		case permissions
		#endif // os(iOS) && !APPCLIP
		
		case privacy
		
		#if os(iOS) && !APPCLIP
		case settings
		#endif // os(iOS) && !APPCLIP
		
		#if os(iOS) && !APPCLIP
		case welcome
		#endif // os(iOS) && !APPCLIP
		
		#if !APPCLIP
		case whatsNew
		#endif // !APPCLIP
		
		var id: Self {
			get {
				return self
			}
		}
		
	}
	
	struct Handle {
		
		let observedIndex: Int
		
		fileprivate init(observedIndex: Int) {
			self.observedIndex = observedIndex
		}
		
	}
	
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
	
	init() { }
	
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
		return Handle(observedIndex: self.stack.count)
	}
	
}
