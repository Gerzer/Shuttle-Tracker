//
//  OnboardingFirstView.swift
//  macOS
//
//  Created by Tommy Truong on 3/28/23.
//

import SwiftUI

struct OnboardingFirstView: View {
    
    @State
    private var tabViewSelection = 0
    
    var body: some View {
        TabView(selection: $tabViewSelection) {
            VStack {
                Image(uiImage: UIImage(named: "AppIcon")!)
                    .resizable()
                    .frame(width: 120,height:120)
                    .cornerRadius(8)
//                    .padding(.bottom,60)
                                                
                VStack(spacing: 10) {
                    Text("Shuttle Network")
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    Text("Join the Shuttle Tracker Network to help improve tracking accuracy and never tap the Board Bus button again!")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        withAnimation {
                            tabViewSelection = 1
                        }
                    } label: {
                        Text("Get started")
                            .bold()
                    }
                    .buttonStyle(.block)
                    .frame(width: 200)
                    .padding(.bottom)
                }
                .background(.gray.opacity(0.15))
                .cornerRadius(12)
                .padding()
                                
                NavigationLink {
                    AnalyticsOnboardingView()
                } label: {
                    Text("Skip to Analytics")
                }
                
            }
            .tag(0)
            

            VStack {
                Text("HELLO WORLD")
                Button("go back"){
                    withAnimation {
                        tabViewSelection = 0
                    }
                }
            }
            .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingFirstView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFirstView()
    }
}
