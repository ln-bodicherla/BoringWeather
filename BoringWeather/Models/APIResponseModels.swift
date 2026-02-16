import Foundation

// MARK: - Open-Meteo Forecast Response

struct OpenMeteoForecastResponse: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let timezone_abbreviation: String
    let current: OpenMeteoCurrent?
    let hourly: OpenMeteoHourly?
    let daily: OpenMeteoDaily?
}

struct OpenMeteoCurrent: Codable {
    let time: String
    let temperature_2m: Double
    let relative_humidity_2m: Int
    let apparent_temperature: Double
    let is_day: Int
    let weather_code: Int
    let wind_speed_10m: Double
    let wind_direction_10m: Int
    let surface_pressure: Double
    let visibility: Double?       // in meters
    let uv_index: Double?
}

struct OpenMeteoHourly: Codable {
    let time: [String]
    let temperature_2m: [Double]
    let relative_humidity_2m: [Int]
    let apparent_temperature: [Double]
    let precipitation_probability: [Int]
    let weather_code: [Int]
    let wind_speed_10m: [Double]
    let is_day: [Int]
}

struct OpenMeteoDaily: Codable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let sunrise: [String]
    let sunset: [String]
    let uv_index_max: [Double]
    let precipitation_sum: [Double]
    let precipitation_probability_max: [Int]
    let wind_speed_10m_max: [Double]
}

// MARK: - Open-Meteo Air Quality Response

struct OpenMeteoAirQualityResponse: Codable {
    let current: OpenMeteoAQCurrent?
}

struct OpenMeteoAQCurrent: Codable {
    let us_aqi: Int?
    let pm10: Double?
    let pm2_5: Double?
    let carbon_monoxide: Double?
    let nitrogen_dioxide: Double?
    let sulphur_dioxide: Double?
    let ozone: Double?
}

// MARK: - Open-Meteo Geocoding Response

struct OpenMeteoGeocodingResponse: Codable {
    let results: [OpenMeteoGeoResult]?
}

struct OpenMeteoGeoResult: Codable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?     // state/region
    let timezone: String?
}

// MARK: - Unit Conversion Helpers

enum UnitConvert {
    static func celsiusToFahrenheit(_ c: Double) -> Double {
        c * 9.0 / 5.0 + 32.0
    }

    static func kphToMph(_ kph: Double) -> Double {
        kph * 0.621371
    }

    static func mbToInHg(_ mb: Double) -> Double {
        mb * 0.02953
    }

    static func metersToKm(_ m: Double) -> Double {
        m / 1000.0
    }

    static func metersToMiles(_ m: Double) -> Double {
        m / 1609.344
    }

    static func mmToInches(_ mm: Double) -> Double {
        mm / 25.4
    }

    static func degreesToCompass(_ deg: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((Double(deg) + 11.25) / 22.5) % 16
        return directions[index]
    }
}

// MARK: - WMO Weather Code Descriptions

enum WMOWeatherCode {
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Clear Sky"
        case 1: return "Mainly Clear"
        case 2: return "Partly Cloudy"
        case 3: return "Overcast"
        case 45: return "Fog"
        case 48: return "Rime Fog"
        case 51: return "Light Drizzle"
        case 53: return "Moderate Drizzle"
        case 55: return "Dense Drizzle"
        case 56: return "Light Freezing Drizzle"
        case 57: return "Dense Freezing Drizzle"
        case 61: return "Slight Rain"
        case 63: return "Moderate Rain"
        case 65: return "Heavy Rain"
        case 66: return "Light Freezing Rain"
        case 67: return "Heavy Freezing Rain"
        case 71: return "Slight Snow"
        case 73: return "Moderate Snow"
        case 75: return "Heavy Snow"
        case 77: return "Snow Grains"
        case 80: return "Slight Rain Showers"
        case 81: return "Moderate Rain Showers"
        case 82: return "Violent Rain Showers"
        case 85: return "Slight Snow Showers"
        case 86: return "Heavy Snow Showers"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with Slight Hail"
        case 99: return "Thunderstorm with Heavy Hail"
        default: return "Unknown"
        }
    }
}

// MARK: - Mapping to Domain Models

extension OpenMeteoForecastResponse {
    func toDomainModel(
        locationName: String,
        region: String,
        country: String,
        airQuality: OpenMeteoAirQualityResponse?
    ) -> WeatherData {
        let timeZoneID = timezone

        // Build LocationInfo
        let localtime: String = current?.time ?? ""
        let locationInfo = LocationInfo(
            name: locationName,
            region: region,
            country: country,
            latitude: latitude,
            longitude: longitude,
            timeZoneID: timeZoneID,
            localtime: localtime
        )

        // Build CurrentWeather
        let cur = current
        let tempC = cur?.temperature_2m ?? 0
        let feelsC = cur?.apparent_temperature ?? 0
        let windKph = cur?.wind_speed_10m ?? 0
        let windDeg = cur?.wind_direction_10m ?? 0
        let pressureMb = cur?.surface_pressure ?? 0
        let visMeters = cur?.visibility ?? 10000

        let currentWeather = CurrentWeather(
            tempC: tempC,
            tempF: UnitConvert.celsiusToFahrenheit(tempC),
            feelsLikeC: feelsC,
            feelsLikeF: UnitConvert.celsiusToFahrenheit(feelsC),
            conditionText: WMOWeatherCode.description(for: cur?.weather_code ?? 0),
            conditionCode: cur?.weather_code ?? 0,
            isDay: (cur?.is_day ?? 1) == 1,
            windMph: UnitConvert.kphToMph(windKph),
            windKph: windKph,
            windDegree: windDeg,
            windDirection: UnitConvert.degreesToCompass(windDeg),
            humidity: cur?.relative_humidity_2m ?? 0,
            pressureMb: pressureMb,
            pressureIn: UnitConvert.mbToInHg(pressureMb),
            visibilityKm: UnitConvert.metersToKm(visMeters),
            visibilityMiles: UnitConvert.metersToMiles(visMeters),
            uvIndex: cur?.uv_index ?? 0,
            airQuality: airQuality?.current?.toDomainModel()
        )

        // Build Forecast Days
        var forecastDays: [ForecastDay] = []

        if let d = daily, let h = hourly {
            let dayCount = d.time.count

            for i in 0..<dayCount {
                let dateStr = d.time[i]

                // Filter hourly data for this day
                let dayHours: [HourForecast] = h.time.enumerated().compactMap { (j, hourTime) in
                    guard hourTime.hasPrefix(dateStr), j < h.temperature_2m.count else { return nil }
                    let hTempC = h.temperature_2m[j]
                    let hFeelsC = j < h.apparent_temperature.count ? h.apparent_temperature[j] : hTempC
                    let hWindKph = j < h.wind_speed_10m.count ? h.wind_speed_10m[j] : 0
                    let hCode = j < h.weather_code.count ? h.weather_code[j] : 0
                    let hIsDay = j < h.is_day.count ? h.is_day[j] == 1 : true
                    let hRain = j < h.precipitation_probability.count ? h.precipitation_probability[j] : 0
                    let hHumidity = j < h.relative_humidity_2m.count ? h.relative_humidity_2m[j] : 0

                    return HourForecast(
                        time: hourTime,
                        tempC: hTempC,
                        tempF: UnitConvert.celsiusToFahrenheit(hTempC),
                        conditionText: WMOWeatherCode.description(for: hCode),
                        conditionCode: hCode,
                        isDay: hIsDay,
                        windMph: UnitConvert.kphToMph(hWindKph),
                        windKph: hWindKph,
                        chanceOfRain: hRain,
                        chanceOfSnow: 0,
                        humidity: hHumidity,
                        feelsLikeC: hFeelsC,
                        feelsLikeF: UnitConvert.celsiusToFahrenheit(hFeelsC)
                    )
                }

                let maxC = i < d.temperature_2m_max.count ? d.temperature_2m_max[i] : 0
                let minC = i < d.temperature_2m_min.count ? d.temperature_2m_min[i] : 0
                let avgC = (maxC + minC) / 2.0
                let precipMm = i < d.precipitation_sum.count ? d.precipitation_sum[i] : 0
                let precipProb = i < d.precipitation_probability_max.count ? d.precipitation_probability_max[i] : 0
                let maxWindKph = i < d.wind_speed_10m_max.count ? d.wind_speed_10m_max[i] : 0
                let dayCode = i < d.weather_code.count ? d.weather_code[i] : 0
                let uvMax = i < d.uv_index_max.count ? d.uv_index_max[i] : 0
                let sunriseISO = i < d.sunrise.count ? d.sunrise[i] : ""
                let sunsetISO = i < d.sunset.count ? d.sunset[i] : ""

                // Convert ISO sunrise/sunset to readable time
                let sunriseTime = formatISOTime(sunriseISO, timeZoneID: timeZoneID)
                let sunsetTime = formatISOTime(sunsetISO, timeZoneID: timeZoneID)

                let day = ForecastDay(
                    date: dateStr,
                    maxTempC: maxC,
                    maxTempF: UnitConvert.celsiusToFahrenheit(maxC),
                    minTempC: minC,
                    minTempF: UnitConvert.celsiusToFahrenheit(minC),
                    avgTempC: avgC,
                    avgTempF: UnitConvert.celsiusToFahrenheit(avgC),
                    maxWindMph: UnitConvert.kphToMph(maxWindKph),
                    maxWindKph: maxWindKph,
                    totalPrecipMm: precipMm,
                    totalPrecipIn: UnitConvert.mmToInches(precipMm),
                    avgHumidity: 0,
                    dailyChanceOfRain: precipProb,
                    dailyChanceOfSnow: 0,
                    conditionText: WMOWeatherCode.description(for: dayCode),
                    conditionCode: dayCode,
                    uvIndex: uvMax,
                    sunrise: sunriseTime,
                    sunset: sunsetTime,
                    hours: dayHours,
                    airQuality: nil
                )
                forecastDays.append(day)
            }
        }

        return WeatherData(
            location: locationInfo,
            current: currentWeather,
            forecast: Forecast(days: forecastDays),
            alerts: nil,
            airQuality: airQuality?.current?.toDomainModel()
        )
    }

    private func formatISOTime(_ isoString: String, timeZoneID: String) -> String {
        // Open-Meteo sunrise/sunset format: "2024-01-15T08:02"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        guard let date = formatter.date(from: isoString) else { return isoString }

        let output = DateFormatter()
        output.dateFormat = "h:mm a"
        output.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        return output.string(from: date)
    }
}

extension OpenMeteoAQCurrent {
    func toDomainModel() -> AirQualityInfo {
        AirQualityInfo(
            usAQI: us_aqi,
            pm2_5: pm2_5,
            pm10: pm10,
            o3: ozone,
            no2: nitrogen_dioxide,
            so2: sulphur_dioxide,
            co: carbon_monoxide
        )
    }
}

extension OpenMeteoGeoResult {
    func toDomainModel() -> SearchLocation {
        SearchLocation(
            name: name,
            region: admin1 ?? "",
            country: country ?? "",
            latitude: latitude,
            longitude: longitude
        )
    }
}
