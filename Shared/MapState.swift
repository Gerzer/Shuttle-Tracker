//
//  MapState.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import Combine

class MapState: ObservableObject {
	
	@Published var buses = Set<Bus>()
	@Published var stops = Set<Stop>()
	@Published var routes = [Route]()
	
}
