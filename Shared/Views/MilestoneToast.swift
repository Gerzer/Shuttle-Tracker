//
//  MilestoneToast.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//

import SwiftUI

struct MilestoneToast<StringType, Content>: View where StringType: StringProtocol, Content: View {
    
    private var headlineString: StringType
    private var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(self.headlineString)
                    .font(.headline)
            }
            self.content
        }
            .layoutPriority(0)
            .padding()
            .background(ViewUtilities.standardVisualEffectView)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
    
    init(_ headlineString: StringType, @ViewBuilder content: () -> Content) {
        self.headlineString = headlineString
        self.content = content()
    }
    
}
