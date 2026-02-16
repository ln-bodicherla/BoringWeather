import SwiftUI

@MainActor
final class AlertsViewModel: ObservableObject {
    @Published var alerts: [WeatherAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: WeatherRepository

    init(repository: WeatherRepository) {
        self.repository = repository
    }

    func loadAlerts(from weatherData: WeatherData?) {
        guard let data = weatherData else {
            alerts = []
            return
        }
        alerts = data.alerts?.alerts ?? []
    }

    var activeAlerts: [WeatherAlert] {
        alerts.filter { alert in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let expires = formatter.date(from: alert.expires) {
                return expires > Date()
            }
            return true // Show if we can't parse
        }
    }

    func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "extreme":
            return .red
        case "severe":
            return Color(red: 0.9, green: 0.4, blue: 0.1)
        case "moderate":
            return Color(red: 0.85, green: 0.65, blue: 0.2)
        case "minor":
            return Color(red: 0.6, green: 0.6, blue: 0.2)
        default:
            return .gray
        }
    }

    func severityIcon(_ severity: String) -> String {
        switch severity.lowercased() {
        case "extreme":
            return "exclamationmark.octagon.fill"
        case "severe":
            return "exclamationmark.triangle.fill"
        case "moderate":
            return "exclamationmark.circle.fill"
        default:
            return "info.circle.fill"
        }
    }
}
