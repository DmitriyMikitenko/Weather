//
//  CurrentCityViewController.swift
//  Weather 1.0
//
//  Created by Dmitriy Mikitenko on 01.08.2021.
//

import UIKit
import CoreLocation


class CurrentCityViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet private weak var cityNameLabel: UILabel!
    @IBOutlet private weak var weatherCondition: UILabel!
    @IBOutlet private weak var temperature: UILabel!
    @IBOutlet private weak var weatherInfoTableView: WeatherInfoTableView!

    private let locationManager = CLLocationManager()
    private var weatherData: WeatherResponse? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.weatherInfoTableView.dataSource = self
        self.registerTableViewCells()
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()

        if let location = locations.first {
            let weatherManager = WeatherService()
            weatherManager.downloadWeather(forLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude){ (result) in
                guard let answer = result else { return }
                self.weatherData = answer
                
                DispatchQueue.main.async {
                    if let data = self.weatherData{
                        self.cityNameLabel.text = data.name
                        self.weatherCondition.text = data.weather[0].description
                        self.temperature.text = String(Int(data.main.temp)) + "℃"
                    }
                    self.weatherInfoTableView.reloadData()
                }
            }
        }
    }
    
    private func registerTableViewCells() {
        let dateCell = UINib(nibName: "CurrentConditionsCell", bundle: nil)
        self.weatherInfoTableView.register(dateCell, forCellReuseIdentifier: "CurrentConditionsCell")
        
        let todayCell = UINib(nibName: "TodayDescriptionCell", bundle: nil)
        self.weatherInfoTableView.register(todayCell, forCellReuseIdentifier: "TodayDescriptionCell")
        
        let conditionsCell = UINib(nibName: "DetailsTableViewCell", bundle: nil)
        self.weatherInfoTableView.register(conditionsCell, forCellReuseIdentifier: "DetailsTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.item {
        case 0...2:
            return createCurentConditionsCell(index: indexPath)
        case 3:
            return createTodayCell()
        case 4...6:
            return createDetailCell(index: indexPath)
        default:
            return UITableViewCell()
        }
            }
    
    func createCurentConditionsCell(index: IndexPath) -> CurrentConditionsCell {
        
        if let cell = weatherInfoTableView.dequeueReusableCell(withIdentifier: "CurrentConditionsCell") as? CurrentConditionsCell {
            
            if let data = weatherData {
                switch index.item {
                case 0:
                    cell.conditionsNameLabel.text = "Атмосферний тиск"
                    //cell.conditionsImageView.image = UIImage(systemName: "heart")
                    cell.conditionsDescriptionLabel.text = String(data.main.pressure) + "hPa"
                case 1:
                    cell.conditionsNameLabel.text = "Вологість повітря"
                    cell.conditionsDescriptionLabel.text = String(data.main.humidity) + "%"
                case 2:
                    cell.conditionsNameLabel.text = "Відчувається як"
                    cell.conditionsDescriptionLabel.text = String(data.main.feels_like) + "℃"
                default: break
                }
            }
            return cell
        }
        return CurrentConditionsCell()
    }
    
    private func createTodayCell() -> TodayDescriptionTableViewCell {
        if let cell  = weatherInfoTableView.dequeueReusableCell(withIdentifier: "TodayDescriptionCell") as? TodayDescriptionTableViewCell {
            if let data = weatherData {
                cell.descriptionLabel.text = "Максимальна температура: \(Int(data.main.temp_max))℃. Мінімальна температура: \(Int(data.main.temp_min))℃. Погодні умови: \(data.weather[0].description)"
            }
            return cell
        }
        return TodayDescriptionTableViewCell()
    }
    
    private func createDetailCell(index: IndexPath) -> DetailsTableViewCell {
        if let cell  = weatherInfoTableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell") as? DetailsTableViewCell {
            if let data = weatherData {
                
                switch index.item {
                case 4:
                    cell.titleLabel.text = "Схід"
                    cell.descriptionsLabel.text = getTime(fromUnixInt: data.sys.sunrise)
                case 5:
                    cell.titleLabel.text = "Захід"
                    cell.descriptionsLabel.text = getTime(fromUnixInt: data.sys.sunset)
                case 6:
                    cell.titleLabel.text = "Вітер"
                    cell.descriptionsLabel.text = "Швидкість: \(Int(data.wind.speed))м/сек. Напрямок: \(getDirection(fromDegrees: (data.wind.deg))) "
                default: break
                }
            }
            return cell
        }
        return DetailsTableViewCell()
    }
    
    private func getTime(fromUnixInt unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
    
    private func getDirection(fromDegrees degrees: Double) -> String {
        switch degrees {
        case 0...45, 316...360:
            return "Північний"
        case 46...135:
            return "Східний"
        case 136...225:
            return "Південий"
        case 226...315:
            return "Західний"
        default:
            return "Не вірний формат"
        }
    }
}
