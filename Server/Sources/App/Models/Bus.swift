//
//  Bus.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import Vapor
import Fluent

final class Bus: Model {
	
	struct Location: Content {
		
		struct Coordinate: Equatable, Codable {
			
			var latitude: Double
			var longitude: Double
			
		}
		
		enum LocationType: String, Codable {
			
			case system = "system"
			case user = "user"
			
		}
		
		var id: UUID
		var date: Date
		var coordinate: Coordinate
		var type: LocationType
		
	}
	
	static let schema = "buses"
	
	var response: BusResponse? {
		get {
			guard let location = self.locations.resolvedLocation else {
				return nil
			}
			return BusResponse(id: self.id ?? 0, location: location)
		}
	}
	
	@ID(custom: "id", generatedBy: .user) var id: Int?
	@Field(key: "locations") var locations: [Location]
	
	init() { }
	
	init(id: Int, locations: [Location] = []) {
		self.id = id
		self.locations = locations
	}
	
}

extension Bus: Hashable {
	
	static func == (_ leftBus: Bus, _ rightBus: Bus) -> Bool {
		return leftBus.id == rightBus.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
}

extension Bus.Location: Equatable {
	
	static func == (_ leftLocation: Bus.Location, _ rightLocation: Bus.Location) -> Bool {
		return leftLocation.id == rightLocation.id
	}
	
}

extension Bus.Location.Coordinate {
	
	static func += (_ leftCoordinate: inout Bus.Location.Coordinate, _ rightCoordinate: Bus.Location.Coordinate) {
		leftCoordinate.latitude += rightCoordinate.latitude
		leftCoordinate.longitude += rightCoordinate.longitude
	}
	
	static func /= (_ coordinate: inout Bus.Location.Coordinate, _ divisor: Double) {
		coordinate.latitude /= divisor
		coordinate.longitude /= divisor
	}
	
}

extension Set where Element == Bus {
	
	static func download(application app: Application, _ busesCallback:  @escaping (_ buses: Set<Bus>) -> Void) {
		_ = app.client.get("https://shuttles.rpi.edu/datafeed")
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
					guard let timeRange = rawLine.range(of: #"(?<=(time:))\d{6}"#, options: [.regularExpression]), let dateRange = rawLine.range(of: #"(?<=(date:))\d{8}"#, options: [.regularExpression]) else {
						return nil
					}
					let formatter = DateFormatter()
					formatter.dateFormat = "HHmmss'|'MMddyyyy"
					formatter.timeZone = TimeZone(abbreviation: "UTC")!
					let dateString = "\(rawLine[timeRange])|\(rawLine[dateRange])"
					let date = formatter.date(from: dateString)!
					let coordinate = Bus.Location.Coordinate(latitude: latitude, longitude: longitude)
					let location = Bus.Location(id: UUID(), date: date, coordinate: coordinate, type: .system)
					return Bus(id: id, locations: [location])
				}
				busesCallback(Set(buses))
			}
	}
	
}

extension Set: Mergable where Element == Bus {
	
	mutating func merge(with otherBuses: Set<Bus>) {
		otherBuses.forEach { (bus) in
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
	
	var systemLocation: Bus.Location? {
		get {
			return self.reversed().first { (location) -> Bool in
				return location.type == .system
			}
		}
	}
	var userLocation: Bus.Location? {
		get {
			let userLocations = self.filter { (location) -> Bool in
				return location.type == .user
			}
			let newestLocation = userLocations.max { (firstLocation, secondLocation) -> Bool in
				return firstLocation.date.compare(secondLocation.date) == .orderedAscending
			}
			let zeroCoordinate = Bus.Location.Coordinate(latitude: 0, longitude: 0)
			var coordinate = userLocations.reduce(into: zeroCoordinate) { (coordinate, location) in
				coordinate += location.coordinate
			}
			coordinate /= Double(self.count)
			guard let userCoordinate = coordinate == zeroCoordinate ? nil : coordinate else {
				return nil
			}
			return Element(id: UUID(), date: newestLocation?.date ?? Date(), coordinate: userCoordinate, type: .user)
		}
	}
	var resolvedLocation: Bus.Location? {
		get {
			return self.userLocation ?? self.systemLocation
		}
	}
	
}

extension Array: Mergable where Element == Bus.Location {
	
	mutating func merge(with otherLocations: [Bus.Location]) {
		otherLocations.forEach { (location) in
			if let index = self.firstIndex(of: location) {
				self.remove(at: index)
			}
			self.append(location)
		}
	}
	
}

protocol Mergable: Collection {
	
	mutating func merge(with: Self);
	
}
