//
//  InformationTypeView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/16/24.
//

import SwiftUI

struct InformationTypeView: View {
    var SFSymbol : SFSymbol
    let primaryColor: Color
    let secondaryColor: Color
    var name : String
    var body: some View {
        HStack(alignment:.center, spacing: 8) {
            Image(systemName: SFSymbol.systemName)
                .resizable()
                .clipShape(Circle())
                .scaledToFit()
                .frame(height: 18)
                .foregroundStyle(primaryColor, secondaryColor)
                .font(.title3)
            Text(self.name)
                .fontWeight(.semibold)
                .lineLimit(1)
            Spacer()
        }
        .padding(10)
        .background(.gray.opacity(0.2), in: .buttonBorder)
        .foregroundStyle(.white)
    }
}

#Preview {
    InformationTypeView(SFSymbol: .shuttleTrackerPlus,
                        primaryColor: .white,
                        secondaryColor: .clear,
                        name: "Shuttle Tracker Plus")
    .rainbow()
}
