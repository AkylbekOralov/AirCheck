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
        
        static func backgroundColor(for aqi: Int) -> UIColor {
            switch aqi {
            case 0...50:
                // Muted green (still friendly but readable)
                return UIColor(red: 0.31, green: 0.51, blue: 0.32, alpha: 1)
            case 51...100:
                // Muted golden yellow
                return UIColor(red: 0.76, green: 0.60, blue: 0.14, alpha: 1)
            case 101...150:
                // Earthy orange
                return UIColor(red: 0.85, green: 0.48, blue: 0.17, alpha: 1)
            case 151...200:
                // Reddish maroon
                return UIColor(red: 0.78, green: 0.22, blue: 0.22, alpha: 1)
            default:
                // Deep crimson
                return UIColor(red: 0.55, green: 0.00, blue: 0.00, alpha: 1)
            }
        }

        static func secondBackgroundColor(for aqi: Int) -> UIColor {
            switch aqi {
            case 0...50:
                // Deep green
                return UIColor(red: 0.20, green: 0.35, blue: 0.22, alpha: 1)
            case 51...100:
                // Rich mustard yellow
                return UIColor(red: 0.70, green: 0.52, blue: 0.10, alpha: 1)
            case 101...150:
                // Warm brown-orange
                return UIColor(red: 0.72, green: 0.35, blue: 0.10, alpha: 1)
            case 151...200:
                // Deep red
                return UIColor(red: 0.60, green: 0.13, blue: 0.13, alpha: 1)
            default:
                // Dark burgundy
                return UIColor(red: 0.40, green: 0.00, blue: 0.00, alpha: 1)
            }
        }
        
        static func message(for aqi: Int) -> String {
            switch aqi {
            case 0...50:
                return "Air quality is good"
            case 51...100:
                return "Acceptable air quality"
            case 101...150:
                return "Unhealthy for sensitive groups"
            case 151...200:
                return "Unhealthy for everyone"
            case 201...300:
                return "Avoid outdoor activity"
            default:
                return "Hazardous — stay indoors"
            }
        }
    }
