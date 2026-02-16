import SwiftUI

enum WeatherIconMapper {

    /// Maps WMO weather condition codes to SF Symbols
    static func sfSymbol(for code: Int, isDay: Bool) -> String {
        switch code {
        // Clear sky
        case 0:
            return isDay ? "sun.max.fill" : "moon.fill"

        // Mainly clear
        case 1:
            return isDay ? "sun.min.fill" : "moon.fill"

        // Partly cloudy
        case 2:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"

        // Overcast
        case 3:
            return "cloud.fill"

        // Fog
        case 45:
            return "cloud.fog.fill"

        // Depositing rime fog
        case 48:
            return "cloud.fog.fill"

        // Drizzle: light, moderate, dense
        case 51:
            return "cloud.drizzle.fill"
        case 53:
            return "cloud.drizzle.fill"
        case 55:
            return "cloud.drizzle.fill"

        // Freezing drizzle: light, dense
        case 56, 57:
            return "cloud.hail.fill"

        // Rain: slight, moderate, heavy
        case 61:
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 63:
            return "cloud.rain.fill"
        case 65:
            return "cloud.heavyrain.fill"

        // Freezing rain: light, heavy
        case 66, 67:
            return "cloud.hail.fill"

        // Snow fall: slight, moderate, heavy
        case 71:
            return "cloud.snow.fill"
        case 73:
            return "cloud.snow.fill"
        case 75:
            return "snowflake"

        // Snow grains
        case 77:
            return "cloud.snow.fill"

        // Rain showers: slight, moderate, violent
        case 80:
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case 81:
            return "cloud.rain.fill"
        case 82:
            return "cloud.heavyrain.fill"

        // Snow showers: slight, heavy
        case 85:
            return "cloud.snow.fill"
        case 86:
            return "snowflake"

        // Thunderstorm
        case 95:
            return "cloud.bolt.fill"

        // Thunderstorm with hail: slight, heavy
        case 96, 99:
            return "cloud.bolt.rain.fill"

        default:
            return "cloud.fill"
        }
    }

    /// Returns a retro-styled color for WMO weather conditions
    static func conditionColor(for code: Int, isDay: Bool) -> Color {
        switch code {
        // Clear / Mainly clear
        case 0, 1:
            return isDay ? Color.orange : Color(red: 0.4, green: 0.4, blue: 0.7)

        // Partly cloudy
        case 2:
            return isDay ? Color(red: 0.8, green: 0.65, blue: 0.3) : Color(red: 0.5, green: 0.5, blue: 0.6)

        // Overcast
        case 3:
            return Color.gray

        // Fog
        case 45, 48:
            return Color(red: 0.6, green: 0.6, blue: 0.6)

        // Drizzle / Rain / Showers
        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
            return Color(red: 0.4, green: 0.5, blue: 0.7)

        // Freezing drizzle / freezing rain
        case 56, 57, 66, 67:
            return Color(red: 0.5, green: 0.6, blue: 0.7)

        // Snow
        case 71, 73, 75, 77, 85, 86:
            return Color(red: 0.7, green: 0.8, blue: 0.9)

        // Thunderstorm
        case 95, 96, 99:
            return Color(red: 0.7, green: 0.5, blue: 0.3)

        default:
            return Color.gray
        }
    }
}
