import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "BoringWeather") {
                if viewModel.activeLocation != nil {
                    Button {
                        Task { await viewModel.loadCurrentLocation() }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RetroTheme.accentColor)
                    }
                    .accessibilityLabel("Switch to current location")
                }
            } trailing: {
                EmptyView()
            }

            ScrollView {
                if viewModel.isLoading && viewModel.weatherData == nil {
                    RetroSkeletonView()
                } else if let error = viewModel.errorMessage, viewModel.weatherData == nil {
                    RetroErrorView(message: error) {
                        await viewModel.refresh()
                    }
                } else if let weather = viewModel.weatherData {
                    weatherContent(weather)
                } else {
                    VStack(spacing: 20) {
                        Text("NO DATA")
                            .font(RetroTheme.headlineFont)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        Text("Pull to refresh or enable location services.")
                            .font(RetroTheme.bodyFont)
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
                    }
                    .padding(.top, 100)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .background(colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight)
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    // MARK: - Weather Content

    @ViewBuilder
    private func weatherContent(_ weather: WeatherData) -> some View {
        LazyVStack(spacing: RetroTheme.sectionSpacing) {
            // Offline banner
            if viewModel.isOffline {
                RetroOfflineBanner(lastUpdated: viewModel.lastUpdatedText)
                    .padding(.top, 4)
            }

            // Current conditions
            currentWeatherCard(weather)

            // Details grid
            detailsGrid(weather)

            // Air Quality
            if let aqi = weather.airQuality ?? weather.current.airQuality {
                airQualityCard(aqi)
            }

            // Hourly forecast
            hourlyForecastSection(weather)

            // Daily forecast
            dailyForecastSection(weather)

            // Last updated
            Text(viewModel.lastUpdatedText)
                .font(RetroTheme.captionFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
                .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }

    // MARK: - Current Weather Card

    private func currentWeatherCard(_ weather: WeatherData) -> some View {
        VStack(spacing: 8) {
            // City name + local time
            Text(weather.location.name)
                .font(RetroTheme.mono(22, weight: .bold))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .accessibilityAddTraits(.isHeader)

            Text(formatLocalTime(weather.location.localtime, timeZoneID: weather.location.timeZoneID))
                .font(RetroTheme.captionFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))

            // Weather icon + temp
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: WeatherIconMapper.sfSymbol(
                    for: weather.current.conditionCode,
                    isDay: weather.current.isDay
                ))
                .font(.system(size: 36))
                .foregroundStyle(WeatherIconMapper.conditionColor(
                    for: weather.current.conditionCode,
                    isDay: weather.current.isDay
                ))
                .symbolRenderingMode(.hierarchical)

                Text(viewModel.unitsService.temperature(
                    celsius: weather.current.tempC,
                    fahrenheit: weather.current.tempF
                ))
                .font(RetroTheme.temperatureFont)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .accessibilityLabel("Temperature \(viewModel.unitsService.temperature(celsius: weather.current.tempC, fahrenheit: weather.current.tempF))")
            }

            // Condition text
            Text(weather.current.conditionText)
                .font(RetroTheme.mono(14, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                .textCase(.uppercase)

            // Feels like + high/low
            if let today = weather.forecast.days.first {
                HStack(spacing: 16) {
                    Text("Feels \(viewModel.unitsService.temperature(celsius: weather.current.feelsLikeC, fahrenheit: weather.current.feelsLikeF))")
                    Text("H:\(viewModel.unitsService.temperature(celsius: today.maxTempC, fahrenheit: today.maxTempF))")
                    Text("L:\(viewModel.unitsService.temperature(celsius: today.minTempC, fahrenheit: today.minTempF))")
                }
                .font(RetroTheme.captionFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity)
        .retroCard()
    }

    // MARK: - Details Grid

    private func detailsGrid(_ weather: WeatherData) -> some View {
        VStack(spacing: 1) {
            RetroSectionHeader(title: "Details")
                .padding(.bottom, 8)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 1) {
                detailCell(
                    icon: "humidity.fill",
                    label: "Humidity",
                    value: "\(weather.current.humidity)%"
                )
                detailCell(
                    icon: "wind",
                    label: "Wind",
                    value: "\(viewModel.unitsService.windSpeed(kph: weather.current.windKph, mph: weather.current.windMph)) \(weather.current.windDirection)"
                )
                detailCell(
                    icon: "gauge.medium",
                    label: "Pressure",
                    value: viewModel.unitsService.pressure(mb: weather.current.pressureMb, inHg: weather.current.pressureIn)
                )
                detailCell(
                    icon: "eye.fill",
                    label: "Visibility",
                    value: viewModel.unitsService.visibility(km: weather.current.visibilityKm, miles: weather.current.visibilityMiles)
                )
                detailCell(
                    icon: "sun.max.trianglebadge.exclamationmark.fill",
                    label: "UV Index",
                    value: "\(Int(weather.current.uvIndex)) \(uvLabel(weather.current.uvIndex))"
                )
                detailCell(
                    icon: "sunrise.fill",
                    label: "Sunrise",
                    value: viewModel.todaySunrise
                )
                detailCell(
                    icon: "sunset.fill",
                    label: "Sunset",
                    value: viewModel.todaySunset
                )
                detailCell(
                    icon: "arrow.up.and.down",
                    label: "Dew Point",
                    value: "--"
                )
            }
        }
    }

    private func detailCell(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(RetroTheme.accentColor)
                Text(label)
                    .font(RetroTheme.captionFont)
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                    .textCase(.uppercase)
            }
            Text(value)
                .font(RetroTheme.mono(14, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .retroCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private func uvLabel(_ uv: Double) -> String {
        switch uv {
        case 0..<3: return "Low"
        case 3..<6: return "Mod"
        case 6..<8: return "High"
        case 8..<11: return "VHigh"
        default: return "Ext"
        }
    }

    // MARK: - Air Quality Card

    private func airQualityCard(_ aqi: AirQualityInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RetroSectionHeader(title: "Air Quality")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AQI: \(aqi.aqiNumericValue)")
                        .font(RetroTheme.mono(20, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)

                    Text(aqi.aqiCategory)
                        .font(RetroTheme.mono(12, weight: .medium))
                        .foregroundStyle(RetroTheme.accentColor)
                        .textCase(.uppercase)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let pm25 = aqi.pm2_5 {
                        Text("PM2.5: \(String(format: "%.1f", pm25))")
                            .font(RetroTheme.captionFont)
                    }
                    if let pm10 = aqi.pm10 {
                        Text("PM10: \(String(format: "%.1f", pm10))")
                            .font(RetroTheme.captionFont)
                    }
                }
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
            }

            RetroDivider()

            Text(aqi.healthRecommendation)
                .font(RetroTheme.captionFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
        }
        .retroCard()
    }

    // MARK: - Hourly Forecast

    private func hourlyForecastSection(_ weather: WeatherData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RetroSectionHeader(title: "Hourly")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.next24Hours) { hour in
                        hourCell(hour, timeZoneID: weather.location.timeZoneID)
                    }
                }
            }
            .retroCard()
        }
    }

    private func hourCell(_ hour: HourForecast, timeZoneID: String) -> some View {
        VStack(spacing: 8) {
            Text(viewModel.unitsService.formatHour(hour.time, timeZoneID: timeZoneID))
                .font(RetroTheme.captionFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))

            Image(systemName: WeatherIconMapper.sfSymbol(for: hour.conditionCode, isDay: hour.isDay))
                .font(.system(size: 18))
                .foregroundStyle(WeatherIconMapper.conditionColor(for: hour.conditionCode, isDay: hour.isDay))
                .symbolRenderingMode(.hierarchical)

            Text(viewModel.unitsService.temperature(celsius: hour.tempC, fahrenheit: hour.tempF))
                .font(RetroTheme.mono(14, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))

            if hour.chanceOfRain > 0 {
                Text("\(hour.chanceOfRain)%")
                    .font(RetroTheme.mono(10))
                    .foregroundStyle(Color(red: 0.4, green: 0.5, blue: 0.8))
            }
        }
        .frame(width: 64)
        .padding(.vertical, 8)
    }

    // MARK: - Daily Forecast

    private func dailyForecastSection(_ weather: WeatherData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RetroSectionHeader(title: "10-Day Forecast")

            VStack(spacing: 0) {
                ForEach(viewModel.forecastDays) { day in
                    dailyRow(day, weather: weather)

                    if day.id != viewModel.forecastDays.last?.id {
                        RetroDivider()
                    }
                }
            }
            .retroCard()
        }
    }

    private func dailyRow(_ day: ForecastDay, weather: WeatherData) -> some View {
        HStack(spacing: 0) {
            // Day name
            Text(viewModel.unitsService.formatDayOfWeek(day.date))
                .font(RetroTheme.mono(13, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
                .frame(width: 50, alignment: .leading)

            // Icon
            Image(systemName: WeatherIconMapper.sfSymbol(for: day.conditionCode, isDay: true))
                .font(.system(size: 16))
                .foregroundStyle(WeatherIconMapper.conditionColor(for: day.conditionCode, isDay: true))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 30)

            // Rain chance
            if day.dailyChanceOfRain > 0 {
                Text("\(day.dailyChanceOfRain)%")
                    .font(RetroTheme.mono(10))
                    .foregroundStyle(Color(red: 0.4, green: 0.5, blue: 0.8))
                    .frame(width: 36)
            } else {
                Spacer()
                    .frame(width: 36)
            }

            Spacer()

            // Temp bar
            tempBar(low: day.minTempC, high: day.maxTempC, lowF: day.minTempF, highF: day.maxTempF)

            // High/Low
            HStack(spacing: 8) {
                Text(viewModel.unitsService.temperature(celsius: day.minTempC, fahrenheit: day.minTempF))
                    .font(RetroTheme.mono(12))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.35))
                    .frame(width: 36, alignment: .trailing)

                Text(viewModel.unitsService.temperature(celsius: day.maxTempC, fahrenheit: day.maxTempF))
                    .font(RetroTheme.mono(12, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.unitsService.formatDayOfWeek(day.date)): High \(viewModel.unitsService.temperature(celsius: day.maxTempC, fahrenheit: day.maxTempF)), Low \(viewModel.unitsService.temperature(celsius: day.minTempC, fahrenheit: day.minTempF)), \(day.dailyChanceOfRain)% rain")
    }

    private func tempBar(low: Double, high: Double, lowF: Double, highF: Double) -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.6, blue: 0.8),
                            RetroTheme.accentColor,
                            Color(red: 0.8, green: 0.4, blue: 0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 4)
        }
        .frame(width: 60, height: 4)
    }

    // MARK: - Helpers

    private func formatLocalTime(_ isoTime: String, timeZoneID: String) -> String {
        // Open-Meteo format: "2024-01-15T14:00"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        guard let date = formatter.date(from: isoTime) else { return isoTime }

        let output = DateFormatter()
        output.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        output.dateFormat = "EEEE, MMM d  h:mm a"
        return output.string(from: date)
    }
}
