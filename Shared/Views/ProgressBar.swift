//
//  ProgressBar.swift
//  macOS
//
//  Created by Truong Tommy on 3/22/22.
//

import SwiftUI

struct ProgressBar: View {
    @State var dailyUsers = 56
    @State private var maximumDailyUser = 64
    @State var newRecordfordailyUser = false
    @State var counter:Int = 0

    @State private var newRecordforBus = false
    
    @State var PersonProgressValue:Float = 0.3
    @State var BusProgressValue:Float = 0.2
    
    var body: some View {
        VStack{
        horizontalProgressBar(value: $PersonProgressValue,filled: $newRecordfordailyUser)
            .frame(height:20)
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar()
    }
}

struct horizontalProgressBar : View {
    @Binding var value : Float
    @Binding var filled : Bool
    var body: some View{
        GeometryReader{geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 25)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                

                if (filled == false){
                Rectangle()
                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width),
                           height: 25)
                    .foregroundColor(.blue)
            }
                else {
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(1)
                        .foregroundColor(.green)
                }
            }
            .cornerRadius(7)
 
        }
        
    }
}
