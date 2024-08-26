//
//  WeatherHistoryView.swift
//  WeatherApp
//
//  Created by Sagar ganji on 24.08.2024.
//

import SwiftUI

extension WeekWeatherInfo: Identifiable { }

struct WeatherHistoryView: View {
    
    @State var weatherWeekForecast: [WeekWeatherInfo]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(weatherWeekForecast) { forecast in
                    VStack {
                        Text("\(forecast.dt_txt)")
                            .padding()
                        Text(String(forecast.main.temp ?? 0.0))
                            .padding()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    
    WeatherHistoryView(weatherWeekForecast: SampleData().getData())
}
