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
        
        MilestoneToast("Stages ","Help ShuttleTracker reach the next checkpoint!"){
            withAnimation {
                self.viewState.toastType = nil
            }
        }  content : {
            Divider()
           
            HStack(alignment: .lastTextBaseline){
                Text("275")
                    .bold()
                    .font(.largeTitle)
                Text("out of 600 rides")
            }
            Spacer()
                .frame(height: 5)
            ProgressBar()
            
            HStack(alignment: .lastTextBaseline){
                Text("3")
                    .font(.largeTitle)
                    .bold()
                Text("out of 5 stages")
            }
            Spacer()
                .frame(height: 5)
            ProgressBar()
        }
        .padding()
        
    }
}

struct MilestoneToastView_Previews: PreviewProvider {
    static var previews: some View {
        MilestoneToastView()
            .environmentObject(ViewState.shared)

    }
}
