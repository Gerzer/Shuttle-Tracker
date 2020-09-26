//
//  routes.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import Vapor
import Fluent

func routes(_ app: Application) throws {
	app.get { (request) -> Response in
		return request.redirect(to: "https://testflight.apple.com/join/Wzc4xn2h")
	}
	app.get("buses") { (request) -> EventLoopFuture<[BusResponse]> in
		return Bus.query(on: request.db)
			.all()
			.flatMapEachCompactThrowing { (bus) -> BusResponse? in
				guard let response = bus.response else {
					return nil
				}
				return response
			}
	}
	app.get("buses", ":id") { (request) -> EventLoopFuture<Bus.Location> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		return Bus.query(on: request.db)
			.filter(\.$id == id)
			.all()
			.flatMapThrowing { (buses) -> Bus.Location in
				let locations = buses.flatMap { (bus) -> [Bus.Location] in
					return bus.locations
				}
				guard let location = locations.resolvedLocation else {
					throw Abort(.notFound)
				}
				return location
			}
	}
	app.post("buses", ":id") { (request) -> VoidResponse in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		_ = Bus.query(on: request.db)
			.all()
			.map { (buses) in
				let isUnique = buses.allSatisfy { (bus) -> Bool in
					return bus.id != id
				}
				if !isUnique {
					_ = Bus.query(on: request.db)
						.filter(\.$id == id)
						.first()
						.flatMapThrowing { (bus) in
							throw Abort(.noContent)
						}
				}
				let bus = Bus(id: id)
				_ = bus.create(on: request.db)
					.flatMapThrowing { (_) in
						throw Abort(.created)
					}
			}
		return VoidResponse()
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
				_ = bus.update(on: request.db)
				return bus
			}
			.map { (bus) -> [Bus.Location] in
				return bus?.locations ?? []
			}
	}
}

struct VoidResponse: Content { }

struct BusResponse: Content {
	
	var id: Int
	var location: Bus.Location
	
}

extension Set: Content, RequestDecodable, ResponseEncodable where Element: Codable { }
