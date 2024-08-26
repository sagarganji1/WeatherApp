//
//  CacheManager.swift
//  WeatherApp
//
//  Created by Sagar ganji on 24.08.2024.
//

import Foundation

class CacheManager: CacheStore {
    
    // FileManager instance for data persistence
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
                cacheDirectory = paths[0]
    }
    
    func cacheData(_ data: Data, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error caching data: \(error)")
        }
    }
    
    func getCachedData(forKey key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL)
    }
}

