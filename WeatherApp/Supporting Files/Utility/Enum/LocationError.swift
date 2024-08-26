//
//  LocationError.swift
//  WeatherApp
//
//  Created by Sagar ganji on 24.08.2024.
//

import Foundation

enum LocationError: Error {
    case noLocationAvailable
    case noCityAvailable
    case noPlacemarkAvailable
}
