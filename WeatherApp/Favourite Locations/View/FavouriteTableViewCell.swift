//
//  FavouriteTableViewCell.swift
//  WeatherApp
//
//  Created by Kirsty-Lee Walker on 2022/04/23.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {

    // MARK: - IBOulets
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityLattitudeLabel: UILabel!
    @IBOutlet weak var cityLongitudeLabel: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!

    // MARK: - Functions
    func updateUI(cityName: String?, lattitudeCity: Double?, longitudeCity: Double?) {
        cityImageView.image = UIImage(named: Constants.SEASUNNY)
        self.cityImageView.layer.cornerRadius = 10
        cityNameLabel.text = cityName
        guard let lattitude = lattitudeCity?.description else { return }
        guard let longitude = longitudeCity?.description else { return }
        cityLattitudeLabel.text = "Lattitude: " + lattitude
        cityLongitudeLabel.text = "Longitude: " + longitude
    }
}
