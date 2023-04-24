//
//  ForecastChartType.swift
//  Explorer
//
//  Created by Tommy Truong on 4/19/23.
//

import Foundation
import SwiftUI

enum ForecastChartType: String, Equatable, CaseIterable {
    case WindSpeed
    case Pressure
    case Humidity
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


