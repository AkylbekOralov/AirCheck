//
//  AQIModel.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 23.03.2025.
//

import Foundation

struct AQIMarker: Decodable {
    let name: String?
    let id: String?
    let aqi: Int
    let type: String?
    let url: String?
    let coordinates: Coordinates
    let isHighPrecisionStation: Bool?
}

struct Coordinates: Decodable {
    let latitude: Double
    let longitude: Double
}

struct AQIResponse: Decodable {
    let markers: [AQIMarker]
    let total: Int
}
