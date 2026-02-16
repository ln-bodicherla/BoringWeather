import SwiftUI

struct AlertsView: View {
    @ObservedObject var viewModel: AlertsViewModel
    @EnvironmentObject var container: DIContainer
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "Alerts")

            ScrollView {
                LazyVStack(spacing: RetroTheme.itemSpacing) {
                    if viewModel.alerts.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.alerts) { alert in
                            alertCard(alert)
                        }
                    }
                }
                .padding()
            }
        }
        .background(colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight)
        .onChange(of: container.homeViewModel.weatherData?.id) { _, _ in
            viewModel.loadAlerts(from: container.homeViewModel.weatherData)
        }
        .onAppear {
            viewModel.loadAlerts(from: container.homeViewModel.weatherData)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 40))
                .foregroundStyle(RetroTheme.accentColor.opacity(0.5))

            Text("NO ACTIVE ALERTS")
                .font(RetroTheme.headlineFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))

            Text("Open-Meteo does not provide weather alerts.\nCheck your local weather service for warnings.")
                .font(RetroTheme.bodyFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }

    // MARK: - Alert Card

    private func alertCard(_ alert: WeatherAlert) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.severityIcon(alert.severity))
                    .foregroundStyle(viewModel.severityColor(alert.severity))

                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.event.isEmpty ? alert.headline : alert.event)
                        .font(RetroTheme.mono(13, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .textCase(.uppercase)

                    Text("Severity: \(alert.severity)")
                        .font(RetroTheme.captionFont)
                        .foregroundStyle(viewModel.severityColor(alert.severity))
                        .textCase(.uppercase)
                }

                Spacer()
            }

            RetroDivider()

            if !alert.effective.isEmpty {
                HStack {
                    Text("From:")
                        .font(RetroTheme.captionFont)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                    Text(alert.effective)
                        .font(RetroTheme.captionFont)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                }
            }
            if !alert.expires.isEmpty {
                HStack {
                    Text("Until:")
                        .font(RetroTheme.captionFont)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                    Text(alert.expires)
                        .font(RetroTheme.captionFont)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                }
            }

            if !alert.description.isEmpty {
                RetroDivider()
                Text(alert.description)
                    .font(RetroTheme.captionFont)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
                    .lineLimit(6)
            }
        }
        .retroCard()
    }
}
