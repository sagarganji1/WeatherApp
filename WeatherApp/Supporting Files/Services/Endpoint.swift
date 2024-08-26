//
//  Endpoint.swift
//  WeatherApp
//
//  Created by Sagar ganji on 23/08/24.
//

import Foundation


enum Endpoint {
    
    case weather(cityName: String)
    case forcast(cityName: String)
    case image(imageName: String)
    
    private var baseUrl: URL? {
        switch self {
        case .weather, .forcast:
            return URL(string: "https://api.openweathermap.org")
        case .image(_):
            return URL(string: "https://openweathermap.org")
        }
    }
    
    
    var path: String {
        switch self {
        case .weather(_):
            return "data/2.5/weather"
        case .forcast(_):
            return "data/2.5/forecast"
        case .image(let imageName):
            return "img/wn/\(imageName)@2x.png"
        }
    }
    
    var key: String {
        switch self {
        case .weather(let cityName):
            return "WeatherForcast_\(cityName)"
        case .forcast(let cityName):
            return "CityWeather_\(cityName)"
        case .image(let imageName):
            return "image_\(imageName)"
        }
    }
    func buildRequest() -> URLRequest {
        var url = baseUrl!
        url.append(path: self.path)
        let appId = URLQueryItem(name: "appid", value: Constant.OW_API_KEY)
        switch self {
        case .weather(let cityName):
            let q = URLQueryItem(name: "q", value: cityName)
            url.append(queryItems: [q, appId])
            return URLRequest(url: url)
        case .forcast(let cityName):
            let q = URLQueryItem(name: "q", value: cityName)
            url.append(queryItems: [q, appId])
            return URLRequest(url: url)
        case .image(_):
            return URLRequest(url: url)
        }
    }
}
