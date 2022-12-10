//
//  RouteProgressView.swift
//  Shuttle Tracker
//
//  Created by Tommy Truong on 12/7/22.
//

import SwiftUI




struct RouteProgressView: View {
    
    @EnvironmentObject private var boardBusManager: BoardBusManager

    @State var routeProgress : routeProgress
    
    @State var currentBusID: Int?
    var body: some View {
        VStack {
            List {
                Text(routeProgress.routeID)
                
            }
            
        }
    }
    
}

private func boardBus() async {
    precondition(LocationUtilities.locationManager.accuracyAuthorization == .fullAccuracy)
    Logging.withLogger(for: .boardBus) { (logger) in
        logger.log(level: .info, "[\(#fileID):\(#line) \(#function, privacy: .public)] Activating Board Bus manually…")
    }
    guard let busID = self.selectedBusID?.rawValue else {
        Logging.withLogger(for: .boardBus, doUpload: true) { (logger) in
            logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] No selected bus ID while trying to activate manual Board Bus")
        }
        return
    }
    await self.boardBusManager.boardBus(id: busID)
}

struct RouteProgressView_Previews: PreviewProvider {
    static var previews: some View {
        RouteProgressView(routeProgress: routeProgress(totalMetersAlongRoute: 0.0, metersAlongRoute: 0.0, routeID: "Testing"))
    }
}
