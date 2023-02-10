//
//  CustomScrollView.swift
//  Shuttle Tracker
//
//  Created by Aidan Flaherty on 2/10/23.
//  Does not work as intended.
//

import SwiftUI

struct CustomScrollView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    @State var topOpacity: CGFloat = 0
    
    @State var bottomOpacity: CGFloat = 0
    
    var body: some View {
        ScrollView {
            ZStack {
                GeometryReader { reader in
                    let minY = reader.frame(in: .named("customScroll")).minY
                    let maxY = reader.frame(in: .named("customScroll")).maxY
                    Color.clear
                        .onChange(of: minY) { y in
                            topOpacity = max(0, min(1, 1 + 10 * y/reader.size.height))
                        }
                        .onChange(of: maxY) { y in
                            bottomOpacity = max(0, min(1, 9 - 10 * y/reader.size.height))
                        }
                    
                }
                VStack(content: content)
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }.coordinateSpace(name: "customScroll")
            .mask(LinearGradient(stops: [Gradient.Stop(color: .white.opacity(topOpacity), location: 0), Gradient.Stop(color: .white.opacity(1), location: 0.1), Gradient.Stop(color: .white.opacity(1), location: 0.9), Gradient.Stop(color: .white.opacity(bottomOpacity), location: 1)], startPoint: .top, endPoint: .bottom))
    }
}

struct CustomScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CustomScrollView() {}
    }
}
