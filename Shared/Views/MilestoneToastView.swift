//
//  MilestoneToastView.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//
import SwiftUI

@available(iOS 15.0, *)
struct MilestoneToastView: View {
    @EnvironmentObject private var viewState: ViewState

    @EnvironmentObject private var milestoneState: MilestoneState
    
    @State private var milestones = [Milestone]()
    
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
                ForEach(milestones, id: \.self) { milestone in
                    MilestoneToast(){
                        withAnimation {
                            self.viewState.toastType = nil
                        }
                    } content : {
                        VStack {
                            HStack {
                                Image(systemName: "bus.doubledecker")
                                    .resizable()
                                    .frame(width: 26, height: 24)
                                Text(milestone.name)
                                    .font(.system(size: 32, weight: .medium, design: .default))
                                    .frame(alignment: .center)
                            }
                            .rainbow()
                            
                            HStack{
                                Text(milestone.extendedDescription)
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .frame(alignment: .center)
                            }
                        }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.background)
                            .cornerRadius(10)

                        HStack(alignment: .lastTextBaseline){
                            Text("\(milestone.progress)")
                                .bold()
                                .font(.largeTitle)
                            Text("out of \(milestone.goalAt(level: milestone.currentLevel())) \(milestone.progressType)")
                        }
                        Spacer()
                            .frame(height: 5)
                        ProgressBar(progressValue: milestone.progressBarValue().progLvl)
                        
                        
                        HStack(alignment: .lastTextBaseline){
                            Text("\(milestone.currentLevel())")
                                .font(.largeTitle)
                                .bold()
                            Text("out of \(milestone.goals.count) stages")
                        }
                        
                        Spacer()
                            .frame(height: 5)
                        ProgressBar(progressValue: milestone.progressBarValue().progStage)
                            .padding(.bottom)
                    }
                    .padding()
                }
            }
        }
        .task {
            await MilestoneState.shared.refresh()
            milestones = await MilestoneState.shared.milestones
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
