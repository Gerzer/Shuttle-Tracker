//
//  BoardBusAttributes.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/17/22.
//

import ActivityKit
import CoreLocation

@available(iOS 16.1, *)
struct BoardBusAttributes: ActivityAttributes {
	
	static var activity: Activity<Self>?
	
	struct ContentState: Codable, Hashable {
		
		let travelState: TravelState
		
		// TODO: Remove because maps aren’t supported in widgets
		let coordinate: Coordinate?
		
		static func == (lhs: Self, rhs: Self) -> Bool {
			return lhs.travelState == rhs.travelState && lhs.coordinate == rhs.coordinate
		}
		
	}
	
	// TODO: Remove because maps aren’t supported in widgets
	let stops: [Stop]
	
	// TODO: Remove because maps aren’t supported in widgets
	let routes: [Route]
	
}
