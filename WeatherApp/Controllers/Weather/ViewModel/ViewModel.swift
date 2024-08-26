//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Sagar ganji on 22.08.2024.
//

import Foundation

class WeatherViewModel {
    
    //MARK: - Var(s)
    var tempBool = true
    var todayOrWeekelySegement = true
    
    // Weekly and daily weather forecasts, current weather, and location manager
    var weekForecast: [WeekWeatherInfo] = []
    var todayForeCast: [WeekWeatherInfo] = []
    
    // Network service instance for making API requests
    let networkService: WeatherServiceProtocol & WatherImageService
    
    // Callbacks to notify the UI when data updates
    var reloadWeatherList: (() -> Void)?
    var showWeatherData: (() -> Void)?
    
    let cityManager: LocationManager
    
    init(cityManager:  LocationManager = LocationManager.shared,
         networkService: WeatherServiceProtocol & WatherImageService) {
        self.cityManager = cityManager
        self.networkService = networkService
        
        // Fetches the current city using the location manager
        cityManager.getCurrentCity { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cityName):
                self.getWeatherForeCastData(city: cityName)
                self.getCityWeatherData(city: cityName)
            case .failure(let error):
                print("Error getting city name: \(error)")
            }
        }
    }
    
    
    // Data sources for weather information
    var weatherForeCastData = [WeekWeatherInfo]() {
        didSet {
            // Trigger UI update when weekly weather forecast data is set
            updateForeCastList(arrForeCastData: weatherForeCastData)
        }
    }
    
    var cityWeatherData: WeatherData? {
        didSet {
            // Trigger UI update when current city weather data is set
            if self.cityWeatherData != nil {
                self.showWeatherData?()
            }
        }
    }
    
    
    //MARK: - Helper Method(s)
    
    // Fetch weekly weather forecast data for a specific city
    func getWeatherForeCastData(city: String) {
        let endpoint = Endpoint.forcast(cityName: city)
        networkService.getWeatherData(endPoint: endpoint, completion: { (status: Bool, data: WeatherResponse?, msg: String?) in
            if status, let arrData = data {
                self.weatherForeCastData = arrData.list
            } else {
                print("Error: - \(msg ?? "NA")")
            }
        })
    }
    
    // Fetch current weather data for a specific city
    func getCityWeatherData(city: String) {
        let endpoint = Endpoint.weather(cityName: city)
        networkService.getWeatherData(endPoint: endpoint, completion: { (status: Bool, data: WeatherData?, msg: String?) in
            if status, let weatherData = data {
                self.cityWeatherData = weatherData
            } else {
                print("Error: - \(msg ?? "NA")")
            }
        })
    }
    
    func getTemp(for data: WeekWeatherInfo) -> String {
        if let tempInKelvin = data.main.temp {
            let tempInCelsius = Utility.kelvinToCelsius(kelvin: tempInKelvin)
             return convertTemperature(tempInCelsius)
        } else {
            return "NA"
        }
    }
    
    func getTimeinterval(for data: WeekWeatherInfo) -> String {
        if let timeInterval = data.dt {
            return todayOrWeekelySegement ?
            Utility.getDateFromTimeStamp(timeStamp: timeInterval, timeFormat: .timeOnly) : Utility.getDateFromTimeStamp(timeStamp: timeInterval)
        } else {
            return "NA"
        }
    }
    
    func getCurrentWeatherIcon(completion: @escaping (Data) -> ()) {
        
        if let iconName = self.cityWeatherData?.weather.first?.icon {
            getImageIcon(iconName: iconName, completion: completion)
        }
    }
    
    func getImageIcon(iconName: String, completion: @escaping (Data) -> ()) {
        networkService.getImage(for: iconName, completion: { data in
            DispatchQueue.main.async {
                completion(data)
            }
        })
    }
    
    func convertTemperature(_ celsius: Double) -> String {
        let roundedTemperature = round(celsius)
        return tempBool ? String(format: "%.0f °C", roundedTemperature) : String(format: "%.0f °F", celsiusToFahrenheit(roundedTemperature))
    }
    
    func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return round((celsius * 9/5) + 32)
    }
    
    func getFormattedDate() -> String {
        if let timeInterval = self.cityWeatherData?.dt {
            return Utility.getDateFromTimeStamp(timeStamp: timeInterval)
        } else {
            return "NA"
        }
    }
    
    func getDescription() -> String {
        self.cityWeatherData?.weather.first?.description ?? "NA"
    }
    
    func getCity() -> String {
        self.cityWeatherData?.name ?? "NA"
    }
    
    func getFormattedTemprature() -> String {
        if let temperature = self.cityWeatherData?.main.temp {
            let celsiusTemperature = Utility.kelvinToCelsius(kelvin: temperature)
            let roundedTemperature = tempBool ? round(celsiusTemperature) : round(celsiusToFahrenheit(celsiusTemperature))
            return tempBool ? String(format: "%.2f °C", roundedTemperature) : String(format: "%.2f °F", roundedTemperature)
            
        } else {
            return "NA"
        }
    }
    
    func getFormatterTemp(for temperature: Double) -> String {
        let celsiusTemperature = Utility.kelvinToCelsius(kelvin: temperature)
        let roundedTemperature = tempBool ? round(celsiusTemperature) : round(celsiusToFahrenheit(celsiusTemperature))
        return tempBool ? String(format: "%.2f °C", roundedTemperature) : String(format: "%.2f °F", roundedTemperature)
    }
    
    // performSearch: Initiates a weather search for the specified city
    func performSearch(with cityName: String) {
        self.getWeatherForeCastData(city: cityName)
        self.getCityWeatherData(city: cityName)
    }
    
    func getCellCount() -> Int {
        self.todayOrWeekelySegement ? self.todayForeCast.count : self.weekForecast.count
    }
    
    func getCurrentList() -> [WeekWeatherInfo] {
        self.todayOrWeekelySegement ? self.todayForeCast : self.weekForecast
    }
    
    func updateForeCastList(arrForeCastData: [WeekWeatherInfo]) {
        self.weekForecast = arrForeCastData.filter({ Utility.isTimeIntervalForToday(timeInterval: $0.dt ?? .zero) == false })
        self.todayForeCast = arrForeCastData.filter({ Utility.isTimeIntervalForToday(timeInterval: $0.dt ?? .zero) == true  })
        self.reloadWeatherList?()
    }
}
