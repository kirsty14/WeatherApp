//
//  Constants.swift
//  WeatherApp
//
//  Created by Kirsty-Lee Walker on 2022/04/21.
//

import Foundation
import UIKit

struct Constants {
    static var APIKey = "8184f7495ce900d66677e0558be90083"
    static var weatherCurrentURl = "https://api.openweathermap.org/data/2.5/weather?"
    static var weatherForecast5URl = "https://api.openweathermap.org/data/2.5/forecast?"
    static var cityURL = "https://raw.githubusercontent.com/kirsty14/WeatherApp/master/WeatherApp/Resources/locationJsonObject.json"
    static let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    static let FORESTSUNNY = "forest_sunny"
    static let FORESTCLOUDY = "forest_cloudy"
    static let FORESTRAINY = "forest_rainy"
    static let SEASUNNY = "sea_sunnypng"
    static let SEACLOUDY = "sea_cloudy"
    static let SEARAINY = "sea_rainy"
}
