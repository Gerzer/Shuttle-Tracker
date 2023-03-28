//
//  ProgressBar.swift
//  macOS
//
//  Created by Truong Tommy on 3/22/22.
//
import SwiftUI

struct ProgressBar: View {
    let ProgressValue:Double

    var body: some View {
        VStack {
            horizontalProgressBar(value: ProgressValue)
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
    
    var body: some View{
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width)
                    .opacity(0.2)
                    .foregroundColor(.black)

                LinearGradient(colors: [Color(red: 0.5, green: 0, blue: 0), Color(red: 1, green: 0.1, blue: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width))
                    .foregroundColor(.red)
                    .cornerRadius(7)
            }
        }
        .cornerRadius(8)
    }

}
