//
//  LocationRemovalJob.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/22/20.
//

import Queues

struct LocationRemovalJob: ScheduledJob {
	
	func run(context: QueueContext) -> EventLoopFuture<Void> {
		_ = Bus.query(on: context.application.db)
			.all()
			.mapEach { (bus) in
				let oldLocations = bus.locations.filter { (location) in
					return location.type == .user && location.date.timeIntervalSinceNow < -30
				}
				let oldLocationsIndicies = oldLocations.compactMap { (location) in
					return bus.locations.firstIndex(of: location)
				}
				oldLocationsIndicies.forEach { (index) in
					bus.locations.remove(at: index)
				}
				 _ = bus.update(on: context.application.db)
			}
		return context.eventLoop.future()
	}
	
}
