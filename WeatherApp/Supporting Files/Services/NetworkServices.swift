//
//  NetworkServices.swift
//  WeatherApp
//
//  Created by Sagar ganji on 22.08.2024.
//

import Foundation


protocol CacheStore {
    func cacheData(_ data: Data, forKey key: String)
    func getCachedData(forKey key: String) -> Data?
}

protocol WeatherServiceProtocol {
    func getWeatherData<T: Codable>(endPoint: Endpoint, completion: @escaping (Bool, T?, String?) -> ())
}

protocol WatherImageService {
    func getImage(for imageName: String, completion: @escaping (Data) -> ())
}


class NetworkService: WeatherServiceProtocol , WatherImageService {
    
    private let httpClient: URLSessionHTTPClient
    private let cacheStore: CacheStore
    
    init(httpClient: URLSessionHTTPClient = URLSessionHTTPClient(), cacheManager: CacheStore = CacheManager()) {
        self.httpClient = httpClient
        self.cacheStore = cacheManager
    }
    
    func getWeatherData<T: Codable>(endPoint: Endpoint, completion: @escaping (Bool, T?, String?) -> ()) {
        
        guard let data = cacheStore.getCachedData(forKey: endPoint.key) else {
            self.fetch(endPoint: endPoint, completion: completion)
            return
        }
        do {
            let model = try parse(type: T.self, response: data)
            completion(true, model as? T, "Error: \(T.self) parsing failed")
        } catch {
            completion(false, nil, error.localizedDescription)
        }
    }
    
    private func parse<T: Codable>(type: T.Type, response: Data) throws -> T? {
        let model = try JSONDecoder().decode(type, from: response)
        return model
    }
    
    private func fetch<T: Codable>(endPoint: Endpoint, completion: @escaping (Bool, T?, String?) -> ()) {
        
        guard let url = endPoint.buildRequest().url else { return }
        print(url)
        httpClient.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                do {
                    let model = try parse(type: T.self, response: response)
                    self.cacheStore.cacheData(response, forKey: endPoint.key)
                    completion(true, model, nil)
                } catch {
                    completion(false, nil, "Error: Trying to parse \(T.self) data to model")
                }
            case .failure(_):
                
                completion(false, nil, "Error: \(T.self) GET Request failed")
            }
        }
    }
    
    func getImage(for imageName: String, completion: @escaping (Data) -> ()) {
        
        guard let data = CacheManager().getCachedData(forKey: imageName) else {
            
            guard let url = Endpoint.image(imageName: imageName).buildRequest().url else { return }
            httpClient.get(from: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.cacheStore.cacheData(data, forKey: imageName)
                    completion(data)
                case .failure(_):
                    return
                }
            }
            return 
        }
        completion(data)
     }
}
