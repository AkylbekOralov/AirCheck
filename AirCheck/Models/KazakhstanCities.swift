//
//  KazCitiesModel.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 09.04.2025.
//

import Foundation
import CoreLocation

public struct KazakhstanCities {
    static var cities: [CityModel] = [
        CityModel(
            cityName: "Almaty",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Astana",
            location: CLLocationCoordinate2D(latitude: 51.121600, longitude: 71.429791)
        ),
        CityModel(
            cityName: "Shymkent",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Karaganda",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Aktobe",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Pavlodar",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Taraz",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Oskemen",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Semey",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        CityModel(
            cityName: "Kostanay",
            location: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        )
    ]
}
