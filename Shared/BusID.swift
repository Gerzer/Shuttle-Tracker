//
//  BusID.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

// TODO: Revisit choice to implement a non-interned wrapper class
final class BusID: Equatable, Comparable, Identifiable, RawRepresentable {
	
	let id: Int
	
	var rawValue: Int {
		get {
			return self.id
		}
	}
	
	init(_ id: Int) {
		self.id = id
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
