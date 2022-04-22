//
//  MilestoneToastView.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//

import SwiftUI

@available(iOS 15.0, *)
struct MilestoneToastView: View {
    
    @StateObject var viewModel = MilestonesViewModel()
    @EnvironmentObject private var viewState: ViewState
    
    var body: some View {
        
        ScrollView {
            HStack{
            Text("Milestones")
                    .bold()
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            BoardBusMilestone()
        }
            .onAppear {
                viewModel.fetch()
            }
    }
}

struct MilestoneToastView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MilestoneToastView()
                .environmentObject(ViewState.shared)
        } else {
            // Fallback on earlier versions
        }

    }
}




