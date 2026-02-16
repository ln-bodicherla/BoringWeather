import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var unitsService: UnitsService
    var cloudBackupService: CloudBackupService?

    init(unitsService: UnitsService) {
        self.unitsService = unitsService
    }

    var temperatureUnit: TemperatureUnit {
        get { unitsService.temperatureUnit }
        set {
            unitsService.temperatureUnit = newValue
            objectWillChange.send()
            backupSettings()
        }
    }

    var speedUnit: SpeedUnit {
        get { unitsService.speedUnit }
        set {
            unitsService.speedUnit = newValue
            objectWillChange.send()
            backupSettings()
        }
    }

    var pressureUnit: PressureUnit {
        get { unitsService.pressureUnit }
        set {
            unitsService.pressureUnit = newValue
            objectWillChange.send()
            backupSettings()
        }
    }

    var distanceUnit: DistanceUnit {
        get { unitsService.distanceUnit }
        set {
            unitsService.distanceUnit = newValue
            objectWillChange.send()
            backupSettings()
        }
    }

    var timeFormat: TimeFormat {
        get { unitsService.timeFormat }
        set {
            unitsService.timeFormat = newValue
            objectWillChange.send()
            backupSettings()
        }
    }

    var appTheme: String {
        get { unitsService.appTheme }
        set {
            unitsService.appTheme = newValue
            objectWillChange.send()
            backupSettings()
        }
    }

    var iCloudBackupEnabled: Bool {
        get { cloudBackupService?.isEnabled ?? false }
        set {
            cloudBackupService?.isEnabled = newValue
            objectWillChange.send()
            if newValue { backupSettings() }
        }
    }

    func setMetric() {
        temperatureUnit = .celsius
        speedUnit = .kph
        pressureUnit = .mb
        distanceUnit = .km
    }

    func setImperial() {
        temperatureUnit = .fahrenheit
        speedUnit = .mph
        pressureUnit = .inHg
        distanceUnit = .miles
    }

    private func backupSettings() {
        cloudBackupService?.backupSettings(from: unitsService)
    }
}
