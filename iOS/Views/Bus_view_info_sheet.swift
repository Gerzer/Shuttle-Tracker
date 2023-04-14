//
//  Bus_view_info_sheet.swift
//  iOS
//
//  Created by John Foster on 4/14/23.
//

import SwiftUI


struct Bus_view_info_sheet: View {
    
    var body: some View {
        NavigationView {
             Bus_info_view()
                .navigationTitle("Bus Info")
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
        }
    }
    
}
