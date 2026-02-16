import Foundation

actor CacheService {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("BoringWeather", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Weather Cache

    func cacheWeather(_ data: WeatherData, for key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("weather_\(key.sanitizedFileName).json")
        do {
            let encoded = try encoder.encode(data)
            try encoded.write(to: fileURL, options: .atomic)
        } catch {
            print("[Cache] Failed to write weather cache: \(error)")
        }
    }

    func loadCachedWeather(for key: String) -> WeatherData? {
        let fileURL = cacheDirectory.appendingPathComponent("weather_\(key.sanitizedFileName).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(WeatherData.self, from: data)
        } catch {
            print("[Cache] Failed to read weather cache: \(error)")
            return nil
        }
    }

    // MARK: - Saved Locations

    func saveFavoriteLocations(_ locations: [SavedLocation]) {
        let fileURL = cacheDirectory.appendingPathComponent("saved_locations.json")
        do {
            let encoded = try encoder.encode(locations)
            try encoded.write(to: fileURL, options: .atomic)
        } catch {
            print("[Cache] Failed to save locations: \(error)")
        }
    }

    func loadFavoriteLocations() -> [SavedLocation] {
        let fileURL = cacheDirectory.appendingPathComponent("saved_locations.json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([SavedLocation].self, from: data)
        } catch {
            print("[Cache] Failed to load locations: \(error)")
            return []
        }
    }

    // MARK: - Clear

    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
    }
}

extension String {
    var sanitizedFileName: String {
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-_"))
        return unicodeScalars
            .filter { allowed.contains($0) }
            .map { String($0) }
            .joined()
    }
}
