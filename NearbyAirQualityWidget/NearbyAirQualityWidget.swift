//
//  NearbyAirQualityWidget.swift
//  NearbyAirQualityWidget
//
//  Created by Akylbek Oralov on 10.04.2025.
//

import WidgetKit
import SwiftUI

struct NearbyAirQualityWidget: Widget {
    let kind: String = "NearbyAirQualityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NearbyAirQualityWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Nearby Air Quality")
        .description("Shows your current location's coordinates.")
        .supportedFamilies([.systemSmall, .systemMedium]) // add/remove sizes as needed
    }
}
