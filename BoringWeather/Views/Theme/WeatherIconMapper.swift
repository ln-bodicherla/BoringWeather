import SwiftUI

enum WeatherIconMapper {

    static func sfSymbol(for code: Int, isDay: Bool) -> String {
        switch code {
        case 0: return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1: return isDay ? "sun.min.fill" : "moon.fill"
        case 2: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: return "cloud.fill"
        case 45: return "cloud.fog.fill"
        case 48: return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 56, 57: return "cloud.hail.fill"
        case 61: return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 63: return "cloud.rain.fill"
        case 65: return "cloud.heavyrain.fill"
        case 66, 67: return "cloud.hail.fill"
        case 71, 73: return "cloud.snow.fill"
        case 75: return "snowflake"
        case 77: return "cloud.snow.fill"
        case 80: return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 81: return "cloud.rain.fill"
        case 82: return "cloud.heavyrain.fill"
        case 85: return "cloud.snow.fill"
        case 86: return "snowflake"
        case 95: return "cloud.bolt.fill"
        case 96, 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }

    static func conditionColor(for code: Int, isDay: Bool) -> Color {
        switch code {
        case 0, 1:
            return isDay ? Color(red: 1.0, green: 0.8, blue: 0.2) : Color(red: 0.6, green: 0.6, blue: 1.0)
        case 2:
            return isDay ? Color(red: 1.0, green: 0.85, blue: 0.4) : Color(red: 0.6, green: 0.65, blue: 0.9)
        case 3:
            return Color(red: 0.65, green: 0.7, blue: 0.8)
        case 45, 48:
            return Color(red: 0.6, green: 0.65, blue: 0.75)
        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
            return Color(red: 0.35, green: 0.65, blue: 1.0)
        case 56, 57, 66, 67:
            return Color(red: 0.55, green: 0.8, blue: 1.0)
        case 71, 73, 75, 77, 85, 86:
            return Color(red: 0.85, green: 0.9, blue: 1.0)
        case 95, 96, 99:
            return Color(red: 0.85, green: 0.55, blue: 1.0)
        default:
            return Color(red: 0.6, green: 0.65, blue: 0.75)
        }
    }

    /// Ambient blob colors for background based on condition
    static func ambientColors(for code: Int, isDay: Bool) -> [Color] {
        switch code {
        case 0, 1:
            return isDay
                ? [Color(red: 0.9, green: 0.6, blue: 0.1), Color(red: 1.0, green: 0.3, blue: 0.2), Color(red: 0.6, green: 0.3, blue: 0.9)]
                : [Color(red: 0.2, green: 0.2, blue: 0.6), Color(red: 0.1, green: 0.1, blue: 0.4), Color(red: 0.3, green: 0.15, blue: 0.5)]
        case 2, 3:
            return [Color(red: 0.3, green: 0.35, blue: 0.55), Color(red: 0.2, green: 0.25, blue: 0.45), Color(red: 0.15, green: 0.2, blue: 0.4)]
        case 51...67, 80...82:
            return [Color(red: 0.15, green: 0.3, blue: 0.6), Color(red: 0.1, green: 0.2, blue: 0.5), Color(red: 0.2, green: 0.15, blue: 0.5)]
        case 71...86:
            return [Color(red: 0.3, green: 0.35, blue: 0.5), Color(red: 0.25, green: 0.3, blue: 0.45), Color(red: 0.2, green: 0.2, blue: 0.4)]
        case 95, 96, 99:
            return [Color(red: 0.4, green: 0.15, blue: 0.5), Color(red: 0.3, green: 0.1, blue: 0.4), Color(red: 0.2, green: 0.1, blue: 0.3)]
        default:
            return [Color(red: 0.2, green: 0.25, blue: 0.4), Color(red: 0.15, green: 0.15, blue: 0.3), Color(red: 0.1, green: 0.1, blue: 0.25)]
        }
    }
}
