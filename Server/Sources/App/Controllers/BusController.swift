import Vapor
import Fluent

struct BusController: RouteCollection {
	
	func boot(routes: RoutesBuilder) throws {
		let buses = routes.grouped("buses")
		buses.get(use: self.index)
		buses.post(use: self.create)
		buses.group(":busID") { (bus) in
			bus.delete(use: self.delete)
		}
	}
	
	func index(req request: Request) throws -> EventLoopFuture<[Bus]> {
		return Bus.query(on: request.db).all()
	}
	
	func create(req request: Request) throws -> EventLoopFuture<Bus> {
		let todo = try request.content.decode(Bus.self)
		return todo.save(on: request.db).map { (_) in
			return todo
		}
	}
	
	func delete(req request: Request) throws -> EventLoopFuture<HTTPStatus> {
		return Bus
			.find(request.parameters.get("busID"), on: request.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { (todo) in
				todo.delete(on: request.db)
			}
			.transform(to: .ok)
	}
	
}
