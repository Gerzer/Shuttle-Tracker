import Vapor
import Fluent

func routes(_ app: Application) throws {
	app.get { (request) in
		return "It doesn't work."
	}
	app.get("hello") { (request) in
		return "Hello, world!"
	}
	app.get("buses", ":id") { (request) -> EventLoopFuture<[Bus.Location]> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		return Bus
			.query(on: request.db)
			.filter(\.$id == id)
			.all()
			.flatMapResult { (buses) -> Result<[Bus.Location], Error> in
				return Result {
					return buses.flatMap { (bus) in
						return bus.locations
					}
				}
			}
	}
	app.post("buses", ":id") { (request) -> EventLoopFuture<EventLoopFuture<Bus>> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		return Bus
			.query(on: request.db)
			.all()
			.map { (buses: [Bus]) in
				let isUnique = buses.allSatisfy { (bus) in
					return bus.id != id
				}
				if !isUnique {
					return Bus
						.query(on: request.db)
						.filter(\.$id == id)
						.first()
						.map { (bus) in
							return bus!
						}
				}
				let bus = Bus(id: id)
				return bus
					.create(on: request.db)
					.map { (_) in
						return bus
					}
			}
	}
	app.patch("buses", ":id") { (request) -> EventLoopFuture<[Bus.Location]> in
		guard let id = request.parameters.get("id", as: Int.self) else {
			throw Abort(.badRequest)
		}
		let newLocation = try request.content.decode(Bus.Location.self)
		return Bus
			.query(on: request.db)
			.filter(\.$id == id)
			.first()
			.optionalMap { (bus) -> Bus in
				let index = bus.locations.firstIndex { (location) in
					return location.id == newLocation.id
				}
				if let index = index {
					bus.locations[index].latitude = newLocation.latitude
					bus.locations[index].longitude = newLocation.longitude
				} else {
					bus.locations.append(newLocation)
				}
				let _ = bus
					.update(on: request.db)
				return bus
			}
			.map { (bus) -> ([Bus.Location]) in
				return bus?.locations ?? []
			}
	}
	try app.register(collection: BusController())
}
