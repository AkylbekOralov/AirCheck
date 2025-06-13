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
        ZStack {
            backgroundForAQI(entry.aqi)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.city)
                    .font(.system(size: 24, weight: .bold))
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)

                HStack(spacing: 8) {
                    Text(entry.country)
                    Text(entry.flag)
                }
                .font(.system(size: 16, weight: .medium))
                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                .padding(.bottom, 8)

                Text("ИКВ: \(entry.aqi)")
                    .font(.system(size: 24, weight: .medium))
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    func backgroundForAQI(_ aqi: Int) -> LinearGradient {
        switch aqi {
        case 0..<51:
            return LinearGradient(colors: [.green.opacity(0.3), .green], startPoint: .top, endPoint: .bottom)
        case 51..<101:
            return LinearGradient(colors: [.yellow.opacity(0.3), .orange], startPoint: .top, endPoint: .bottom)
        case 101..<151:
            return LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
        case 151..<201:
            return LinearGradient(colors: [.red, .purple], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
        }
    }
}

#Preview(as: .systemSmall) {
    NearbyAirQualityWidget()
} timeline: {
    AQIEntry(date: .now, city: "Алматы", country: "Казахстан", flag: "🇰🇿", aqi: 42)
}
