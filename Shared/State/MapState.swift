//
//  MapState.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import Foundation
import Combine

class MapState: ObservableObject {
	
	static let shared = MapState()
	
	@Published var buses = [Bus]()
	
	@Published var stops = [Stop]()
	
	@Published var routes = [Route]()
	
	@Published var travelState = TravelState.notOnBus
	
	@Published var busID: Int?
	
	@Published var locationID: UUID?
	
	private init() { }
	
}
