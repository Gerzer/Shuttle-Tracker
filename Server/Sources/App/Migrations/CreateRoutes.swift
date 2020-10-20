//
//  File.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 10/20/20.
//

import Fluent

struct CreateRoutes: Migration {
	
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		return database.schema("routes")
			.id()
			.field("coordinates", .array(of: .custom(Coordinate.self)), .required)
			.field("stopIDs", .array(of: .int), .required)
			.create()
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		return database.schema("routes")
			.delete()
	}
	
}
