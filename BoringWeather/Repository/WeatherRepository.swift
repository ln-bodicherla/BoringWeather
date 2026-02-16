import Foundation

final class WeatherRepository: ObservableObject {
    private let apiService: WeatherAPIService
    private let cacheService: CacheService

    init(apiService: WeatherAPIService, cacheService: CacheService) {
        self.apiService = apiService
        self.cacheService = cacheService
    }

    // MARK: - Fetch Weather

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let cacheKey = "\(latitude)_\(longitude)"
        do {
            let data = try await apiService.fetchWeather(latitude: latitude, longitude: longitude)
            await cacheService.cacheWeather(data, for: cacheKey)
            return data
        } catch {
            if let cached = await cacheService.loadCachedWeather(for: cacheKey) {
                return cached
            }
            throw error
        }
    }

    func fetchWeather(for location: SavedLocation) async throws -> WeatherData {
        let cacheKey = "\(location.latitude)_\(location.longitude)"
        do {
            let data = try await apiService.fetchWeather(
                latitude: location.latitude,
                longitude: location.longitude,
                name: location.name,
                region: location.region,
                country: location.country
            )
            await cacheService.cacheWeather(data, for: cacheKey)
            return data
        } catch {
            if let cached = await cacheService.loadCachedWeather(for: cacheKey) {
                return cached
            }
            throw error
        }
    }

    // MARK: - Cached Data

    func loadCachedWeather(for key: String) async -> WeatherData? {
        await cacheService.loadCachedWeather(for: key)
    }

    // MARK: - Saved Locations

    func saveFavoriteLocations(_ locations: [SavedLocation]) async {
        await cacheService.saveFavoriteLocations(locations)
    }

    func loadFavoriteLocations() async -> [SavedLocation] {
        await cacheService.loadFavoriteLocations()
    }

    // MARK: - Search

    func searchLocations(query: String) async throws -> [SearchLocation] {
        try await apiService.searchLocations(query: query)
    }

    // MARK: - Clear

    func clearCache() async {
        await cacheService.clearAll()
    }
}
