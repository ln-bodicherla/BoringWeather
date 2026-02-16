import Foundation

// MARK: - Domain Models (used by Views/ViewModels)

struct WeatherData: Codable, Identifiable {
    var id: String { location.name + location.region }
    let location: LocationInfo
    let current: CurrentWeather
    let forecast: Forecast
    let alerts: AlertData?
    let airQuality: AirQualityInfo?
    let lastUpdated: Date

    init(location: LocationInfo, current: CurrentWeather, forecast: Forecast,
         alerts: AlertData?, airQuality: AirQualityInfo?, lastUpdated: Date = Date()) {
        self.location = location
        self.current = current
        self.forecast = forecast
        self.alerts = alerts
        self.airQuality = airQuality
        self.lastUpdated = lastUpdated
    }
}

struct LocationInfo: Codable, Hashable {
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timeZoneID: String
    let localtime: String
}

struct CurrentWeather: Codable {
    let tempC: Double
    let tempF: Double
    let feelsLikeC: Double
    let feelsLikeF: Double
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    let windMph: Double
    let windKph: Double
    let windDegree: Int
    let windDirection: String
    let humidity: Int
    let pressureMb: Double
    let pressureIn: Double
    let visibilityKm: Double
    let visibilityMiles: Double
    let uvIndex: Double
    let airQuality: AirQualityInfo?
}

struct Forecast: Codable {
    let days: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var id: String { date }
    let date: String
    let maxTempC: Double
    let maxTempF: Double
    let minTempC: Double
    let minTempF: Double
    let avgTempC: Double
    let avgTempF: Double
    let maxWindMph: Double
    let maxWindKph: Double
    let totalPrecipMm: Double
    let totalPrecipIn: Double
    let avgHumidity: Int
    let dailyChanceOfRain: Int
    let dailyChanceOfSnow: Int
    let conditionText: String
    let conditionCode: Int
    let uvIndex: Double
    let sunrise: String
    let sunset: String
    let hours: [HourForecast]
    let airQuality: AirQualityInfo?
}

struct HourForecast: Codable, Identifiable {
    var id: String { time }
    let time: String
    let tempC: Double
    let tempF: Double
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    let windMph: Double
    let windKph: Double
    let chanceOfRain: Int
    let chanceOfSnow: Int
    let humidity: Int
    let feelsLikeC: Double
    let feelsLikeF: Double
}

struct AlertData: Codable {
    let alerts: [WeatherAlert]
}

struct WeatherAlert: Codable, Identifiable {
    var id: String { headline + effective }
    let headline: String
    let severity: String
    let urgency: String
    let areas: String
    let category: String
    let event: String
    let effective: String
    let expires: String
    let description: String
    let instruction: String
}

struct AirQualityInfo: Codable {
    let usAQI: Int?
    let pm2_5: Double?
    let pm10: Double?
    let o3: Double?
    let no2: Double?
    let so2: Double?
    let co: Double?

    var aqiCategory: String {
        guard let aqi = usAQI else { return "N/A" }
        switch aqi {
        case 0...50: return "Good"
        case 51...100: return "Moderate"
        case 101...150: return "Unhealthy (Sensitive)"
        case 151...200: return "Unhealthy"
        case 201...300: return "Very Unhealthy"
        case 301...: return "Hazardous"
        default: return "Unknown"
        }
    }

    var healthRecommendation: String {
        guard let aqi = usAQI else { return "No data available." }
        switch aqi {
        case 0...50: return "Air quality is satisfactory. Enjoy outdoor activities."
        case 51...100: return "Acceptable. Sensitive individuals should limit prolonged outdoor exertion."
        case 101...150: return "Sensitive groups may experience health effects. Limit outdoor activity."
        case 151...200: return "Everyone may experience health effects. Reduce outdoor exertion."
        case 201...300: return "Health alert. Everyone should avoid outdoor exertion."
        case 301...: return "Emergency conditions. Stay indoors."
        default: return "No recommendation available."
        }
    }

    var aqiNumericValue: Int {
        usAQI ?? 0
    }
}

// MARK: - Saved Location

struct SavedLocation: Codable, Identifiable, Hashable {
    var id: String { name + region }
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double

    init(name: String, region: String, country: String, latitude: Double, longitude: Double) {
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from locationInfo: LocationInfo) {
        self.name = locationInfo.name
        self.region = locationInfo.region
        self.country = locationInfo.country
        self.latitude = locationInfo.latitude
        self.longitude = locationInfo.longitude
    }
}

// MARK: - Search Result

struct SearchLocation: Codable, Identifiable, Hashable {
    var id: String { "\(name)-\(region)-\(country)" }
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
}
