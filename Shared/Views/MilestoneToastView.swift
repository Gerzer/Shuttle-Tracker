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
    
    
    @State private var numberOfBoard:Int = 95
    @State private var levels = [100,200,300,400,500]
    
    @State var milestones = [Milestone]()
        
    var body: some View {
        
        ScrollView {
            
            HStack{
            Text("Milestones")
                    .bold()
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
        VStack{
                ForEach(viewModel.milestones,id: \.self) { milestone in
                    
                    var r = Double.random(in: 0...1)
                    var g = Double.random(in: 0...0.8)
                    var b = Double.random(in: 0...1)
                    
                
                    MilestoneToast(){
                        withAnimation {
                            self.viewState.toastType = nil
                        }
                    }  content : {
                        HStack {
                            Image(systemName: "bus.doubledecker")
                                .resizable()
                                .frame(width: 26, height: 24)
                            Text(milestone.name)
                                .font(.system(size: 32, weight: .medium, design: .default))
                        }
                        .rainbow()
                        
                        
                        HStack{
                            Text(milestone.extendedDescription)
                                .font(.system(size: 18, weight: .bold, design: .default))
                        }
                        Divider()
                        Spacer()
                            .frame(height: 5)
                        
                        HStack(alignment: .lastTextBaseline){
                            Text("\(milestone.progress)")
                                .bold()
                                .font(.largeTitle)
                            Text("out of \(milestone.goals[currentLevel(p:milestone.progress,g:milestone.goals)]) rides")
                        }
                        Spacer()
                            .frame(height: 5)
                        ProgressBar(progressValue: progressBarValue(p: milestone.progress, g: milestone.goals).progLvl)
                        
                        HStack(alignment: .lastTextBaseline){
                            Text("\(currentLevel(p:milestone.progress,g:milestone.goals))")
                                .font(.largeTitle)
                                .bold()
                            Text("out of \(milestone.goals.count) stages")
                        }
                        Spacer()
                            .frame(height: 5)
                        ProgressBar(progressValue: progressBarValue(p: milestone.progress, g: milestone.goals).progStage)
                        
                    }
                    .padding()
                }
        }
        }
            .onAppear {
                viewModel.fetch()
            }
    }
        
        /*
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
                    Text(self.milestones[0].extendedDescription)
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
            .task {
                await loadData()
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
        */
    func currentLevel(p current_goal:Int,g array:[Int])->Int {
        var a :Int = 0
        for i in 0..<array.count {
                if (current_goal >= array[i]) {
                    a+=1
                }
            }
        return a
        }
    
    /*
    var progress: (progCurrentLevel: Double, progressStage: Double) {
            let res1 = Double(self.numberOfBoard)/Double(levels[currentLevel]) //progress in the current stage
            let res2 = Double(currentLevel)/Double(self.levels.count) // progress in total of all the stages.
            return (res1,res2)
    }
     */
    
    func progressBarValue(p current_goal:Int,g array:[Int])-> (progLvl:Double,progStage:Double) {
        let curLvl = currentLevel(p: current_goal, g: array)
        let res1 = Double(current_goal)/Double(array[curLvl]) //progress in the current stage
        let res2 = Double(curLvl)/Double(array.count) // progress in total of all the stages.
        return (res1,res2)
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




