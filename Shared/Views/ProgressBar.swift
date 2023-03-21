//
//  ProgressBar.swift
//  macOS
//
//  Created by Truong Tommy on 3/22/22.
//
import SwiftUI

struct ProgressBar: View {

    @State var newRecordfordailyUser = true
    @State private var newRecordforBus = false
    let ProgressValue:Double

    var body: some View {
        VStack{
            horizontalProgressBar(value: ProgressValue, record: $newRecordfordailyUser)
                .frame(height:30)
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
    @Binding var record : Bool
    
    var body: some View{
        GeometryReader{geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width)
                    .opacity(0.2)
                    .foregroundColor(.red)

                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width))
                    .foregroundColor(.red)
                    .cornerRadius(7)
                
                if(record) {
                    HStack {
                        Spacer().frame(width: self.value > 0.35 ? 10 : CGFloat(self.value) * geometry.size.width + 10)
                        Text("New record!")
                            .bold()
                        Spacer()
                    }
                }
            }
            .cornerRadius(6)

        }

    }

}
