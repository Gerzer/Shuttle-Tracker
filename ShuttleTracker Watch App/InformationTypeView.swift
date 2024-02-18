//
//  InformationTypeView.swift
//  ShuttleTracker Watch App
//
//  Created by Tommy Truong on 2/16/24.
//

import SwiftUI

struct InformationTypeView: View {
    var SFSymbol : SFSymbol
    var iconColor : Color
    var name : String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: SFSymbol.systemName)
                .symbolVariant(.circle.fill)
                .foregroundStyle(self.iconColor)
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
    InformationTypeView(SFSymbol: .info, iconColor: .green, name: "Information")
}
