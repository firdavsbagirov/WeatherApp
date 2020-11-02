//
//  ViewController.swift
//  WeatherApp
//
//  Created by Firdavs Bagirov on 11/1/20.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    var networkWeatherManager = NetworkWeatherManager()
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    } ()
    
    override func viewDidLoad() {
        networkWeatherManager.onCompletion = { [weak self] currentWeather in
            guard let self = self else { return }
            self.updateInfterfaceWith(weather: currentWeather)
            
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        
    }
    
    
    func updateInfterfaceWith(weather: CurrentWeather) {
        DispatchQueue.main.async {
            self.cityNameLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.feelsLikeTemperatureLabel.text = weather.feelsLikeTemperatureString
            self.weatherIconImageView.image = UIImage(systemName: weather.systemIconNameString)
        }
        
        
    }

    @IBAction func searchCityButtonPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert) {
            [unowned self] city in
            self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: city))
        }
      
    }
}


extension ViewController {
    func presentSearchAlertController(withTitle title: String, message: String?, style: UIAlertController.Style, completionHandler: @escaping (String) -> Void) {
        let ac = UIAlertController(title: "Enter city name", message: nil, preferredStyle: .alert)
        ac.addTextField { (tf) in
            let citiesArray = ["Moscow", "London", "Tokyo", "Tashkent", "Madrid", "New York"]
            tf.placeholder = citiesArray.randomElement()
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { (action) in
            let textField = ac.textFields?.first
            guard let cityName = textField?.text else { return }
            if cityName != "" {
              //  self.networkWeatherManager.fetchCurrentWeather(forCity: cityName)
                let city = cityName.split(separator: " ").joined(separator: "%20")
                completionHandler(city)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(searchAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)
        
    }
    }

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        networkWeatherManager.fetchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
