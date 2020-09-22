//
//  configure.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import Vapor
import FluentSQLiteDriver
import Queues
import QueuesFluentDriver

public func configure(_ app: Application) throws {
//	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	app.databases.use(.sqlite(), as: .sqlite)
	app.migrations.add(CreateBuses())
	app.migrations.add(JobModelMigrate())
	app.queues.use(.fluent(useSoftDeletes: false))
	app.queues.schedule(BusJob())
		.minutely()
		.at(0)
	try app.autoMigrate()
		.wait()
	try app.queues.startInProcessJobs()
	try app.queues.startScheduledJobs()
	try routes(app)
}
