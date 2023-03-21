//
//  MilestoneState.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 3/21/23.
//

import Foundation

actor MilestoneState: ObservableObject {
    
    static let shared = MilestoneState()
    
    private(set) var milestones = [Milestone]()
    
    private init() { }
    
    func refresh() async {
        self.milestones = await [Milestone].download()
        
        /*self.milestones.append(Milestone(id: UUID(), name: "Test", extendedDescription: "This is a milestone", progress: 892, progressType: "mcguffin points", goals: [10, 50, 100, 500, 1000], signature: Data()))
        
        self.milestones.append(Milestone(id: UUID(), name: "Students injured", extendedDescription: "This is a running count of the number of students hit by shuttles.", progress: 150, progressType: "students hit", goals: [10, 50, 100, 500, 1000], signature: Data()))
        */
        await MainActor.run {
            self.objectWillChange.send()
        }
    }
}
