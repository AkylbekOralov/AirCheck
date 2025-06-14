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
    
    private let maxAQI: Double = 300
    
    var progress: Double {
        min(Double(entry.aqi) / maxAQI, 1.0)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color.blue.opacity(0.15)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            
            Circle()
                .trim(from: 0.025, to: 0.8)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green, .yellow, .orange, .red, .purple, .brown, .brown, .brown, .brown, .black]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .rotationEffect(.degrees(122))
                .frame(width: 100, height: 100)
            
            Circle()
                .stroke(Color.white,
                        style: StrokeStyle(lineWidth: 4, lineCap: .square))
                .frame(width: 12, height: 12)
                .offset(y: 50)
                .rotationEffect(.degrees(progress * 360))
                .shadow(color: .white, radius: 1)
            
            Text("\(entry.aqi)")
                .font(.system(size: 35, weight: .medium))
                .foregroundColor(.black)
                
            Text("AQI")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0, green: 0.01, blue: 0.4))
                .offset(y: 42)
        }
    }
}

#Preview(as: .systemSmall) {
    NearbyAirQualityWidget()
} timeline: {
    AQIEntry(date: .now, city: "Алматы", country: "Казахстан", flag: "🇰🇿", aqi: 42)
}
