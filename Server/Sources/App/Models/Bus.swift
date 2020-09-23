//
//  Bus.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import Vapor
import Fluent

final class Bus: Hashable, Model, Content {
	
	struct Location: Hashable, Content {
		
		struct Coordinate: Hashable, Content {
			
			var latitude: Double
			var longitude: Double
			
		}
		
		var id: UUID
		var date: Date
		var coordinate: Coordinate
		
	}
	
	static let schema = "buses"
	
	var response: BusResponse {
		get {
			return BusResponse(id: self.id ?? 0, location: self.locations.meanLocation)
		}
	}
	
	@ID(custom: "id", generatedBy: .user) var id: Int?
	@Field(key: "locations") var locations: [Location]
	
	init() { }
	
	init(id: Int, locations: [Location] = []) {
		self.id = id
		self.locations = locations
	}
	
	static func == (_ leftBus: Bus, _ rightBus: Bus) -> Bool {
		return leftBus.id == rightBus.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
}

extension Bus.Location {
	
	static func == (_ leftLocation: Self, _ rightLocation: Self) -> Bool {
		return leftLocation.id == rightLocation.id
	}
	
}

extension Bus.Location.Coordinate {
	
	static func * (_ coordinate: Self, _ factor: Double) -> Self {
		return self.init(latitude: coordinate.latitude * factor, longitude: coordinate.longitude * factor)
	}
	
	static func += (_ leftCoordinate: inout Self, _ rightCoordinate: Self) {
		leftCoordinate.latitude += rightCoordinate.latitude
		leftCoordinate.longitude += rightCoordinate.longitude
	}
	
	static func /= (_ coordinate: inout Self, _ divisor: Double) {
		coordinate.latitude /= divisor
		coordinate.longitude /= divisor
	}
	
}

extension Set where Element == Bus {
	
	static func download(application app: Application, _ busesCallback:  @escaping (_ buses: Set<Bus>) -> Void) {
		let _ = app.client.get("https://shuttles.rpi.edu/datafeed")
			.map { (response) in
				guard let length = response.body?.readableBytes, let data = response.body?.getData(at: 0, length: length), let rawString = String(data: data, encoding: .utf8) else {
					return
				}
				let buses = rawString.split(separator: "\r\n").dropFirst().dropLast().compactMap { (rawLine) -> Bus? in
					guard let idRange = rawLine.range(of: #"(?<=(Vehicle\sID:))\d+"#, options: [.regularExpression]), let id = Int(rawLine[idRange]) else {
						return nil
					}
					guard let latitudeRange = rawLine.range(of: #"(?<=(lat:))-?\d+\.\d+"#, options: [.regularExpression]), let latitude = Double(rawLine[latitudeRange]) else {
						return nil
					}
					guard let longitudeRange = rawLine.range(of: #"(?<=(lon:))-?\d+\.\d+"#, options: [.regularExpression]), let longitude = Double(rawLine[longitudeRange]) else {
						return nil
					}
					let coordinate = Bus.Location.Coordinate(latitude: latitude, longitude: longitude)
					let location = Bus.Location(id: UUID(), date: Date(), coordinate: coordinate)
					return Bus(id: id, locations: [location])
				}
				busesCallback(Set(buses))
			}
	}
	
	mutating func merge(with otherSet: Self) {
		otherSet.forEach { (bus) in
			if !self.insert(bus).inserted {
				guard let existingBus = self.remove(bus) else {
					fatalError()
				}
				existingBus.locations.merge(with: bus.locations)
				self.insert(existingBus)
			}
		}
	}
	
}

extension Collection where Element == Bus.Location {
	
	var meanCoordinate: Element.Coordinate {
		get {
			let oldestLocation = self.min { (firstLocation, secondLocation) in
				return firstLocation.date.compare(secondLocation.date) == .orderedAscending
			}
			let longestInterval = (oldestLocation?.date.timeIntervalSinceNow ?? -600) * -1
			var divisor: Double = 0
			var coordinate = self.reduce(into: Bus.Location.Coordinate(latitude: 0, longitude: 0)) { (coordinate, location) in
				let factor = longestInterval - location.date.timeIntervalSinceNow * -1
				coordinate += location.coordinate * factor
				divisor += factor
			}
			coordinate /= divisor
			return coordinate
		}
	}
	var meanLocation: Element {
		get {
			let newestLocation = self.max { (firstLocation, secondLocation) in
				return firstLocation.date.compare(secondLocation.date) == .orderedAscending
			}
			return Element(id: UUID(), date: newestLocation?.date ?? Date(), coordinate: self.meanCoordinate)
		}
	}
	
}

extension Array where Element == Bus.Location {
	
	mutating func merge(with otherArray: Self) {
		otherArray.forEach { (location) in
			if !self.contains(location) {
				self.append(location)
			}
		}
	}
	
}
