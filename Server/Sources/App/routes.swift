//
//  routes.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import Vapor
import Fluent

func routes(_ app: Application) throws {
	app.get { (request) in
		return request.redirect(to: "https://testflight.apple.com/join/Wzc4xn2h")
	}
	app.get("buses") { (request) in
		return Bus.query(on: request.db)
			.all()
			.mapEach { (bus) in
				return bus.response
			}
	}
	app.get("buses", ":id") { (request) -> EventLoopFuture<Bus.Location.Coordinate> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		return Bus.query(on: request.db)
			.filter(\.$id == id)
			.all()
			.map { (buses) in
				let locations = buses.flatMap { (bus) in
					return bus.locations
				}
				return locations.meanCoordinate
			}
	}
	app.post("buses", ":id") { (request) -> EventLoopFuture<EventLoopFuture<BusResponse>> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		return Bus.query(on: request.db)
			.all()
			.map { (buses) in
				let isUnique = buses.allSatisfy { (bus) in
					return bus.id != id
				}
				if !isUnique {
					return Bus.query(on: request.db)
						.filter(\.$id == id)
						.first()
						.map { (bus) in
							return bus!.response
						}
				}
				let bus = Bus(id: id)
				return bus.create(on: request.db)
					.map { (_) in
						return bus.response
					}
			}
	}
	app.patch("buses", ":id") { (request) -> EventLoopFuture<[Bus.Location]> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		let newLocation = try request.content.decode(Bus.Location.self)
		return Bus.query(on: request.db)
			.filter(\.$id == id)
			.first()
			.optionalMap { (bus) -> Bus in
				bus.locations.merge(with: [newLocation])
				let _ = bus.update(on: request.db)
				return bus
			}
			.map { (bus) in
				return bus?.locations ?? []
			}
	}
}

struct BusResponse: Content {
	
	var id: Int
	var location: Bus.Location
	
}

extension Set: Content, RequestDecodable, ResponseEncodable where Element: Codable { }
