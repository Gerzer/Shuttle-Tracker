//
//  RouteProgressView.swift
//  Shuttle Tracker
//
//  Created by Tommy Truong on 12/7/22.
//

import SwiftUI

struct RouteProgressView: View {
    @State var routeProgress : routeProgress
    var body: some View {
        VStack {
            List {
                Text(routeProgress.routeID)
            }
        }
    }
}

struct RouteProgressView_Previews: PreviewProvider {
    static var previews: some View {
        RouteProgressView(routeProgress: routeProgress(totalMetersAlongRoute: 0.0, metersAlongRoute: 0.0, routeID: "Testing"))
    }
}
