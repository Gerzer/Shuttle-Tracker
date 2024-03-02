//
//  BusID.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

// TODO: Revisit choice to implement a non-interned wrapper class
final class BusID: Equatable, Comparable, Identifiable, RawRepresentable {
	
	static let unknown = BusID()
	
	let id: Int
	
	var isUnknown: Bool {
		get {
			return self.id < 0
		}
	}
	
	var rawValue: Int {
		get {
			return self.id
		}
	}
	
	init?(_ id: Int) {
		guard id > 0 else {
			return nil
		}
		self.id = id
	}
	
	private init() {
		self.id = .random(in: Int(Int8.min) ..< 0)
	}
	
	required init(rawValue: Int) {
		self.id = rawValue
	}
	
	static func == (_ left: BusID, _ right: BusID) -> Bool {
		return left.id == right.id
	}
	
	static func < (_ left: BusID, _ right: BusID) -> Bool {
		return left.id < right.id
	}
	
}
