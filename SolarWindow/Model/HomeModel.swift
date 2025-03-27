//
//  HomeModel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 1/18/25.
//

import Foundation

struct Home {
    private var esp32BaseURL: String
    
    init() {
        esp32BaseURL = "http://192.168.1.222"
    }
    
    func sunPositionX(degree: Double) -> CGFloat {
        let radius: CGFloat = 250
        return radius * cos(CGFloat(degree) * .pi / 180)
    }
    
    /// Calculates the vertical position of the sun based on the degree (top half of a circle)
    func sunPositionY(degree: Double) -> CGFloat {
        let radius: CGFloat = 250 // Radius of the arc
        return radius * sin(CGFloat(degree) * .pi / 180)
    }
    
    func sendRequestForMode(endpoint: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(esp32BaseURL)\(endpoint)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                completion(responseBody)
            } else {
                print("No response data or unable to decode response.")
                completion(nil)
            }
        }.resume()
    }

    
    
    func sendRequest(endpoint: String, degree: Double) {
        guard let url = URL(string: "\(esp32BaseURL)\(endpoint)?degree=\(degree)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Response code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}
