//
//  Connection.swift
//  Weather 1.0
//
//  Created by Dmitriy Mikitenko on 01.08.2021.
//

import Foundation
import CoreLocation

struct WeatherResponse: Codable {
    var weather: [WeatherStruct]
    var main: MainStruct
    var wind: WindStruct
    var sys: SysStruct
    var name : String
}

struct WeatherStruct: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct MainStruct: Codable {
    var temp: Double
    var feels_like: Double
    var temp_min: Double
    var temp_max: Double
    var pressure: Double
    var humidity: Double
}

struct WindStruct: Codable {
    var speed: Double
    var deg: Double
}

struct SysStruct: Codable {
    var type: Int
    var id: Int
    var country: String
    var sunrise: Int
    var sunset: Int
}

class WeatherService {
    
    func downloadWeather(forLatitude latitude:CLLocationDegrees, longitude:CLLocationDegrees, completitionBlock: @escaping (WeatherResponse?) -> Void) {
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=df905f74a4f8f316d5fef296b9402248&units=metric&lang=ua"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
                do {
                    let answer = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    completitionBlock(answer)
                } catch {
                    print(error)
                }
        }.resume()
    }
}
