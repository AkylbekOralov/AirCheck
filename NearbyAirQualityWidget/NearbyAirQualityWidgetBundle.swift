//
//  NearbyAirQualityWidgetBundle.swift
//  NearbyAirQualityWidget
//
//  Created by Akylbek Oralov on 10.04.2025.
//

import WidgetKit
import SwiftUI

@main
struct NearbyAirQualityWidgetBundle: WidgetBundle {
    var body: some Widget {
        NearbyAirQualityWidget()
        NearbyAirQualityWidgetControl()
        NearbyAirQualityWidgetLiveActivity()
    }
}
