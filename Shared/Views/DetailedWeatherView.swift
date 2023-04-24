//
//  DetailedWeatherView.swift
//  Explorer
//
//  Created by Tommy Truong on 4/19/23.
//

import SwiftUI
import Charts

struct DetailedWeatherView: View {
    var data: DetailedForecast
    
    @State var currentChartType: ForecastChartType
    
    //CHART 1
    @State var temps = [Double]()
    //CHART 2
    
    var body: some View {
        VStack {
            List {
                Section {
                    DetailedRowInformation(title: "City name", information: "\(data.city.name)")
                    DetailedRowInformation(title: "Country Code", information: "\(data.city.country)")
                    DetailedRowInformation(title: "Population", information: "\(data.city.population)")
                    DetailedRowInformation(title: "Sunrise time ", information: "\(NSDate(timeIntervalSince1970: data.city.sunrise) )")
                    DetailedRowInformation(title: "Sunset time", information: "\(NSDate(timeIntervalSince1970: data.city.sunset) )")
                    DetailedRowInformation(title: "Timezone", information: " \((data.city.timezone/3600)>0 ? "+":"" ) \(data.city.timezone/3600) GMT")
                } header: {
                    Text("General")
                }
                
                Section {
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(data.list,id:\.dt) { element in
                                RowView(data: element)
                                    .frame(width: 100)
                            }
                        }
                    }
                } header: {
                    Text("The weather for the next 5 days")
                }
                
                Section {
                    
                    Picker("Pick for", selection: self.$currentChartType.animation(.easeInOut)) {
                        ForEach(ForecastChartType.allCases, id: \.self) { value in
                                Text(value.localizedName)
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    
                    switch currentChartType {
                    case .WindSpeed:
                        Chart(data.list,id:\.dt) { element in
                            LineMark(x: .value("Day", element.dt_txt),
                                     y: .value("Temperature", element.wind.speed))
                            .foregroundStyle(.blue)
                        }
                        .chartYAxisLabel("Temperature")
                        .chartYAxis {
                            AxisMarks(position: .leading, values: .automatic) { value in
                                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                                    AxisValueLabel() {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue) m/s")
                                            .font(.system(size: 10))
                                        }
                                    }
                                }
                        }
                        
                    case .Pressure:
                            Chart(data.list,id:\.dt) { element in
                                LineMark(x: .value("Day", element.dt_txt),
                                         y: .value("Pressure", element.main.pressure/1000))
                                .foregroundStyle(.red)
                            }
                            .chartYAxisLabel("Pressure")
                            .chartYScale(domain: [1.00,1.03])
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic) { value in
                                        AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                                        AxisValueLabel() {
                                            if let intValue = value.as(Double.self) {
                                                Text("\(intValue,specifier: "%.2f") Pa")
                                                .font(.system(size: 10))
                                            }
                                        }
                                    }
                            }
                    case .Humidity:
                                Chart(data.list,id:\.dt) { element in
                                    LineMark(x: .value("Day", element.dt_txt),
                                             y: .value("Humidity", element.main.humidity))
                                    .foregroundStyle(.cyan)
                                }
                                .chartYAxisLabel("Humidity")
                                .chartYAxis {
                                    AxisMarks(position: .leading, values: .automatic) { value in
                                            AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                                            AxisValueLabel() {
                                                if let intValue = value.as(Int.self) {
                                                    Text("\(intValue) %")
                                                    .font(.system(size: 10))
                                                }
                                            }
                                        }
                                }
                    }

                } header: {
                    Text("Charts")
                }
            }
            .navigationTitle("Additional Informations")
        }
    }
}

//struct DetailedWeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailedWeatherView(data: .init(cod: "cod", message: 2, cnt: 40, list: [.init(dt: 100, main: .init(temp: 10, feels_like: 30, temp_min: 28, temp_max: 38, pressure: 30.0, humidity: 30.0, temp_kf: 30.0), weather: [.init(id: 999, main: "main", description: "description", icon: "icon")], clouds: .init(all: 10), wind: .init(speed: 100, deg: 200), visibility: 1, pop: 10, rain: .none, sys: .init(pod: "pod"), dt_txt: "text")], city: .init(id: 10, name: "name", coord: .init(lon: 50, lat: 60), country: "Country", population: 100000, timezone: 10, sunrise: 2, sunset: 3)))
//    }
//}
struct RowView: View {
    var data: ForecastBody
    let dateFormatter = DateFormatter()
    @State var day = ""
    @State var hour = ""
    
    var body: some View {
        VStack(alignment: .center) {
//            Text("\(NSDate(timeIntervalSince1970: Double(data.dt) ))")
//                .fontWeight(.bold)
            Text(day)
            Text(hour)
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(data.weather[0].icon)@2x.png"), content: { image in
                image
                    .frame(height: 40)
                }, placeholder: {
                    ProgressView()
                })
            Text("High: \(data.main.temp_max.roundDouble())°F")
            Text("Low: \(data.main.temp_min.roundDouble())°F")
            Text(data.weather[0].description)
                .font(.caption)
        }
        .onAppear {
            dateFormatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
            let result = dateFormatter.date(from: data.dt_txt)
            if let result {
                let components = Calendar.current.dateComponents([.day, .hour,.month], from: result)
                day = "\(components.day!)"
                hour = result.formatted(date: .omitted, time: .shortened)
            }
        }
    }
}
