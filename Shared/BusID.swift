//
//  BusID.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 10/22/21.
//

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
	
	static func == (_ leftBusID: BusID, _ rightBusID: BusID) -> Bool {
		return leftBusID.id == rightBusID.id
	}
	
	static func < (_ leftBusID: BusID, _ rightBusID: BusID) -> Bool {
		return leftBusID.id < rightBusID.id
	}
	
}
