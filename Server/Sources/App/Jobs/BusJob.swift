//
//  BusJob.swift
//  
//
//  Created by Gabriel Jacoby-Cooper on 9/22/20.
//

import Foundation
import Queues

struct BusJob: ScheduledJob {
	
	func run(context: QueueContext) -> EventLoopFuture<Void> {
		Set<Bus>.download(application: context.application) { (buses) in
			var newBuses = buses
			let _ = Bus.query(on: context.application.db)
				.all()
				.mapEachCompact { (existingBus) in
					if let newBus = newBuses.remove(existingBus) {
						existingBus.locations.merge(with: newBus.locations)
						let _ = existingBus.update(on: context.application.db)
					}
				}
				.map { (_) in
					newBuses.forEach { (newBus) in
						let _ = newBus.save(on: context.application.db)
					}
				}
		}
		let _ = Bus.query(on: context.application.db)
			.all()
			.mapEach { (bus) in
				let oldLocations = bus.locations.filter { (location) in
					return location.date.timeIntervalSinceNow < -300
				}
				let oldLocationsIndicies = oldLocations.compactMap { (location) in
					return bus.locations.firstIndex(of: location)
				}
				oldLocationsIndicies.forEach { (index) in
					bus.locations.remove(at: index)
				}
				let _ = bus.update(on: context.application.db)
			}
		return context.eventLoop.future()
	}
	
}
