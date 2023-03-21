//
//  Milestone.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 4/1/22.
//
import Foundation

struct Milestone:Codable,Hashable {
    var id:UUID
    var name:String
    var extendedDescription : String
    var progress:Int
    var progressType:String
    var goals:[Int]
    var signature:Data
    
    func goalAt(level: Int) -> Int {
        return goals[min(currentLevel(), goals.count - 1)]
    }
    
    func currentLevel() -> Int {
        var level = 0
        
        for i in 0..<goals.count {
            if (progress >= goals[i]) {
                level = i + 1
            }
        }
        
        return level
    }

    func progressBarValue()-> (progLvl:Double, progStage:Double) {
        let curLvl = currentLevel()
        
        let res1 = min(1, Double(progress)/Double(goalAt(level: curLvl)))
        let res2 = min(1, Double(curLvl)/Double(goals.count))
        
        return (res1, res2)
    }
}

extension Array where Element == Milestone {
    
    static func download() async -> [Milestone] {
        do {
            return try await API.readMilestones.perform(as: [Milestone].self)
        } catch let error {
            Logging.withLogger(for: .api) { (logger) in
                logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Failed to download milestones: \(error, privacy: .public)")
            }
            return []
        }
    }
    
}
