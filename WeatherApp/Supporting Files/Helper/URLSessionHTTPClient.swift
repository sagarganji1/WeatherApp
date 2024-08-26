//
//  URLSessionHTTPClient.swift
//  WeatherApp
//
//  Created by Sagar ganji on 22.08.2024.
//

import Foundation

public class URLSessionHTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error { }
    
    public func get(from url: URL, completion: @escaping (Result<Data, Error>) -> ()) {
        
        session.dataTask(with: url) { data, response, error in
            // Check for errors and handle accordingly
            guard error == nil else {
                print("Error: problem calling GET")
                print(error!)
                completion(.failure(UnexpectedValuesRepresentation()))
                return
            }
            // Check if data was received
            guard let data = data else {
                print("Error: did not receive data")
                completion(.failure(UnexpectedValuesRepresentation()))
                return
            }
            // Check if the HTTP response status code is in the success range
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                completion(.failure(UnexpectedValuesRepresentation()))
                return
            }
            // Call the completion handler with success status and data
            completion(.success(data))
        }.resume()
    }
}
