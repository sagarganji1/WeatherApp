//
//  Constant.swift
//  WeatherApp
//
//  Created by Sagar ganji on 22.08.2024.
//

import Foundation

struct Constant {
    
    static var OW_API_KEY: String {
        get {
            if let storedKey = KeychainService.getAPIKey() {
                return storedKey
            } else {
                return "555707b60a648234521b877ef252df72"
            }
        }
        set {
            KeychainService.saveAPIKey(newValue)
        }
    }
}
