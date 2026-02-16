import Foundation

struct APIConfig {
    let forecastBaseURL: String
    let geocodingBaseURL: String
    let airQualityBaseURL: String

    static func load() -> APIConfig {
        APIConfig(
            forecastBaseURL: "https://api.open-meteo.com/v1",
            geocodingBaseURL: "https://geocoding-api.open-meteo.com/v1",
            airQualityBaseURL: "https://air-quality-api.open-meteo.com/v1"
        )
    }
}
