//
//  CityModel.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 09.04.2025.
//

import Foundation
import CoreLocation

struct LocationModel {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let description: String?
    
    init(name: String, coordinate: CLLocationCoordinate2D, description: String? = nil) {
        self.name = name
        self.coordinate = coordinate
        self.description = description
    }
}
