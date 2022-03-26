//
//  MilestoneToastView.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//

import SwiftUI

struct MilestoneToastView: View {
    @EnvironmentObject private var viewState: ViewState
    
    @State private var numberOfBoard:Int = 95
    @State private var levels = [100,200,300,400,500]
        
    var body: some View {
        VStack{
            
            HStack{
            Text("Milestones")
                    .bold()
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }

        MilestoneToast("Stages ","Help ShuttleTracker reach the next checkpoint!"){
            withAnimation {
                self.viewState.toastType = nil
            }
        }  content : {
            Divider()
           
            HStack(alignment: .lastTextBaseline){
                Text("\(numberOfBoard)")
                    .bold()
                    .font(.largeTitle)
                Text("out of \(levels[currentLevel]) rides")
            }
            Spacer()
                .frame(height: 5)
            ProgressBar(progressValue: self.progress.progCurrentLevel)
            
            HStack(alignment: .lastTextBaseline){
                Text("\(currentLevel)")
                    .font(.largeTitle)
                    .bold()
                Text("out of \(levels.count) stages")
            }
            Spacer()
                .frame(height: 5)
            ProgressBar(progressValue: self.progress.progressStage)
        }
        .padding()
            
            
            
            
            Button("TAP BOARD BUS"){
                self.numberOfBoard += 1
            }
        }
    }
    

    
    var currentLevel:Int {
            var a :Int = 0
            for i in 0..<self.levels.count {
                if (self.numberOfBoard >= levels[i]) {
                    a+=1
                }
            }
        return a
        }
    
    
    var progress: (progCurrentLevel: Double, progressStage: Double) {
            let res1 = Double(self.numberOfBoard)/Double(levels[currentLevel]) //progress in the current stage
            let res2 = Double(currentLevel)/Double(self.levels.count) // progress in total of all the stages.
            return (res1,res2)
    
    }
}

struct MilestoneToastView_Previews: PreviewProvider {
    static var previews: some View {
        MilestoneToastView()
            .environmentObject(ViewState.shared)

    }
}




