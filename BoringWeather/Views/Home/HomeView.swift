import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var blobPhase: Double = 0
    @State private var iconBounce = false
    @State private var tempScale: CGFloat = 0.8
    @State private var tempOpacity: Double = 0
    @State private var cardAppear: [Bool] = Array(repeating: false, count: 6)

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "Weather") {
                if viewModel.activeLocation != nil {
                    Button {
                        Task { await viewModel.loadCurrentLocation() }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RetroTheme.accentColor)
                            .liquidGlow(color: RetroTheme.accentColor)
                    }
                    .accessibilityLabel("Switch to current location")
                }
            } trailing: {
                EmptyView()
            }

            ScrollView {
                if viewModel.isLoading && viewModel.weatherData == nil {
                    RetroSkeletonView()
                        .frame(minHeight: 500)
                } else if let error = viewModel.errorMessage, viewModel.weatherData == nil {
                    RetroErrorView(message: error) {
                        await viewModel.refresh()
                    }
                } else if let weather = viewModel.weatherData {
                    weatherContent(weather)
                } else {
                    emptyState
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .background(
            ZStack {
                Color(red: 0.02, green: 0.02, blue: 0.05)

                if let weather = viewModel.weatherData {
                    // Animated liquid blobs as background
                    let colors = WeatherIconMapper.ambientColors(
                        for: weather.current.conditionCode,
                        isDay: weather.current.isDay
                    )
                    ambientBackground(colors: colors)
                }
            }
            .ignoresSafeArea()
        )
        .task {
            await viewModel.loadIfNeeded()
        }
        .onChange(of: viewModel.weatherData?.id) { _, _ in
            triggerEntryAnimations()
        }
    }

    // MARK: - Ambient Background

    private func ambientBackground(colors: [Color]) -> some View {
        ZStack {
            // Large morphing blobs
            LiquidBlob(phase: blobPhase)
                .fill(colors[0].opacity(0.25))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: -50, y: -200)

            LiquidBlob(phase: blobPhase + 2)
                .fill(colors.count > 1 ? colors[1].opacity(0.2) : Color.clear)
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: 80, y: -80)

            LiquidBlob(phase: blobPhase + 4)
                .fill(colors.count > 2 ? colors[2].opacity(0.15) : Color.clear)
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: -30, y: 150)

            // Floating particles
            FloatingParticles(count: 12, color: RetroTheme.accentColor.opacity(0.4))
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                blobPhase = .pi * 2
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                BreathingRing(color: RetroTheme.accentColor.opacity(0.3), size: 80)
                Image(systemName: "cloud.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(RetroTheme.textTertiary)
            }
            Text("No Data")
                .font(RetroTheme.mono(18, weight: .semibold))
                .foregroundStyle(RetroTheme.textPrimary)
            Text("Pull to refresh or enable location services")
                .font(RetroTheme.bodyFont)
                .foregroundStyle(RetroTheme.textTertiary)
        }
        .padding(.top, 120)
    }

    // MARK: - Weather Content

    @ViewBuilder
    private func weatherContent(_ weather: WeatherData) -> some View {
        LazyVStack(spacing: RetroTheme.sectionSpacing) {
            if viewModel.isOffline {
                RetroOfflineBanner(lastUpdated: viewModel.lastUpdatedText)
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            currentWeatherCard(weather)
                .offset(y: cardAppear[0] ? 0 : 30)
                .opacity(cardAppear[0] ? 1 : 0)

            detailsGrid(weather)
                .offset(y: cardAppear[1] ? 0 : 30)
                .opacity(cardAppear[1] ? 1 : 0)

            if let aqi = weather.airQuality ?? weather.current.airQuality {
                airQualityCard(aqi)
                    .offset(y: cardAppear[2] ? 0 : 30)
                    .opacity(cardAppear[2] ? 1 : 0)
            }

            hourlyForecastSection(weather)
                .offset(y: cardAppear[3] ? 0 : 30)
                .opacity(cardAppear[3] ? 1 : 0)

            dailyForecastSection(weather)
                .offset(y: cardAppear[4] ? 0 : 30)
                .opacity(cardAppear[4] ? 1 : 0)

            Text(viewModel.lastUpdatedText)
                .font(RetroTheme.captionFont)
                .foregroundStyle(RetroTheme.textTertiary)
                .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .onAppear {
            triggerEntryAnimations()
        }
    }

    private func triggerEntryAnimations() {
        for i in 0..<cardAppear.count {
            cardAppear[i] = false
        }
        tempScale = 0.8
        tempOpacity = 0
        iconBounce = false

        for i in 0..<cardAppear.count {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.1)) {
                cardAppear[i] = true
            }
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.15)) {
            tempScale = 1.0
            tempOpacity = 1
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.4).delay(0.1)) {
            iconBounce = true
        }
    }

    // MARK: - Current Weather Card

    private func currentWeatherCard(_ weather: WeatherData) -> some View {
        VStack(spacing: 4) {
            // Location pill
            HStack(spacing: 5) {
                Image(systemName: "mappin")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(RetroTheme.accentColor)
                Text(weather.location.name)
                    .font(RetroTheme.mono(13, weight: .semibold))
                    .foregroundStyle(RetroTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .accessibilityAddTraits(.isHeader)

            Text(formatLocalTime(weather.location.localtime, timeZoneID: weather.location.timeZoneID))
                .font(RetroTheme.mono(10))
                .foregroundStyle(RetroTheme.textTertiary)
                .tracking(1)
                .padding(.top, 2)

            // Animated weather icon with glow orb
            ZStack {
                // Ambient orb behind icon
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                WeatherIconMapper.conditionColor(for: weather.current.conditionCode, isDay: weather.current.isDay).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(iconBounce ? 1 : 0.5)

                Image(systemName: WeatherIconMapper.sfSymbol(
                    for: weather.current.conditionCode,
                    isDay: weather.current.isDay
                ))
                .font(.system(size: 52))
                .foregroundStyle(WeatherIconMapper.conditionColor(
                    for: weather.current.conditionCode,
                    isDay: weather.current.isDay
                ))
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(iconBounce ? 1 : 0.3)
                .liquidGlow(color: WeatherIconMapper.conditionColor(for: weather.current.conditionCode, isDay: weather.current.isDay))
            }
            .padding(.vertical, 4)

            // Temperature with scale animation
            Text(viewModel.unitsService.temperature(
                celsius: weather.current.tempC,
                fahrenheit: weather.current.tempF
            ))
            .font(RetroTheme.temperatureFont)
            .foregroundStyle(RetroTheme.textPrimary)
            .scaleEffect(tempScale)
            .opacity(tempOpacity)
            .accessibilityLabel("Temperature \(viewModel.unitsService.temperature(celsius: weather.current.tempC, fahrenheit: weather.current.tempF))")

            // Condition with shimmer
            Text(weather.current.conditionText)
                .font(RetroTheme.mono(15, weight: .medium))
                .foregroundStyle(RetroTheme.textSecondary)
                .shimmer()

            // Info pills
            if let today = weather.forecast.days.first {
                HStack(spacing: 8) {
                    glassPill("Feels \(viewModel.unitsService.temperature(celsius: weather.current.feelsLikeC, fahrenheit: weather.current.feelsLikeF))")
                    glassPill("H:\(viewModel.unitsService.temperature(celsius: today.maxTempC, fahrenheit: today.maxTempF))")
                    glassPill("L:\(viewModel.unitsService.temperature(celsius: today.minTempC, fahrenheit: today.minTempF))")
                }
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .retroCard()
    }

    private func glassPill(_ text: String) -> some View {
        Text(text)
            .font(RetroTheme.mono(10, weight: .medium))
            .foregroundStyle(RetroTheme.textTertiary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }

    // MARK: - Details Grid

    private func detailsGrid(_ weather: WeatherData) -> some View {
        VStack(spacing: 1) {
            RetroSectionHeader(title: "Details")
                .padding(.bottom, 8)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                detailCell(icon: "humidity.fill", label: "Humidity", value: "\(weather.current.humidity)%",
                           color: Color(red: 0.3, green: 0.7, blue: 1.0))
                detailCell(icon: "wind", label: "Wind",
                           value: "\(viewModel.unitsService.windSpeed(kph: weather.current.windKph, mph: weather.current.windMph)) \(weather.current.windDirection)",
                           color: RetroTheme.accentColor)
                detailCell(icon: "gauge.medium", label: "Pressure",
                           value: viewModel.unitsService.pressure(mb: weather.current.pressureMb, inHg: weather.current.pressureIn),
                           color: RetroTheme.accentPurple)
                detailCell(icon: "eye.fill", label: "Visibility",
                           value: viewModel.unitsService.visibility(km: weather.current.visibilityKm, miles: weather.current.visibilityMiles),
                           color: RetroTheme.accentMint)
                detailCell(icon: "sun.max.trianglebadge.exclamationmark.fill", label: "UV Index",
                           value: "\(Int(weather.current.uvIndex)) \(uvLabel(weather.current.uvIndex))",
                           color: RetroTheme.accentGold)
                detailCell(icon: "sunrise.fill", label: "Sunrise", value: viewModel.todaySunrise,
                           color: Color(red: 1.0, green: 0.7, blue: 0.3))
                detailCell(icon: "sunset.fill", label: "Sunset", value: viewModel.todaySunset,
                           color: RetroTheme.accentPink)
                detailCell(icon: "drop.fill", label: "Dew Point", value: "--",
                           color: Color(red: 0.4, green: 0.6, blue: 0.9))
            }
        }
    }

    private func detailCell(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon with colored glass circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(RetroTheme.mono(10, weight: .medium))
                    .foregroundStyle(RetroTheme.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Text(value)
                    .font(RetroTheme.mono(16, weight: .bold))
                    .foregroundStyle(RetroTheme.textPrimary)
            }
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
        VStack(alignment: .leading, spacing: 14) {
            RetroSectionHeader(title: "Air Quality")

            HStack(alignment: .top) {
                // AQI score with animated ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 4)
                        .frame(width: 64, height: 64)

                    Circle()
                        .trim(from: 0, to: min(CGFloat(aqi.aqiNumericValue) / 300.0, 1.0))
                        .stroke(
                            AngularGradient(
                                colors: [aqiColor(aqi.aqiNumericValue), aqiColor(aqi.aqiNumericValue).opacity(0.3)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(aqi.aqiNumericValue)")
                            .font(RetroTheme.mono(20, weight: .bold))
                            .foregroundStyle(RetroTheme.textPrimary)
                        Text("AQI")
                            .font(RetroTheme.mono(8, weight: .medium))
                            .foregroundStyle(RetroTheme.textTertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(aqi.aqiCategory)
                        .font(RetroTheme.mono(12, weight: .bold))
                        .foregroundStyle(aqiColor(aqi.aqiNumericValue))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(aqiColor(aqi.aqiNumericValue).opacity(0.12))
                        )

                    VStack(alignment: .trailing, spacing: 4) {
                        if let pm25 = aqi.pm2_5 {
                            HStack(spacing: 4) {
                                Text("PM2.5")
                                    .font(RetroTheme.captionFont)
                                    .foregroundStyle(RetroTheme.textTertiary)
                                Text(String(format: "%.1f", pm25))
                                    .font(RetroTheme.mono(13, weight: .semibold))
                                    .foregroundStyle(RetroTheme.textSecondary)
                            }
                        }
                        if let pm10 = aqi.pm10 {
                            HStack(spacing: 4) {
                                Text("PM10")
                                    .font(RetroTheme.captionFont)
                                    .foregroundStyle(RetroTheme.textTertiary)
                                Text(String(format: "%.1f", pm10))
                                    .font(RetroTheme.mono(13, weight: .semibold))
                                    .foregroundStyle(RetroTheme.textSecondary)
                            }
                        }
                    }
                }
            }

            RetroDivider()

            Text(aqi.healthRecommendation)
                .font(RetroTheme.mono(11))
                .foregroundStyle(RetroTheme.textTertiary)
                .lineSpacing(3)
        }
        .retroCard()
    }

    private func aqiColor(_ value: Int) -> Color {
        switch value {
        case 0..<50: return RetroTheme.accentMint
        case 50..<100: return RetroTheme.accentGold
        case 100..<150: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case 150..<200: return RetroTheme.accentPink
        default: return Color(red: 0.8, green: 0.2, blue: 0.2)
        }
    }

    // MARK: - Hourly Forecast

    private func hourlyForecastSection(_ weather: WeatherData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            RetroSectionHeader(title: "Hourly")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    ForEach(viewModel.next24Hours) { hour in
                        hourCell(hour, timeZoneID: weather.location.timeZoneID)
                    }
                }
                .padding(.horizontal, 4)
            }
            .retroCard()
        }
    }

    private func hourCell(_ hour: HourForecast, timeZoneID: String) -> some View {
        VStack(spacing: 10) {
            Text(viewModel.unitsService.formatHour(hour.time, timeZoneID: timeZoneID))
                .font(RetroTheme.mono(10, weight: .medium))
                .foregroundStyle(RetroTheme.textTertiary)

            ZStack {
                Circle()
                    .fill(WeatherIconMapper.conditionColor(for: hour.conditionCode, isDay: hour.isDay).opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: WeatherIconMapper.sfSymbol(for: hour.conditionCode, isDay: hour.isDay))
                    .font(.system(size: 18))
                    .foregroundStyle(WeatherIconMapper.conditionColor(for: hour.conditionCode, isDay: hour.isDay))
                    .symbolRenderingMode(.hierarchical)
            }

            Text(viewModel.unitsService.temperature(celsius: hour.tempC, fahrenheit: hour.tempF))
                .font(RetroTheme.mono(14, weight: .bold))
                .foregroundStyle(RetroTheme.textPrimary)

            if hour.chanceOfRain > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 7))
                    Text("\(hour.chanceOfRain)%")
                        .font(RetroTheme.mono(9, weight: .semibold))
                }
                .foregroundStyle(Color(red: 0.35, green: 0.65, blue: 1.0))
            }
        }
        .frame(width: 62)
        .padding(.vertical, 10)
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
            Text(viewModel.unitsService.formatDayOfWeek(day.date))
                .font(RetroTheme.mono(13, weight: .medium))
                .foregroundStyle(RetroTheme.textSecondary)
                .frame(width: 50, alignment: .leading)

            ZStack {
                Circle()
                    .fill(WeatherIconMapper.conditionColor(for: day.conditionCode, isDay: true).opacity(0.08))
                    .frame(width: 26, height: 26)
                Image(systemName: WeatherIconMapper.sfSymbol(for: day.conditionCode, isDay: true))
                    .font(.system(size: 14))
                    .foregroundStyle(WeatherIconMapper.conditionColor(for: day.conditionCode, isDay: true))
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(width: 32)

            if day.dailyChanceOfRain > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 7))
                    Text("\(day.dailyChanceOfRain)%")
                        .font(RetroTheme.mono(10, weight: .semibold))
                }
                .foregroundStyle(Color(red: 0.35, green: 0.65, blue: 1.0))
                .frame(width: 40)
            } else {
                Spacer().frame(width: 40)
            }

            Spacer()

            // Gradient temp bar
            tempBar(low: day.minTempC, high: day.maxTempC, lowF: day.minTempF, highF: day.maxTempF)

            HStack(spacing: 8) {
                Text(viewModel.unitsService.temperature(celsius: day.minTempC, fahrenheit: day.minTempF))
                    .font(RetroTheme.mono(12))
                    .foregroundStyle(RetroTheme.textTertiary)
                    .frame(width: 36, alignment: .trailing)
                Text(viewModel.unitsService.temperature(celsius: day.maxTempC, fahrenheit: day.maxTempF))
                    .font(RetroTheme.mono(12, weight: .bold))
                    .foregroundStyle(RetroTheme.textPrimary)
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.unitsService.formatDayOfWeek(day.date)): High \(viewModel.unitsService.temperature(celsius: day.maxTempC, fahrenheit: day.maxTempF)), Low \(viewModel.unitsService.temperature(celsius: day.minTempC, fahrenheit: day.minTempF)), \(day.dailyChanceOfRain)% rain")
    }

    private func tempBar(low: Double, high: Double, lowF: Double, highF: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: geo.size.width, height: 5)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.6, blue: 1.0),
                                RetroTheme.accentColor,
                                RetroTheme.accentGold,
                                Color(red: 1.0, green: 0.4, blue: 0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width, height: 5)
                    .shadow(color: RetroTheme.accentColor.opacity(0.3), radius: 4, y: 0)
            }
        }
        .frame(width: 50, height: 5)
    }

    // MARK: - Helpers

    private func formatLocalTime(_ isoTime: String, timeZoneID: String) -> String {
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
