//
//  RouteProgress.swift
//  Shuttle Tracker
//
//  Created by Tommy Truong on 12/7/22.
//

import Foundation



struct routeProgress: Codable {
    var totalMetersAlongRoute: Double
    var metersAlongRoute: Double
    var routeID: String
 
}



class RouteProgressViewModel : ObservableObject {
    @Published var progress = [routeProgress]()
    
    
    func fetch() {
        // NEED TO ADD URL ENDPOINT HERE
        guard let url = URL(string: "https://shuttletracker.app/") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data,_,error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let progress = try JSONDecoder().decode([routeProgress].self, from: data)
                DispatchQueue.main.async {
                    self?.progress = progress
                }
            }catch {
                print(error)
            }

        }
        task.resume()
    }
}
