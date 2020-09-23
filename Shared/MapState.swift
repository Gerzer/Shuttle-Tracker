//
//  MapState.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/20/20.
//

import Combine

class MapState: ObservableObject {
	
	@Published var buses = [Bus]()
	@Published var stops = [Stop]()
	@Published var routes = [Route]()
	
}
