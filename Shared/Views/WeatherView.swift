//
//  WeatherView.swift
//  Shuttle Tracker
//
//  Created by Tommy Truong on 4/15/23.
//

import SwiftUI
import CoreLocation
import Charts

@available(iOS 16.0, *)
struct InformationSheet: View {
    
    @StateObject var weatherViewModel = WeatherViewModel()
    
    var body: some View {
        VStack {
            Text("Current location")
                .bold()
                .font(.largeTitle)
            if let data = weatherViewModel.data {

                Text(data.currentWeather.date.description)
                Text(data.currentWeather.temperature.formatted())
                Text(data.minuteForecast?.summary ?? "")
                ForEach(data.hourlyForecast,id:\.date){ hourlyForcast in
                    
                    HStack {
                        Text(hourlyForcast.date.ISO8601Format())
                        Text(hourlyForcast.temperature.description)
                    }
                }
                Text(data.dailyForecast.forecast.description)

//                Chart(data)
            }
            else {
                Text("There is currently no available information about this location")
            }

        }
        .onAppear {
            weatherViewModel.getWeather(for: CLLocation(latitude: currentSuggestedLocation.coordinate.latitude, longitude: currentSuggestedLocation.coordinate.longitude))
        }
    }
}

struct InformationSheet_Previews: PreviewProvider {
    static var previews: some View {
        InformationSheet(currentSuggestedLocation: SuggestedLocation.sampleLocations[0])
    }
}
