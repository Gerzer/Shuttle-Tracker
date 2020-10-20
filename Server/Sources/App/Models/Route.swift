//
//  Route.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 10/9/20.
//

import Vapor
import Fluent
import JSONParser

final class Route: Model, Content, Collection {
	
	static let schema = "routes"
	
	let startIndex = 0
	lazy var endIndex = self.coordinates.count - 1
	
	@ID var id: UUID?
	@Field(key: "coordinates") var coordinates: [Coordinate]
	@Field(key: "stopIDs") var stopIDs: [Int]
	
	init() { }
	
	init(_ coordinates: [Coordinate] = [], stopIDs: [Int]) {
		self.coordinates = coordinates
		self.stopIDs = stopIDs
	}
	
	subscript(position: Int) -> Coordinate {
		return self.coordinates[position]
	}
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
	}
	
}

extension Array where Element == Route {
	
	static func download(application app: Application, _ routesCallback: @escaping (_ routes: [Route]) -> Void) {
		_ = app.client.get("https://shuttles.rpi.edu/routes")
			.map { (response) in
				guard let length = response.body?.readableBytes, let data = response.body?.getData(at: 0, length: length) else {
					return
				}
				var routes = [Route]()
				let parser = ArrayJSONParser(data)
				do {
					try parser.parse().enumerated().forEach { (index, _) in
						let coordinates = parser[dictionaryAt: index]?["points", as: [[String: Double]].self]?.compactMap { (object) -> Coordinate? in
							guard let latitude = object["latitude"], let longitude = object["longitude"] else {
								return nil
							}
							return Coordinate(latitude: latitude, longitude: longitude)
						} ?? []
						let stopIDs = parser[dictionaryAt: index]!["stop_ids", as: [Int].self]!
						let route = Route(coordinates, stopIDs: stopIDs)
						routes.append(route)
					}
					routesCallback(routes)
				} catch {
					return
				}
			}
	}
	
}
