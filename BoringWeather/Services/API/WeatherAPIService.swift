import Foundation
import CoreLocation

enum WeatherAPIError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .invalidResponse(let code):
            return "Server returned error code \(code)."
        case .decodingError(let error):
            return "Failed to parse weather data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noData:
            return "No weather data returned."
        }
    }
}

actor WeatherAPIService {
    private let config: APIConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    init(config: APIConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Fetch Weather by Coordinates

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        // Use Apple CLGeocoder for reliable reverse geocoding
        let placemark = await reverseGeocodeApple(latitude: latitude, longitude: longitude)
        let cityName = placemark?.locality ?? placemark?.name ?? "Current Location"
        let region = placemark?.administrativeArea ?? ""
        let country = placemark?.country ?? ""

        // Fetch forecast
        let forecast = try await fetchForecast(latitude: latitude, longitude: longitude)

        // Fetch air quality
        let airQuality = try? await fetchAirQuality(latitude: latitude, longitude: longitude)

        return forecast.toDomainModel(
            locationName: cityName,
            region: region,
            country: country,
            airQuality: airQuality
        )
    }

    // MARK: - Fetch Weather for a Named Location (uses stored coordinates)

    func fetchWeather(latitude: Double, longitude: Double,
                      name: String, region: String, country: String) async throws -> WeatherData {
        let forecast = try await fetchForecast(latitude: latitude, longitude: longitude)
        let airQuality = try? await fetchAirQuality(latitude: latitude, longitude: longitude)

        return forecast.toDomainModel(
            locationName: name,
            region: region,
            country: country,
            airQuality: airQuality
        )
    }

    // MARK: - Search Locations

    func searchLocations(query: String) async throws -> [SearchLocation] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        var components = URLComponents(string: "\(config.geocodingBaseURL)/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else { throw WeatherAPIError.invalidURL }

        let response: OpenMeteoGeocodingResponse = try await request(url: url)
        return response.results?.map { $0.toDomainModel() } ?? []
    }

    // MARK: - Private: Forecast

    private func fetchForecast(latitude: Double, longitude: Double) async throws -> OpenMeteoForecastResponse {
        var components = URLComponents(string: "\(config.forecastBaseURL)/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,visibility,uv_index"),
            URLQueryItem(name: "hourly", value: "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m,is_day"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "10")
        ]

        guard let url = components?.url else { throw WeatherAPIError.invalidURL }
        return try await request(url: url)
    }

    // MARK: - Private: Air Quality

    private func fetchAirQuality(latitude: Double, longitude: Double) async throws -> OpenMeteoAirQualityResponse {
        var components = URLComponents(string: "\(config.airQualityBaseURL)/air-quality")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone")
        ]

        guard let url = components?.url else { throw WeatherAPIError.invalidURL }
        return try await request(url: url)
    }

    // MARK: - Private: Reverse Geocode (Apple CLGeocoder)

    private func reverseGeocodeApple(latitude: Double, longitude: Double) async -> CLPlacemark? {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first
        } catch {
            return nil
        }
    }

    // MARK: - Private: Generic Request

    private func request<T: Decodable>(url: URL) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.invalidResponse(statusCode: 0)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAPIError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw WeatherAPIError.decodingError(error)
        }
    }
}
