//
//  NetworkManager.swift
//  ITMO_NETWORK
//
//  Created by Тюленев Вадим on 06.11.2023.
//

import Foundation

class NetworkManager {
    private var countPage = 0
    static let shared = NetworkManager()
    
    private init() {}

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        if UserDefaults.standard.string(forKey: "authToken") != nil {
            completion(true, UserDefaults.standard.string(forKey: "authToken"))
            return
        }
        
        guard let url = URL(string: "http://127.0.0.1:8080/auth/login") else {
            completion(false, "Invalid URL")
            return
        }
    
        let credentials = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch {
            completion(false, "Error: cannot create JSON from credentials")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false, error!.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let tokenData = data, let token = String(data: tokenData, encoding: .utf8) {
                    completion(true, token)
                } else {
                    completion(false, "Error: did not receive data")
                }
            } else {
                completion(false, "Error: unexpected server response")
            }
        }
        
        task.resume()
    }
    
    func setCountPage(val: Int) {
        countPage = val
    }

    func fetchData(withToken token: String, completion: @escaping (Result<Data, Error>) -> Void) {
        countPage += 1
        guard let url = URL(string: "http://127.0.0.1:8080/rows/\(countPage)") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            countPage -= 1
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let authValue = "\(token)"
        request.addValue(authValue, forHTTPHeaderField: "Authorization")
        print("Request URL: \(request.url?.absoluteString ?? "nil")")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error: unexpected server response"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}
