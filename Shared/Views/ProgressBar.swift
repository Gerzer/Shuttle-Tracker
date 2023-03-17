//
//  ProgressBar.swift
//  macOS
//
//  Created by Truong Tommy on 3/22/22.
//
import SwiftUI

struct ProgressBar: View {

    @State var newRecordfordailyUser = false
    @State private var newRecordforBus = false
    let ProgressValue:Double

    var body: some View {
        VStack{
        horizontalProgressBar(value: ProgressValue,filled: $newRecordfordailyUser)
            .frame(height:20)
        }
    }

    init(progressValue: Double) {
            self.ProgressValue = progressValue
        }

}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
        ProgressBar(progressValue: 0.1)
        }
        .padding()
    }
}

struct horizontalProgressBar : View {
    let value : Double
    @Binding var filled : Bool
    var body: some View{
        GeometryReader{geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 25)
                    .opacity(0.2)
                    .foregroundColor(.blue)


                if (filled == false){
                Rectangle()
                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width),
                           height: 25)
                    .foregroundColor(.blue)
                    .cornerRadius(7)
            }
                else {
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(1)
                        .foregroundColor(.green)
                        .cornerRadius(7)
                }
            }
            .cornerRadius(6)

        }

    }

}
