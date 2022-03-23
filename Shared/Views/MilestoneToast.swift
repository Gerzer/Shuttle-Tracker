//
//  MilestoneToast.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//

import SwiftUI

struct MilestoneToast<StringType, Content>: View where StringType: StringProtocol, Content: View {
    
    private var headlineString: StringType
    private var descriptionString : StringType
    private var dismissalHandler: () -> Void
    private var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 26, height: 24)
                Text(self.headlineString)
                    .font(.system(size: 32, weight: .medium, design: .default))
            }
            .rainbow()
            HStack{
                Text(self.descriptionString)
                    .font(.system(size: 18, weight: .bold, design: .default))
            }
            self.content
        }
            .layoutPriority(0)
            .padding()
            .background(ViewUtilities.standardVisualEffectView)
            .cornerRadius(10)
    }
    
    init(_ headlineString: StringType, _ descriptionString:StringType, dismissalHandler: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.headlineString = headlineString
        self.descriptionString = descriptionString
        self.dismissalHandler = dismissalHandler
        self.content = content()
    }
    
}
