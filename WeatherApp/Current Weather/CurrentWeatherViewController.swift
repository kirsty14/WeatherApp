//
//  ViewController.swift
//  WeatherApp
//
//  Created by Kirsty-Lee Walker on 2022/04/21.
//

import UIKit
import CoreLocation

class CurrentWeatherViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak private var currentTempValueLabel: UILabel!
    @IBOutlet weak private var weatherConditionLabel: UILabel!
    @IBOutlet weak private var weatherImageViewTheme: UIImageView!
    @IBOutlet weak private var currentBackgroundView: UIView!
    @IBOutlet weak private var minTempLabel: UILabel!
    @IBOutlet weak private var currentTempLabel: UILabel!
    @IBOutlet weak private var maxTempLabel: UILabel!
    @IBOutlet weak private var cityNameLabel: UILabel!
    @IBOutlet weak private var weatherTableView: UITableView!
    
    // MARK: - Vars/Lets
    private lazy var currentWeatherViewModel = CurrentWeatherViewModel(repository: CurrentWeatherRepository(),
                                                                       delegate: self)
    private lazy var locationManager = CLLocationManager()
    private var isImagePressed = false
    private var overallBackgroundColour: UIColor?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableview()
        setUpTodaysWeather()
    }
    
    // MARK: - @IBAction
    @IBAction private func changeImageButtonPressed(_ sender: Any) {
        isImagePressed = !isImagePressed
        currentWeatherViewModel.imagePressed(pressed: isImagePressed)
        setUpTodaysWeather()
    }
    
    @IBAction private func saveLocationButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "FaouritesViewController", sender: self)
    }
    
    // MARK: - Functions
    private func setUpTableview() {
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
    }
    
    func setFavLatLong(cityLattitude: Double, cityLongitude: Double) {
        currentWeatherViewModel.setFavLatLong(cityLattitude: cityLattitude, cityLongitude: cityLongitude)
    }
    
    private func setUpTodaysWeather() {
        currentWeatherViewModel.fetchCurrentWeatherResults { _ in
            guard let currentWeather = self.currentWeatherViewModel.objectCurrentWeather else { return }
            self.updateUpUICurrentWeather(currentWeather: currentWeather)
        }
        
        currentWeatherViewModel.fetchForecastCurrentWeatherResults { _ in
            guard self.currentWeatherViewModel.objectForecastWeather != nil else { return }
            self.weatherTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let currentWeather = self.currentWeatherViewModel.objectCurrentWeather else { return }
        guard let locationName = currentWeather.name else { return }
        let locationLattitude = currentWeather.coord.lat
        let locationLogitude = currentWeather.coord.lon
        if let destination = segue.destination as? FavouriteLocationsViewController {
            destination.setSingleCityData(cityName: locationName,
                                          lattitude: locationLattitude,
                                          longitude: locationLogitude,
                                          image: Constants.SEASUNNY)
        }
        
    }
    
    private func updateUpUICurrentWeather(currentWeather: CurrentWeather) {
        guard let currentTemp = currentWeather.main?.temp else { return }
        guard let minTemp = currentWeather.main?.tempMin else { return }
        guard let maxTemp = currentWeather.main?.tempMin else { return }
        guard let nameCity = currentWeather.name else { return }
        guard let currentCondition = currentWeather.weather?[0].main else { return }
        let imageCondition = currentWeatherViewModel.setBackgroundimage()
        setWeatherUI(currentTemp: currentTemp,
                     minTemp: minTemp,
                     maxTemp: maxTemp,
                     nameCity: nameCity,
                     imageCondition: imageCondition,
                     currentCondition: currentCondition)
        setBackgroundColoursCurrentWeather(currentWeather: currentWeather)
    }
    
    private func setWeatherUI(currentTemp: Double,
                              minTemp: Double,
                              maxTemp: Double,
                              nameCity: String,
                              imageCondition:  String,
                              currentCondition: String) {
        currentTempValueLabel.text = currentTemp.description + "°"
        currentTempLabel.text = currentTemp.description + "°"
        minTempLabel.text = minTemp.description + "°"
        maxTempLabel.text = maxTemp.description  + "°"
        cityNameLabel.text = nameCity
        weatherConditionLabel.text = currentCondition
        weatherImageViewTheme.image = UIImage(named: imageCondition)

    }
    
    private func setBackgroundColoursCurrentWeather(currentWeather: CurrentWeather) {
        guard let weatherConditionType = currentWeather.weather?[0].main.lowercased() else { return }
        let weatherCondition = WeatherCondition.init(rawValue: weatherConditionType)
        var backgroundColour: UIColor
        switch weatherCondition {
        case .sunny:
            backgroundColour = UIColor.sunnyAppColor
            
        case .clear:
            backgroundColour = UIColor.sunnyAppColor
            
        case .clouds:
            backgroundColour = UIColor.cloudyAppColor
            
        case .rain:
            backgroundColour = UIColor.rainyAppColor
            
        case .none:
            backgroundColour = UIColor.sunnyAppColor
        }
        
        currentBackgroundView.backgroundColor = backgroundColour
        weatherImageViewTheme.backgroundColor = backgroundColour
        overallBackgroundColour = backgroundColour
    }
    
    private func setIconForecastWeather(currentCondition: String) -> UIImage {
        var backgroundIcon: UIImage
        let weatherCondition = WeatherCondition.init(rawValue: currentCondition)
        switch weatherCondition {
        case .sunny:
            backgroundIcon = UIImage.sunnyIcon
            
        case .clear:
            backgroundIcon =  UIImage.sunnyIcon
            
        case .clouds:
            backgroundIcon =  UIImage.cloudyIcon
            
        case .rain:
            backgroundIcon =  UIImage.rainyIcon
            
        case .none:
            backgroundIcon =  UIImage.sunnyIcon
        }
        return backgroundIcon
    }
}

extension CurrentWeatherViewController: CurrentWeatherViewModelDelegate {
    func didUpdateWeather(weather: CurrentWeather) {
        DispatchQueue.main.async {
            self.setUpTodaysWeather()
        }
    }
    
    func didFailWithError(error: NSError?) {
        displayAlert(alertTitle: "Location Error",
                     alertMessage: "Could not get your location",
                     alertActionTitle: "Try Again" ,
                     alertDelegate: self,
                     alertTriggered: .errorAlert)
    }
    
    func reloadView() {
        weatherTableView.reloadData()
    }
    
    func showError(error: String, message: String) {
        displayAlert(alertTitle: error,
                     alertMessage: message,
                     alertActionTitle: "Try Again" ,
                     alertDelegate: self,
                     alertTriggered: .errorAlert)
    }
}

// MARK: - Extension - UITableViewDelegate and DataSource
extension CurrentWeatherViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let forecastWeatherCount = currentWeatherViewModel.objectForecastWeather?.list.count else { return 0 }
        return forecastWeatherCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var imageIcon: UIImage
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FiveDayForecastTableViewCell.identifier,
                                                       for: indexPath) as? FiveDayForecastTableViewCell
        else { return UITableViewCell() }

        guard let forecastWeatherCount = currentWeatherViewModel.objectForecastWeather?.list.count else { return UITableViewCell() }

        if indexPath.row > forecastWeatherCount - 1 {
            return UITableViewCell()
        } else {
            guard let temperature = currentWeatherViewModel.objectForecastWeather?.list[indexPath.row].main.temp else { return UITableViewCell() }
            guard let weatherCondition = currentWeatherViewModel.objectForecastWeather?.list[indexPath.row].weather[0].main.lowercased()
            else { return UITableViewCell() }
            guard let colour =  overallBackgroundColour else { return UITableViewCell() }
            imageIcon = setIconForecastWeather(currentCondition: weatherCondition)
            cell.setCellItems(temperature: temperature,
                              day: currentWeatherViewModel.dayOfWeeekArray(index: indexPath.row),
                              colour: colour,
                              imageIcon: imageIcon)
        }
        return cell
    }
}
