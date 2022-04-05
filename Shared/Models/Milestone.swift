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
}

class MilestonesViewModel : ObservableObject {
    @Published var milestones = [Milestone]()
    
    func fetch() {
        guard let url = URL(string: "https://shuttletracker.app/milestones") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data,_,error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let milestones = try JSONDecoder().decode([Milestone].self, from: data)
                DispatchQueue.main.async {
                    self?.milestones = milestones
                }
            }catch {
                print(error)
            }

        }
        task.resume()
    }
}





