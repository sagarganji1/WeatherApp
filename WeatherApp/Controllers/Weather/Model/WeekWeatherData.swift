//
//  WeekWeatherData.swift
//  WeatherApp
//
//  Created by Sagar ganji on 22.08.2024.
//

import Foundation

struct WeatherResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [WeekWeatherInfo]
    let city: WeekCity
}

struct WeekWeatherInfo: Codable {
    var id: UUID = UUID()
    let dt: TimeInterval?
    let main: WeekMain
    var weather: [WeekWeather]
    let clouds: WeekClouds
    let wind: WeekWind
    let visibility: Int?
    let pop: Float?
    let sys: WeekSys
    let dt_txt: String
    
    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case visibility
        case pop
        case sys
        case dt_txt
    }
}

struct WeekMain: Codable {
    let temp: Double?
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let sea_level: Int
    let grnd_level: Int
    let humidity: Int
    let temp_kf: Double
}

struct WeekWeather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeekClouds: Codable {
    let all: Int
}

struct WeekWind: Codable {
    let speed: Double
    let deg: Double
    let gust: Double
}

struct WeekSys: Codable {
    let pod: String
}

struct WeekCity: Codable {
    let id: Int
    let name: String
    let coord: WeekCoord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct WeekCoord: Codable {
    let lat: Double
    let lon: Double
}

