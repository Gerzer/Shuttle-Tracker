//
//  RouteDownloadingJob.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 10/20/20.
//

import Queues

struct RouteDownloadingJob: ScheduledJob {
	
	func run(context: QueueContext) -> EventLoopFuture<Void> {
		[Route].download(application: context.application) { (routes) in
			Bus.query(on: context.application.db)
				.all()
				.mapEach { (route) in
					_ = route.delete(on: context.application.db)
				}
				.whenSuccess { (_) in
					routes.forEach { (route) in
						_ = route.save(on: context.application.db)
					}
				}
		}
		return context.eventLoop.future()
	}
	
}
