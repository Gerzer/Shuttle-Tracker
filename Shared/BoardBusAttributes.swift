//
//  BoardBusAttributes.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/17/22.
//

import ActivityKit
import CoreLocation


// Every stop [routesID]
// Routes = [coord,coord,coord]
// Distance travel pro - num of meter from 1 []
@available(iOS 16.1, *)

struct BoardBusAttributes: ActivityAttributes {
    public typealias BusTravelStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var busID: String
        var estimated: ClosedRange<Date>
    }

    var numberOfPizzas: Int
    var totalAmount: String
}
