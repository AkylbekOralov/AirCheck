//
//  NearbyAirQualityWidgetEntryView.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 13.06.2025.
//

import SwiftUI
import WidgetKit

struct NearbyAirQualityWidgetEntryView : View {
    var entry: AQIEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.city)
                .font(.headline)
            
            HStack {
                Text(entry.country)
                Text(entry.flag)
            }
            .font(.subheadline)

            Text("AQI: \(entry.aqius)")
                .font(.title2)
                .bold()
        }
    }
}
