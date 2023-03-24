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
        
        await MainActor.run {
            self.objectWillChange.send()
        }
    }
}
