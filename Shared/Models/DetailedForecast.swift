//
//  DetailedForecast.swift
//  Explorer
//
//  Created by Tommy Truong on 4/19/23.
//

import Foundation

struct DetailedForecast: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastBody]
    let city: City
}

struct ForecastBody: Codable{
    let dt: Int
    let main: MainDetailed // ok
    let weather: [Weather] // ok
    let clouds: Clouds // ok
    let wind: Wind // ok
    let visibility: Int
    let pop: Double
    let rain: Rain?
    let sys: System
    let dt_txt: String
    
    static func == (lhs: ForecastBody, rhs: ForecastBody) -> Bool {
        return lhs.dt == rhs.dt
    }
}

struct MainDetailed: Codable, Hashable {    
    let temp, feels_like, temp_min, temp_max: Double
    let pressure, humidity, temp_kf: Double
}

struct Rain: Codable {
    let the3H: Double
    enum CodingKeys: String, CodingKey {
            case the3H = "3h"
    }
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Double
    let sunset: Double
}

struct System: Codable {
    let pod: String
}
