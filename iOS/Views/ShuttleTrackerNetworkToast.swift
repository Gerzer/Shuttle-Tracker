//
//  ShuttleTrackerNetworkToast.swift
//  iOS
//
//  Created by John Foster on 12/1/22.
//
import Foundation

import SwiftUI

struct ShuttleTrackerNetworkToast: View {

    @EnvironmentObject private var viewState: ViewState

    var body: some View {
        Toast("We cant see you!") {
            withAnimation {
                self.viewState.toastType = nil
            }
        } content: {
            Text("Enable location services for optimal usage of the Shuttle Tracker Network.")
        }
    }

}

