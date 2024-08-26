//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Sagar ganji on 24.08.2024.
//

import SwiftUI

struct WeatherDetailView: View {
    
    
    var timeStamp: String?
    var mainTemp: String
    var maxTemp: String
    var minTemp: String
    var humidity: String
    var description: String
    
    var body: some View {
        VStack(spacing: 20) {
            //MARK: Date Label
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text(timeStamp ?? "N/A")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            //MARK: Temperature Labels
            Group {
                WeatherInfoRow(label: "Temperature", value: mainTemp)
                WeatherInfoRow(label: "Max temperature", value: maxTemp)
                WeatherInfoRow(label: "Min temperature", value: minTemp)
                WeatherInfoRow(label: "Humidity", value: humidity)
                WeatherInfoRow(label: "Description", value: description)
            }
            .font(.headline)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    //MARK: Convert temperature from Celsius to Fahrenheit.
    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }
}

//MARK: Helper view for displaying weather information rows
struct WeatherInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label) :")
                .fontWeight(.bold)
            Spacer()
            Text(value)
        }
    }
}

struct WeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherDetailView(mainTemp: "28.0", maxTemp: "35.5", minTemp: "34.0", humidity: "15", description: "Humidity")
    }
}
