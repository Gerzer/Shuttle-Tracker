//
//  BoardBusMilestone.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 4/19/22.
//
import SwiftUI

struct BoardBusMilestone: View {
    @StateObject var viewModel = MilestonesViewModel()
    @EnvironmentObject private var viewState: ViewState

    var body: some View {

        VStack{
                ForEach(viewModel.milestones,id: \.self) { milestone in

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
            .onAppear {
                viewModel.fetch()
            }
    }

    func currentLevel(p current_goal:Int,g array:[Int])->Int {
        var a :Int = 0
        for i in 0..<array.count {
                if (current_goal >= array[i]) {
                    a+=1
                }
            }
        return a
        }

    func progressBarValue(p current_goal:Int,g array:[Int])-> (progLvl:Double,progStage:Double) {
        let curLvl = currentLevel(p: current_goal, g: array)
        let res1 = Double(current_goal)/Double(array[curLvl]) //progress in the current stage
        let res2 = Double(curLvl)/Double(array.count) // progress in total of all the stages.
        return (res1,res2)
    }
}

struct BoardBusMilestone_Previews: PreviewProvider {
    static var previews: some View {
        BoardBusMilestone()
    }
}
