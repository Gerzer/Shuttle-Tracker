//
//  Milestone.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 4/1/22.
//

import Foundation

struct Milestone:Codable {
    var id:UUID
    var name:String
    var extendedDescription : String
    var progress:Int
    var progressType:String
    var goals:[Int]
    var signature:Data
    
}





