//
//  MilestoneToast.swift
//  Shuttle Tracker
//
//  Created by Truong Tommy on 3/20/22.
//

import SwiftUI

struct MilestoneToast<Content>: View where  Content: View {
    
    private var dismissalHandler: () -> Void
    private var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            self.content
        }
            .layoutPriority(0)
            .padding()
            .background(ViewUtilities.standardVisualEffectView)
            .cornerRadius(10)
    }
    
    init(dismissalHandler: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.dismissalHandler = dismissalHandler
        self.content = content()
    }
    
}
