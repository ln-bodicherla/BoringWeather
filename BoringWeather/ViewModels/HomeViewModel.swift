import SwiftUI
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOffline = false

    /// Tracks what is currently being viewed — nil means "use GPS current location"
    @Published private(set) var activeLocation: SavedLocation?
    private var hasLoadedOnce = false
    private var currentLoadTask: Task<Void, Never>?

    private let repository: WeatherRepository
    private let locationService: LocationService
    let unitsService: UnitsService

    init(repository: WeatherRepository, locationService: LocationService, unitsService: UnitsService) {
        self.repository = repository
        self.locationService = locationService
        self.unitsService = unitsService
    }

    var lastUpdatedText: String {
        guard let data = weatherData else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Updated \(formatter.localizedString(for: data.lastUpdated, relativeTo: Date()))"
    }

    // MARK: - Current Hours (next 24)

    var next24Hours: [HourForecast] {
        guard let data = weatherData else { return [] }
        let now = Date()
        let calendar = Calendar.current
        let timeZone = TimeZone(identifier: data.location.timeZoneID) ?? .current

        var allHours: [HourForecast] = []
        for day in data.forecast.days {
            allHours.append(contentsOf: day.hours)
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone

        let formats = ["yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm"]

        let filtered = allHours.filter { hour in
            var hourDate: Date?
            for fmt in formats {
                formatter.dateFormat = fmt
                if let d = formatter.date(from: hour.time) {
                    hourDate = d
                    break
                }
            }
            guard let parsed = hourDate else { return false }
            return parsed >= calendar.date(byAdding: .hour, value: -1, to: now) ?? now
        }

        return Array(filtered.prefix(24))
    }

    // MARK: - Forecast days

    var forecastDays: [ForecastDay] {
        guard let data = weatherData else { return [] }
        return Array(data.forecast.days)
    }

    // MARK: - Sunrise / Sunset from today

    var todaySunrise: String {
        guard let data = weatherData, let today = data.forecast.days.first else { return "--" }
        return unitsService.formatTime(today.sunrise, timeZoneID: data.location.timeZoneID)
    }

    var todaySunset: String {
        guard let data = weatherData, let today = data.forecast.days.first else { return "--" }
        return unitsService.formatTime(today.sunset, timeZoneID: data.location.timeZoneID)
    }

    // MARK: - Initial Load (called once by .task)

    func loadIfNeeded() async {
        guard !hasLoadedOnce else { return }
        hasLoadedOnce = true
        await loadCurrentLocation()
    }

    // MARK: - Load Current GPS Location

    func loadCurrentLocation() async {
        // Cancel any in-progress load
        currentLoadTask?.cancel()
        activeLocation = nil
        isLoading = true
        errorMessage = nil

        let task = Task { @MainActor in
            do {
                if locationService.isAuthorized {
                    let coord = try await locationService.requestCurrentLocation()
                    guard !Task.isCancelled else { return }
                    let data = try await repository.fetchWeather(
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                    guard !Task.isCancelled else { return }
                    self.weatherData = data
                    self.isOffline = false
                } else {
                    locationService.requestPermission()
                    if let cached = await repository.loadCachedWeather(for: "currentLocation") {
                        guard !Task.isCancelled else { return }
                        self.weatherData = cached
                        self.isOffline = true
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = error.localizedDescription
                if let cached = await repository.loadCachedWeather(for: "currentLocation") {
                    guard !Task.isCancelled else { return }
                    self.weatherData = cached
                    self.isOffline = true
                }
            }

            self.isLoading = false
        }
        currentLoadTask = task
        await task.value
    }

    // MARK: - Load Saved Location

    func loadWeather(for location: SavedLocation) async {
        // Cancel any in-progress load (e.g. GPS load)
        currentLoadTask?.cancel()
        activeLocation = location
        isLoading = true
        errorMessage = nil

        let task = Task { @MainActor in
            do {
                let data = try await repository.fetchWeather(for: location)
                guard !Task.isCancelled else { return }
                self.weatherData = data
                self.isOffline = false
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = error.localizedDescription
                let key = "\(location.latitude)_\(location.longitude)"
                if let cached = await repository.loadCachedWeather(for: key) {
                    guard !Task.isCancelled else { return }
                    self.weatherData = cached
                    self.isOffline = true
                }
            }

            self.isLoading = false
        }
        currentLoadTask = task
        await task.value
    }

    // MARK: - Refresh (reloads whatever is currently active)

    func refresh() async {
        if let location = activeLocation {
            await loadWeather(for: location)
        } else {
            await loadCurrentLocation()
        }
    }
}
