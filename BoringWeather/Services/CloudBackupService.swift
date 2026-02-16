import Foundation

final class CloudBackupService: ObservableObject {
    private let store = NSUbiquitousKeyValueStore.default

    // iCloud keys
    private enum Key {
        static let savedLocations = "backup_savedLocations"
        static let temperatureUnit = "backup_temperatureUnit"
        static let speedUnit = "backup_speedUnit"
        static let distanceUnit = "backup_distanceUnit"
        static let pressureUnit = "backup_pressureUnit"
        static let timeFormat = "backup_timeFormat"
        static let appTheme = "backup_appTheme"
    }

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "icloudBackupEnabled")
        }
    }

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "icloudBackupEnabled")
    }

    func start() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        store.synchronize()
    }

    // MARK: - Save to iCloud

    func backupLocations(_ locations: [SavedLocation]) {
        guard isEnabled else { return }
        if let data = try? JSONEncoder().encode(locations) {
            store.set(data, forKey: Key.savedLocations)
            store.synchronize()
        }
    }

    func backupSettings(from units: UnitsService) {
        guard isEnabled else { return }
        store.set(units.temperatureUnit.rawValue, forKey: Key.temperatureUnit)
        store.set(units.speedUnit.rawValue, forKey: Key.speedUnit)
        store.set(units.distanceUnit.rawValue, forKey: Key.distanceUnit)
        store.set(units.pressureUnit.rawValue, forKey: Key.pressureUnit)
        store.set(units.timeFormat.rawValue, forKey: Key.timeFormat)
        store.set(units.appTheme, forKey: Key.appTheme)
        store.synchronize()
    }

    // MARK: - Restore from iCloud

    func restoreLocations() -> [SavedLocation]? {
        guard let data = store.data(forKey: Key.savedLocations) else { return nil }
        return try? JSONDecoder().decode([SavedLocation].self, from: data)
    }

    func restoreSettings(to units: UnitsService) {
        if let raw = store.string(forKey: Key.temperatureUnit),
           let val = TemperatureUnit(rawValue: raw) {
            units.temperatureUnit = val
        }
        if let raw = store.string(forKey: Key.speedUnit),
           let val = SpeedUnit(rawValue: raw) {
            units.speedUnit = val
        }
        if let raw = store.string(forKey: Key.distanceUnit),
           let val = DistanceUnit(rawValue: raw) {
            units.distanceUnit = val
        }
        if let raw = store.string(forKey: Key.pressureUnit),
           let val = PressureUnit(rawValue: raw) {
            units.pressureUnit = val
        }
        if let raw = store.string(forKey: Key.timeFormat),
           let val = TimeFormat(rawValue: raw) {
            units.timeFormat = val
        }
        if let theme = store.string(forKey: Key.appTheme), !theme.isEmpty {
            units.appTheme = theme
        }
    }

    /// Run on first launch or when backup is enabled — restores iCloud data if local is empty
    func restoreIfNeeded(cacheService: CacheService, unitsService: UnitsService) async {
        guard isEnabled else { return }

        // Restore locations if local list is empty
        let localLocations = await cacheService.loadFavoriteLocations()
        if localLocations.isEmpty, let cloudLocations = restoreLocations(), !cloudLocations.isEmpty {
            await cacheService.saveFavoriteLocations(cloudLocations)
        }

        // Restore settings (iCloud overwrites local on fresh install)
        restoreSettings(to: unitsService)
    }

    @objc private func storeDidChange(_ notification: Notification) {
        // iCloud data changed externally — could add merge logic here if needed
    }
}
