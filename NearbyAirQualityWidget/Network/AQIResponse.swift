//
//  AQIResponse.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 13.06.2025.
//

import Foundation

struct AQIResponse: Decodable {
    struct Data: Decodable {
        let city: String
        let country: String
        let current: Current
    }
    struct Current: Decodable {
        let pollution: Pollution
    }
    struct Pollution: Decodable {
        let aqius: Int
    }
    
    let data: Data
}
