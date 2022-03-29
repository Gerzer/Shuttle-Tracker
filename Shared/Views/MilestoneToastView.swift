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
        
        ScrollView {
            
            VStack{
                HStack{
                Text("Milestones")
                        .bold()
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                }

            MilestoneToast(){
                withAnimation {
                    self.viewState.toastType = nil
                }
            }  content : {
                HStack {
                    Image(systemName: "skew")
                        .resizable()
                        .frame(width: 26, height: 24)
                    Text("Stages")
                        .font(.system(size: 32, weight: .medium, design: .default))
                }
                .rainbow()
                HStack{
                    Text("Help ShuttleTracker reach the next checkpoint!")
                        .font(.system(size: 18, weight: .bold, design: .default))
                }
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
                
            MilestoneToast() {
                    withAnimation {
                        self.viewState.toastType = nil
                    }
            } content : {
                HStack{
                Image(systemName: "bus")
                        .foregroundColor(.red)
                    
                Text("Why Shuttle Tracker")
                        .bold()
                        .font(.title)
                        .foregroundColor(.red)
                    }
                Divider()
                Text("Because")
                
            }
            .padding()
                
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




