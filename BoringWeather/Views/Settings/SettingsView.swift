import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "Settings")

            ScrollView {
                VStack(spacing: RetroTheme.sectionSpacing) {
                    // Unit Presets
                    settingsSection(title: "Unit Presets") {
                        VStack(spacing: 0) {
                            presetRow(
                                label: "Metric (°C, km/h, km)",
                                isSelected: viewModel.temperatureUnit == .celsius
                            ) {
                                viewModel.setMetric()
                            }

                            RetroDivider()

                            presetRow(
                                label: "Imperial (°F, mph, mi)",
                                isSelected: viewModel.temperatureUnit == .fahrenheit
                            ) {
                                viewModel.setImperial()
                            }
                        }
                    }

                    // Temperature
                    settingsSection(title: "Temperature") {
                        retroSegmentPicker(
                            selection: Binding(
                                get: { viewModel.temperatureUnit },
                                set: { viewModel.temperatureUnit = $0 }
                            ),
                            options: TemperatureUnit.allCases,
                            label: { "°\($0.rawValue)" }
                        )
                    }

                    // Units
                    settingsSection(title: "Units") {
                        VStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Wind Speed")
                                    .font(RetroTheme.captionFont)
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                                    .textCase(.uppercase)
                                retroSegmentPicker(
                                    selection: Binding(
                                        get: { viewModel.speedUnit },
                                        set: { viewModel.speedUnit = $0 }
                                    ),
                                    options: SpeedUnit.allCases,
                                    label: { $0.rawValue }
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Distance")
                                    .font(RetroTheme.captionFont)
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                                    .textCase(.uppercase)
                                retroSegmentPicker(
                                    selection: Binding(
                                        get: { viewModel.distanceUnit },
                                        set: { viewModel.distanceUnit = $0 }
                                    ),
                                    options: DistanceUnit.allCases,
                                    label: { $0.rawValue }
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Pressure")
                                    .font(RetroTheme.captionFont)
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                                    .textCase(.uppercase)
                                retroSegmentPicker(
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

                    // Time
                    settingsSection(title: "Time") {
                        retroSegmentPicker(
                            selection: Binding(
                                get: { viewModel.timeFormat },
                                set: { viewModel.timeFormat = $0 }
                            ),
                            options: TimeFormat.allCases,
                            label: { $0.rawValue }
                        )
                    }

                    // Appearance
                    settingsSection(title: "Appearance") {
                        retroSegmentPicker(
                            selection: Binding(
                                get: { viewModel.appTheme },
                                set: { viewModel.appTheme = $0 }
                            ),
                            options: ["system", "light", "dark"],
                            label: { $0.capitalized }
                        )
                    }

                    // iCloud Backup
                    settingsSection(title: "Backup") {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("iCloud Backup")
                                    .font(RetroTheme.bodyFont)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                Text("Auto-sync locations & settings")
                                    .font(RetroTheme.captionFont)
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
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

                    // About
                    settingsSection(title: "About") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BoringWeather v1.0")
                                .font(RetroTheme.mono(13, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            Text("A deliberately boring, retro-styled weather app. No flashy animations. No trendy gradients. Just weather.")
                                .font(RetroTheme.captionFont)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                            Text("Data: Open-Meteo.com")
                                .font(RetroTheme.captionFont)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                        }
                    }
                }
                .padding()
            }
        }
        .background(colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight)
    }

    // MARK: - Settings Section

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RetroSectionHeader(title: title)
            content()
                .retroCard()
        }
    }

    // MARK: - Preset Row

    private func presetRow(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(RetroTheme.bodyFont)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(RetroTheme.accentColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Retro Segment Picker

    private func retroSegmentPicker<T: Hashable>(
        selection: Binding<T>,
        options: [T],
        label: @escaping (T) -> String
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection.wrappedValue = option
                    }
                } label: {
                    Text(label(option))
                        .font(RetroTheme.mono(13, weight: selection.wrappedValue == option ? .bold : .regular))
                        .foregroundStyle(
                            selection.wrappedValue == option
                                ? RetroTheme.accentColor
                                : (colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selection.wrappedValue == option
                                ? RetroTheme.accentColor.opacity(0.12)
                                : Color.clear
                        )
                }
                .buttonStyle(.plain)

                if index < options.count - 1 {
                    Rectangle()
                        .fill(colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight)
                        .frame(width: 1)
                }
            }
        }
        .background(colorScheme == .dark ? RetroTheme.cardDark.opacity(0.5) : RetroTheme.cardLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight, lineWidth: 1)
        )
    }
}
