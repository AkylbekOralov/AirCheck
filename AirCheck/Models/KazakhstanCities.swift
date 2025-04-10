//
//  KazCitiesModel.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 09.04.2025.
//

import Foundation
import CoreLocation

public struct KazakhstanCities {
    static var cities: [LocationModel] = [
        LocationModel(
            name: "Almaty",
            coordinate: CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        ),
        LocationModel(
            name: "Astana",
            coordinate: CLLocationCoordinate2D(latitude: 51.121600, longitude: 71.429791)
        ),
        LocationModel(
            name: "Shymkent",
            coordinate: CLLocationCoordinate2D(latitude: 42.3205, longitude: 69.5876)
        ),
        LocationModel(
            name: "Karaganda",
            coordinate: CLLocationCoordinate2D(latitude: 49.8047, longitude: 73.1094)
        ),
        LocationModel(
            name: "Aktobe",
            coordinate: CLLocationCoordinate2D(latitude: 50.2839, longitude: 57.1670)
        ),
        LocationModel(
            name: "Pavlodar",
            coordinate: CLLocationCoordinate2D(latitude: 52.2873, longitude: 76.9674)
        ),
        LocationModel(
            name: "Taraz",
            coordinate: CLLocationCoordinate2D(latitude: 42.8984, longitude: 71.3980)
        ),
        LocationModel(
            name: "Oskemen",
            coordinate: CLLocationCoordinate2D(latitude: 49.9749, longitude: 82.6017)
        ),
        LocationModel(
            name: "Semey",
            coordinate: CLLocationCoordinate2D(latitude: 50.4233, longitude: 80.2508)
        ),
        LocationModel(
            name: "Kostanay",
            coordinate: CLLocationCoordinate2D(latitude: 53.2198, longitude: 63.6354)
        )
    ]
}
