import SwiftUI

struct WeatherResponse: Decodable {
    let temperature: Temperature
}

struct Temperature: Decodable {
    let degrees: Double
    let unit: String
}

@MainActor
class GoogleWeatherViewModel: ObservableObject {
    @Published var temperature: String = "--"
    
    func fetchWeather(lat: Double, lon: Double, apiKey: String) {
        print("fetching")
        guard let url = URL(string:
            "https://weather.googleapis.com/v1/currentConditions:lookup?location.latitude=\(lat)&location.longitude=\(lon)&key=\(apiKey)"
        ) else {
            print("error")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.temperature = "\(String(result.temperature.degrees)) °C"
                }
            } catch {
                
            }
        }.resume()
    }
}
