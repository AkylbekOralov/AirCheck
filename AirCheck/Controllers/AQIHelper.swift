    //
    //  AQIColorHelper.swift
    //  AirCheck
    //
    //  Created by Akylbek Oralov on 30.03.2025.
    //

    import UIKit

    struct AQIHelper {
        static func color(for aqi: Int) -> UIColor {
            switch aqi {
            case 0...50: return .systemGreen
            case 51...100: return .systemYellow
            case 101...150: return .systemOrange
            default: return .systemRed
            }
        }
        
        static func image(for aqi: Int) -> String {
            switch aqi {
            case 0...50: return "Smile"
            case 51...100: return "Confused"
            case 101...150: return "Sad"
            default: return "SuperSad"
            }
        }
        
        static func state(for aqi: Int) -> String {
            switch aqi {
            case 0...50: return "Good"
            case 51...100: return "Moderate"
            case 101...150: return "Bad"
            default: return "Terrible"
            }
        }
    }
