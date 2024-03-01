//
//  CustomScrollView.swift
//  Shuttle Tracker
//
//  Created by Yi Chen on 12/8/23.
//

import SwiftUI

struct CustomScrollView<Content: View> : View{

    let content: Content
    
    @State
    var h_content : Double = .zero
    
    @Environment(\.colorScheme)
    var colorScheme
    
    private var fade_color: Color{
        get{
            if(colorScheme == .dark){
                return .black
            }
            else{
                return .white
            }
        }
    }
    
  
    var body: some View{
        
        GeometryReader{proxy in
            ZStack{
                ScrollView{
                    self.content
                        .background(
                            GeometryReader{geo in
                                Color.clear
                                    .onAppear {
                                        h_content = geo.size.height
                                    }
                            }
                        )
                }
                if(h_content >= proxy.frame(in: .local).size.height){
                    Rectangle()
                        .fill(LinearGradient(colors:
                                                [fade_color, fade_color.opacity(0.1)],
                                             startPoint: .top,
                                             endPoint: .bottom)
                        ).frame(height: proxy.frame(in:.global).size.height/3)
                        .position(CGPoint(x: proxy.frame(in: .global).size.width/2,
                                          y:  0 + (proxy.frame(in: .global).size.height/100)))
                    
                    Rectangle()
                        .fill(LinearGradient(colors:
                                                [fade_color.opacity(0.1),fade_color],
                                             startPoint: .top,
                                             endPoint: .bottom)
                        ).frame(height: proxy.frame(in:.global).size.height/3)
                        .position(CGPoint(x: proxy.frame(in: .global).size.width/2,
                                          y:  proxy.frame(in: .global).size.height - (proxy.frame(in: .global).size.height/15)))
                }

            }

        }
    }
         
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}



struct CustomScrollViewPreviews: PreviewProvider{
    
    static var previews: some View{
        CustomScrollView() {}
    }
}

