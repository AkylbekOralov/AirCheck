    //
    //  AQIColorHelper.swift
    //  AirCheck
    //
    //  Created by Akylbek Oralov on 30.03.2025.
    //

    import UIKit

    struct AQIColorHelper {
        static func color(for aqi: Int) -> UIColor {
            switch aqi {
            case 0...50: return .systemGreen
            case 51...100: return .systemYellow
            case 101...150: return .systemOrange
            case 151...200: return .systemRed
            case 201...300: return .purple
            default: return .brown
            }
        }
    }
