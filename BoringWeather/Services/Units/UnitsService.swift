import Foundation
import SwiftUI

enum TemperatureUnit: String, CaseIterable {
    case celsius = "C"
    case fahrenheit = "F"
}

enum SpeedUnit: String, CaseIterable {
    case kph = "km/h"
    case mph = "mph"
}

enum PressureUnit: String, CaseIterable {
    case mb = "mb"
    case inHg = "inHg"
}

enum DistanceUnit: String, CaseIterable {
    case km = "km"
    case miles = "mi"
}

enum TimeFormat: String, CaseIterable {
    case twelve = "12h"
    case twentyFour = "24h"
}

final class UnitsService: ObservableObject {
    @AppStorage("temperatureUnit") var temperatureUnit: TemperatureUnit = .fahrenheit
    @AppStorage("speedUnit") var speedUnit: SpeedUnit = .mph
    @AppStorage("pressureUnit") var pressureUnit: PressureUnit = .inHg
    @AppStorage("distanceUnit") var distanceUnit: DistanceUnit = .miles
    @AppStorage("timeFormat") var timeFormat: TimeFormat = .twelve
    @AppStorage("appTheme") var appTheme: String = "system"

    // MARK: - Temperature

    func temperature(celsius: Double, fahrenheit: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return "\(Int(round(celsius)))°"
        case .fahrenheit:
            return "\(Int(round(fahrenheit)))°"
        }
    }

    func temperatureValue(celsius: Double, fahrenheit: Double) -> Int {
        switch temperatureUnit {
        case .celsius: return Int(round(celsius))
        case .fahrenheit: return Int(round(fahrenheit))
        }
    }

    // MARK: - Wind

    func windSpeed(kph: Double, mph: Double) -> String {
        switch speedUnit {
        case .kph: return "\(Int(round(kph))) km/h"
        case .mph: return "\(Int(round(mph))) mph"
        }
    }

    // MARK: - Pressure

    func pressure(mb: Double, inHg: Double) -> String {
        switch pressureUnit {
        case .mb: return "\(Int(round(mb))) mb"
        case .inHg: return String(format: "%.2f inHg", inHg)
        }
    }

    // MARK: - Visibility

    func visibility(km: Double, miles: Double) -> String {
        switch distanceUnit {
        case .km: return String(format: "%.1f km", km)
        case .miles: return String(format: "%.1f mi", miles)
        }
    }

    // MARK: - Precipitation

    func precipitation(mm: Double, inches: Double) -> String {
        switch distanceUnit {
        case .km: return String(format: "%.1f mm", mm)
        case .miles: return String(format: "%.2f in", inches)
        }
    }

    // MARK: - Time Formatting

    func formatTime(_ timeString: String, timeZoneID: String) -> String {
        let formats = ["yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm", "hh:mm a", "h:mm a", "HH:mm"]
        var date: Date?

        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let d = formatter.date(from: timeString) {
                date = d
                break
            }
        }

        guard let parsedDate = date else { return timeString }

        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        switch timeFormat {
        case .twelve:
            outputFormatter.dateFormat = "h:mm a"
        case .twentyFour:
            outputFormatter.dateFormat = "HH:mm"
        }
        return outputFormatter.string(from: parsedDate)
    }

    func formatHour(_ timeString: String, timeZoneID: String) -> String {
        let formats = ["yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm"]
        var date: Date?
        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let d = formatter.date(from: timeString) {
                date = d
                break
            }
        }
        guard let date else { return timeString }

        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        switch timeFormat {
        case .twelve:
            outputFormatter.dateFormat = "ha"
        case .twentyFour:
            outputFormatter.dateFormat = "HH:mm"
        }
        return outputFormatter.string(from: date).lowercased()
    }

    func formatDayOfWeek(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: dateString) else { return dateString }

        let isToday = Calendar.current.isDateInToday(date)
        if isToday { return "Today" }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE"
        return outputFormatter.string(from: date)
    }

    func formatFullDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: dateString) else { return dateString }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE, MMM d"
        return outputFormatter.string(from: date)
    }
}

