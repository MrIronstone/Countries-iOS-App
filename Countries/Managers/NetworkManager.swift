//
//  NetworkManager.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import Foundation

struct URLHeaders {
    static let API_KEY = "de64de0dcamsh0a6199a3ff3d1bep1c3fe9jsncebad7489b8f"
    static let baseURL = "https://wft-geo-db.p.rapidapi.com"
}

enum NetworkManagerError: Error {
    case failedToGetData
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func getCountries(completion: @escaping (Result< CountriesResponse, Error >) -> Void) {
        
        let urlString = "https://wft-geo-db.p.rapidapi.com/v1/geo/countries"
        let parameters = ["limit": "10"]
        let headers = ["X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com", "X-RapidAPI-Key": "de64de0dcamsh0a6199a3ff3d1bep1c3fe9jsncebad7489b8f"]
        
        var urlComponents = URLComponents(string: urlString)

        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        urlComponents?.queryItems = queryItems

        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "GET"

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("Countries URL: \(request.url!)")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let results =  try JSONDecoder().decode(CountriesResponse.self, from: data)
                completion(.success(results))
            }
            catch {
                completion(.failure(NetworkManagerError.failedToGetData))
            }
        })
        
        task.resume()
    }
    
    func getNextPage(with url: String, completion: @escaping (Result< CountriesResponse, Error >) -> Void) {
        
        let urlString = "https://wft-geo-db.p.rapidapi.com\(url)"
        let headers = ["X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com", "X-RapidAPI-Key": "de64de0dcamsh0a6199a3ff3d1bep1c3fe9jsncebad7489b8f"]
        
        guard let safeUrl =  URL(string: urlString) else { return }
        
        var request = URLRequest(url: safeUrl)
        request.httpMethod = "GET"

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("Next page URL: \(request.url!)")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let results =  try JSONDecoder().decode(CountriesResponse.self, from: data)
                completion(.success(results))
                print("URL: \(results) ###")
            }
            catch {
                completion(.failure(NetworkManagerError.failedToGetData))
            }
        })
        task.resume()
    }
    
    func getCountryDetails(with code:String, completion: @escaping (Result<CountryDetails, Error >) -> Void) {
        
        let urlString = "https://wft-geo-db.p.rapidapi.com/v1/geo/countries/\(code)"
        let headers = ["X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com", "X-RapidAPI-Key": "de64de0dcamsh0a6199a3ff3d1bep1c3fe9jsncebad7489b8f"]
        
        guard let safeUrl = URL(string: urlString) else { return }
        
        var request = URLRequest(url: safeUrl)
        request.httpMethod = "GET"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("Country Details URL: \(request.url!)")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let results =  try JSONDecoder().decode(CountryDetailsResponse.self, from: data)
                completion(.success(results.data))
            }
            catch {
                completion(.failure(NetworkManagerError.failedToGetData))
            }
        })
        
        task.resume()
    }

}


