//
//  SimpleEntry.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 13.06.2025.
//

import WidgetKit

struct AQIEntry: TimelineEntry {
    let date: Date
    let city: String
    let country: String
    let flag: String
    let aqi: Int
}
