//
//  MilestoneToastView.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//

import SwiftUI

struct MilestoneToastView: View {
    @EnvironmentObject private var viewState: ViewState

    var body: some View {
        MilestoneToast("Daily Stats"){
            withAnimation {
                self.viewState.toastType = nil
            }
        }  content : {
            Text("SHEESH")
        }
    }
}

struct MilestoneToastView_Previews: PreviewProvider {
    static var previews: some View {
        MilestoneToastView()
            .environmentObject(ViewState.shared)

    }
}
