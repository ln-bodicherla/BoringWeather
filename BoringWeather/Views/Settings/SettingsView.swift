import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var sectionAppear: [Bool] = Array(repeating: false, count: 7)

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "Settings")

            ScrollView {
                VStack(spacing: RetroTheme.sectionSpacing) {
                    settingsSection(title: "Presets", index: 0) {
                        VStack(spacing: 0) {
                            presetRow(
                                label: "Metric",
                                detail: "°C, km/h, km",
                                icon: "globe.europe.africa.fill",
                                color: RetroTheme.accentColor,
                                isSelected: viewModel.temperatureUnit == .celsius
                            ) { viewModel.setMetric() }

                            RetroDivider()

                            presetRow(
                                label: "Imperial",
                                detail: "°F, mph, mi",
                                icon: "globe.americas.fill",
                                color: RetroTheme.accentPurple,
                                isSelected: viewModel.temperatureUnit == .fahrenheit
                            ) { viewModel.setImperial() }
                        }
                    }

                    settingsSection(title: "Temperature", index: 1) {
                        liquidSegmentPicker(
                            selection: Binding(
                                get: { viewModel.temperatureUnit },
                                set: { viewModel.temperatureUnit = $0 }
                            ),
                            options: TemperatureUnit.allCases,
                            label: { "°\($0.rawValue)" }
                        )
                    }

                    settingsSection(title: "Units", index: 2) {
                        VStack(spacing: 18) {
                            unitRow(title: "Wind Speed") {
                                liquidSegmentPicker(
                                    selection: Binding(
                                        get: { viewModel.speedUnit },
                                        set: { viewModel.speedUnit = $0 }
                                    ),
                                    options: SpeedUnit.allCases,
                                    label: { $0.rawValue }
                                )
                            }
                            unitRow(title: "Distance") {
                                liquidSegmentPicker(
                                    selection: Binding(
                                        get: { viewModel.distanceUnit },
                                        set: { viewModel.distanceUnit = $0 }
                                    ),
                                    options: DistanceUnit.allCases,
                                    label: { $0.rawValue }
                                )
                            }
                            unitRow(title: "Pressure") {
                                liquidSegmentPicker(
                                    selection: Binding(
                                        get: { viewModel.pressureUnit },
                                        set: { viewModel.pressureUnit = $0 }
                                    ),
                                    options: PressureUnit.allCases,
                                    label: { $0.rawValue }
                                )
                            }
                        }
                    }

                    settingsSection(title: "Time Format", index: 3) {
                        liquidSegmentPicker(
                            selection: Binding(
                                get: { viewModel.timeFormat },
                                set: { viewModel.timeFormat = $0 }
                            ),
                            options: TimeFormat.allCases,
                            label: { $0.rawValue }
                        )
                    }

                    settingsSection(title: "Sync", index: 4) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [RetroTheme.accentPurple.opacity(0.15), RetroTheme.accentColor.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(RetroTheme.accentPurple.opacity(0.2), lineWidth: 0.5)
                                    )
                                Image(systemName: "icloud.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(RetroTheme.accentPurple)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("iCloud Sync")
                                    .font(RetroTheme.mono(14, weight: .semibold))
                                    .foregroundStyle(RetroTheme.textPrimary)
                                Text("Auto-sync locations & settings")
                                    .font(RetroTheme.mono(11))
                                    .foregroundStyle(RetroTheme.textTertiary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { viewModel.iCloudBackupEnabled },
                                set: { viewModel.iCloudBackupEnabled = $0 }
                            ))
                            .tint(RetroTheme.accentColor)
                            .labelsHidden()
                        }
                    }

                    settingsSection(title: "About", index: 5) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                // App icon glass badge
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [RetroTheme.accentColor.opacity(0.15), RetroTheme.accentPurple.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                        )
                                    Image(systemName: "cloud.sun.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(RetroTheme.accentColor)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("BoringWeather")
                                        .font(RetroTheme.mono(15, weight: .bold))
                                        .foregroundStyle(RetroTheme.textPrimary)
                                    Text("v1.0")
                                        .font(RetroTheme.mono(11))
                                        .foregroundStyle(RetroTheme.accentColor)
                                }
                            }

                            Text("A futuristic weather experience powered by real-time atmospheric data and liquid glass design.")
                                .font(RetroTheme.mono(12))
                                .foregroundStyle(RetroTheme.textSecondary)
                                .lineSpacing(3)

                            HStack(spacing: 4) {
                                Image(systemName: "server.rack")
                                    .font(.system(size: 10))
                                Text("Data: Open-Meteo.com")
                                    .font(RetroTheme.mono(11))
                            }
                            .foregroundStyle(RetroTheme.textTertiary)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(
            ZStack {
                RetroTheme.bgDark
                // Ambient blobs
                LiquidBlob(phase: 1.5)
                    .fill(RetroTheme.accentPurple.opacity(0.06))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: -80, y: 100)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        )
        .onAppear {
            for i in 0..<sectionAppear.count {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(i) * 0.08)) {
                    sectionAppear[i] = true
                }
            }
        }
    }

    // MARK: - Settings Section

    private func settingsSection<Content: View>(title: String, index: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RetroSectionHeader(title: title)
            content()
                .retroCard()
        }
        .offset(y: sectionAppear[min(index, sectionAppear.count - 1)] ? 0 : 20)
        .opacity(sectionAppear[min(index, sectionAppear.count - 1)] ? 1 : 0)
    }

    // MARK: - Unit Row

    private func unitRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(RetroTheme.mono(10, weight: .bold))
                .foregroundStyle(RetroTheme.textTertiary)
                .textCase(.uppercase)
                .tracking(1)
            content()
        }
    }

    // MARK: - Preset Row

    private func presetRow(label: String, detail: String, icon: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient(colors: [color.opacity(0.2), color.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.white.opacity(0.04), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? color.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 0.5)
                        )
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(isSelected ? color : RetroTheme.textTertiary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(RetroTheme.mono(14, weight: .semibold))
                        .foregroundStyle(RetroTheme.textPrimary)
                    Text(detail)
                        .font(RetroTheme.mono(11))
                        .foregroundStyle(RetroTheme.textTertiary)
                }
                Spacer()
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(color)
                    }
                    .liquidGlow(color: color)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Liquid Segment Picker

    private func liquidSegmentPicker<T: Hashable>(
        selection: Binding<T>,
        options: [T],
        label: @escaping (T) -> String
    ) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let isSelected = selection.wrappedValue == option

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        selection.wrappedValue = option
                    }
                } label: {
                    Text(label(option))
                        .font(RetroTheme.mono(13, weight: isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? .white : RetroTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if isSelected {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [RetroTheme.accentColor, RetroTheme.accentPurple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: RetroTheme.accentColor.opacity(0.4), radius: 8)
                                        .shadow(color: RetroTheme.accentPurple.opacity(0.2), radius: 16)
                                } else {
                                    Capsule()
                                        .fill(Color.clear)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .opacity(0.4)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}
