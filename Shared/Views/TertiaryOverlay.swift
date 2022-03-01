//
//  TertiaryOverlay.swift
//  Shuttle Tracker
//
//  Created by Scott Wofford on 2/18/22.
//

import SwiftUI

// 'TertiaryOverlay' contains the 'RecenterButton' and is located below 'SecondaryOverlay'
struct TertiaryOverlay: View {
    
    @State private var announcementsCount = 0
    
    var body: some View {
        VStack(spacing: 0) {
            RecenterButton()
        }
            .background(
                VisualEffectView(.systemThickMaterial)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            )
    }
    
}

struct TertiaryOverlayPreviews: PreviewProvider {
    
    static var previews: some View {
        TertiaryOverlay()
    }
    
}
