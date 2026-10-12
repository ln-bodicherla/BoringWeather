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
        .background(
            ZStack {
                RetroTheme.bgDark
                LiquidBlob(phase: 2)
                    .fill(RetroTheme.accentMint.opacity(0.04))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(y: -100)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        )
        .onChange(of: container.homeViewModel.weatherData?.id) { _, _ in
            viewModel.loadAlerts(from: container.homeViewModel.weatherData)
        }
        .onAppear {
            viewModel.loadAlerts(from: container.homeViewModel.weatherData)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                // Animated rings
                BreathingRing(color: RetroTheme.accentMint.opacity(0.2), size: 100)
                BreathingRing(color: RetroTheme.accentMint.opacity(0.15), size: 70)

                // Glass circle
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(RetroTheme.accentMint.opacity(0.2), lineWidth: 0.5)
                        )

                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(RetroTheme.accentMint)
                        .liquidGlow(color: RetroTheme.accentMint)
                }
            }
            .frame(height: 110)

            Text("All Clear")
                .font(RetroTheme.mono(20, weight: .bold))
                .foregroundStyle(RetroTheme.textPrimary)
                .tracking(2)

            Text("No active weather alerts.\nCheck your local weather service\nfor warnings.")
                .font(RetroTheme.mono(12))
                .foregroundStyle(RetroTheme.textTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.top, 80)
    }

    // MARK: - Alert Card

    private func alertCard(_ alert: WeatherAlert) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Severity icon with glass circle
                ZStack {
                    Circle()
                        .fill(viewModel.severityColor(alert.severity).opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(viewModel.severityColor(alert.severity).opacity(0.2), lineWidth: 0.5)
                        )
                    Image(systemName: viewModel.severityIcon(alert.severity))
                        .font(.system(size: 15))
                        .foregroundStyle(viewModel.severityColor(alert.severity))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(alert.event.isEmpty ? alert.headline : alert.event)
                        .font(RetroTheme.mono(14, weight: .bold))
                        .foregroundStyle(RetroTheme.textPrimary)
                    Text(alert.severity.uppercased())
                        .font(RetroTheme.mono(10, weight: .bold))
                        .foregroundStyle(viewModel.severityColor(alert.severity))
                        .tracking(2)
                }
                Spacer()
            }

            RetroDivider()

            if !alert.effective.isEmpty {
                HStack(spacing: 6) {
                    Text("From")
                        .font(RetroTheme.mono(10, weight: .bold))
                        .foregroundStyle(RetroTheme.textTertiary)
                    Text(alert.effective)
                        .font(RetroTheme.mono(11))
                        .foregroundStyle(RetroTheme.textSecondary)
                }
            }
            if !alert.expires.isEmpty {
                HStack(spacing: 6) {
                    Text("Until")
                        .font(RetroTheme.mono(10, weight: .bold))
                        .foregroundStyle(RetroTheme.textTertiary)
                    Text(alert.expires)
                        .font(RetroTheme.mono(11))
                        .foregroundStyle(RetroTheme.textSecondary)
                }
            }

            if !alert.description.isEmpty {
                RetroDivider()
                Text(alert.description)
                    .font(RetroTheme.mono(11))
                    .foregroundStyle(RetroTheme.textTertiary)
                    .lineSpacing(3)
                    .lineLimit(6)
            }
        }
        .retroCard()
        .overlay(
            RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            viewModel.severityColor(alert.severity).opacity(0.3),
                            viewModel.severityColor(alert.severity).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
}
