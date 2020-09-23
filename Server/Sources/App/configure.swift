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
	try? app.http.server.configuration.tlsConfiguration = .forServer(
		certificateChain: [
			.certificate(
				.init(
					file: "/etc/letsencrypt/live/shuttle.gerzer.software/fullchain.pem",
					format: .pem
				)
			)
		],
		privateKey: .file(
			"/etc/letsencrypt/live/shuttle.gerzer.software/privkey.pem"
		)
	)
	try routes(app)
}
