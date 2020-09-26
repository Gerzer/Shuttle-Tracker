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
	app.databases.use(.sqlite(), as: .sqlite)
	app.migrations.add(CreateBuses())
	app.migrations.add(JobModelMigrate())
	app.queues.use(.fluent(useSoftDeletes: false))
	app.queues.schedule(BusDownloadingJob())
		.minutely()
		.at(0)
	app.queues.schedule(LocationRemovalJob())
		.everySecond()
	try app.autoMigrate()
		.wait()
	try app.queues.startInProcessJobs()
	try app.queues.startScheduledJobs()
	if let domain = ProcessInfo.processInfo.environment["domain"] {
		try app.http.server.configuration.tlsConfiguration = .forServer(
			certificateChain: [
				.certificate(
					.init(
						file: "/etc/letsencrypt/live/\(domain)/fullchain.pem",
						format: .pem
					)
				)
			],
			privateKey: .file(
				"/etc/letsencrypt/live/\(domain)/privkey.pem"
			)
		)
	}
	try routes(app)
}
