import XCTest
@testable import BoringWeather

final class BoringWeatherTests: XCTestCase {

    // MARK: - Open-Meteo Forecast Decoding

    func testForecastResponseDecoding() throws {
        let json = """
        {
            "latitude": 51.5,
            "longitude": -0.12,
            "timezone": "Europe/London",
            "timezone_abbreviation": "GMT",
            "current": {
                "time": "2024-01-15T14:00",
                "temperature_2m": 8.0,
                "relative_humidity_2m": 71,
                "apparent_temperature": 5.2,
                "is_day": 1,
                "weather_code": 2,
                "wind_speed_10m": 20.2,
                "wind_direction_10m": 250,
                "surface_pressure": 1013.0,
                "visibility": 10000,
                "uv_index": 2.0
            },
            "hourly": {
                "time": ["2024-01-15T00:00", "2024-01-15T01:00"],
                "temperature_2m": [5.0, 4.8],
                "relative_humidity_2m": [80, 82],
                "apparent_temperature": [2.5, 2.2],
                "precipitation_probability": [0, 10],
                "weather_code": [0, 1],
                "wind_speed_10m": [12.9, 13.5],
                "is_day": [0, 0]
            },
            "daily": {
                "time": ["2024-01-15"],
                "weather_code": [2],
                "temperature_2m_max": [10.0],
                "temperature_2m_min": [3.0],
                "sunrise": ["2024-01-15T08:02"],
                "sunset": ["2024-01-15T16:10"],
                "uv_index_max": [2.0],
                "precipitation_sum": [2.5],
                "precipitation_probability_max": [60],
                "wind_speed_10m_max": [24.1]
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(OpenMeteoForecastResponse.self, from: json)

        XCTAssertEqual(response.latitude, 51.5)
        XCTAssertEqual(response.timezone, "Europe/London")
        XCTAssertEqual(response.current?.temperature_2m, 8.0)
        XCTAssertEqual(response.current?.weather_code, 2)
        XCTAssertEqual(response.hourly?.time.count, 2)
        XCTAssertEqual(response.daily?.time.count, 1)
        XCTAssertEqual(response.daily?.temperature_2m_max[0], 10.0)

        // Test domain model mapping
        let domain = response.toDomainModel(
            locationName: "London",
            region: "England",
            country: "United Kingdom",
            airQuality: nil
        )
        XCTAssertEqual(domain.location.name, "London")
        XCTAssertEqual(domain.current.tempC, 8.0)
        XCTAssertEqual(domain.current.conditionCode, 2)
        XCTAssertTrue(domain.current.isDay)
        XCTAssertEqual(domain.current.conditionText, "Partly Cloudy")
        XCTAssertEqual(domain.forecast.days.count, 1)
        XCTAssertEqual(domain.forecast.days[0].hours.count, 2)
    }

    // MARK: - Geocoding Decoding

    func testGeocodingResponseDecoding() throws {
        let json = """
        {
            "results": [
                {
                    "id": 2643743,
                    "name": "London",
                    "latitude": 51.50853,
                    "longitude": -0.12574,
                    "country": "United Kingdom",
                    "admin1": "England",
                    "timezone": "Europe/London"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(OpenMeteoGeocodingResponse.self, from: json)

        XCTAssertEqual(response.results?.count, 1)
        XCTAssertEqual(response.results?[0].name, "London")

        let domain = response.results![0].toDomainModel()
        XCTAssertEqual(domain.name, "London")
        XCTAssertEqual(domain.region, "England")
        XCTAssertEqual(domain.country, "United Kingdom")
        XCTAssertEqual(domain.latitude, 51.50853, accuracy: 0.001)
    }

    // MARK: - Air Quality Decoding

    func testAirQualityResponseDecoding() throws {
        let json = """
        {
            "current": {
                "us_aqi": 42,
                "pm10": 18.5,
                "pm2_5": 8.2,
                "carbon_monoxide": 250.0,
                "nitrogen_dioxide": 12.3,
                "sulphur_dioxide": 3.1,
                "ozone": 55.0
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(OpenMeteoAirQualityResponse.self, from: json)

        XCTAssertEqual(response.current?.us_aqi, 42)
        XCTAssertEqual(response.current?.pm2_5, 8.2)

        let domain = response.current!.toDomainModel()
        XCTAssertEqual(domain.usAQI, 42)
        XCTAssertEqual(domain.aqiCategory, "Good")
        XCTAssertEqual(domain.aqiNumericValue, 42)
    }

    // MARK: - Unit Conversion Tests

    func testCelsiusToFahrenheit() {
        XCTAssertEqual(UnitConvert.celsiusToFahrenheit(0), 32.0, accuracy: 0.01)
        XCTAssertEqual(UnitConvert.celsiusToFahrenheit(100), 212.0, accuracy: 0.01)
        XCTAssertEqual(UnitConvert.celsiusToFahrenheit(-40), -40.0, accuracy: 0.01)
    }

    func testKphToMph() {
        XCTAssertEqual(UnitConvert.kphToMph(100), 62.1371, accuracy: 0.01)
        XCTAssertEqual(UnitConvert.kphToMph(0), 0, accuracy: 0.01)
    }

    func testMbToInHg() {
        XCTAssertEqual(UnitConvert.mbToInHg(1013.25), 29.92, accuracy: 0.01)
    }

    func testMetersToKmAndMiles() {
        XCTAssertEqual(UnitConvert.metersToKm(10000), 10.0, accuracy: 0.01)
        XCTAssertEqual(UnitConvert.metersToMiles(1609.344), 1.0, accuracy: 0.01)
    }

    func testDegreesToCompass() {
        XCTAssertEqual(UnitConvert.degreesToCompass(0), "N")
        XCTAssertEqual(UnitConvert.degreesToCompass(90), "E")
        XCTAssertEqual(UnitConvert.degreesToCompass(180), "S")
        XCTAssertEqual(UnitConvert.degreesToCompass(270), "W")
        XCTAssertEqual(UnitConvert.degreesToCompass(45), "NE")
        XCTAssertEqual(UnitConvert.degreesToCompass(225), "SW")
    }

    // MARK: - UnitsService Formatting

    func testTemperatureFormatting() {
        let units = UnitsService()

        units.temperatureUnit = .fahrenheit
        XCTAssertEqual(units.temperature(celsius: 0, fahrenheit: 32), "32°")
        XCTAssertEqual(units.temperature(celsius: 100, fahrenheit: 212), "212°")

        units.temperatureUnit = .celsius
        XCTAssertEqual(units.temperature(celsius: 0, fahrenheit: 32), "0°")
        XCTAssertEqual(units.temperature(celsius: 100, fahrenheit: 212), "100°")
    }

    func testWindSpeedFormatting() {
        let units = UnitsService()

        units.speedUnit = .mph
        XCTAssertEqual(units.windSpeed(kph: 16.1, mph: 10.0), "10 mph")

        units.speedUnit = .kph
        XCTAssertEqual(units.windSpeed(kph: 16.1, mph: 10.0), "16 km/h")
    }

    func testPressureFormatting() {
        let units = UnitsService()

        units.pressureUnit = .mb
        XCTAssertEqual(units.pressure(mb: 1013.0, inHg: 29.91), "1013 mb")

        units.pressureUnit = .inHg
        XCTAssertEqual(units.pressure(mb: 1013.0, inHg: 29.91), "29.91 inHg")
    }

    func testVisibilityFormatting() {
        let units = UnitsService()

        units.distanceUnit = .km
        XCTAssertEqual(units.visibility(km: 10.0, miles: 6.2), "10.0 km")

        units.distanceUnit = .miles
        XCTAssertEqual(units.visibility(km: 10.0, miles: 6.2), "6.2 mi")
    }

    func testDayOfWeekFormatting() {
        let units = UnitsService()

        let todayFormatter = DateFormatter()
        todayFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = todayFormatter.string(from: Date())

        XCTAssertEqual(units.formatDayOfWeek(todayString), "Today")
    }

    // MARK: - Cache Tests

    func testCacheWriteAndRead() async {
        let cache = CacheService()

        let location = LocationInfo(
            name: "TestCity",
            region: "TestRegion",
            country: "TestCountry",
            latitude: 40.0,
            longitude: -74.0,
            timeZoneID: "America/New_York",
            localtime: "2024-01-15T12:00"
        )

        let current = CurrentWeather(
            tempC: 20.0, tempF: 68.0,
            feelsLikeC: 18.0, feelsLikeF: 64.4,
            conditionText: "Clear Sky", conditionCode: 0,
            isDay: true,
            windMph: 5.0, windKph: 8.0,
            windDegree: 180, windDirection: "S",
            humidity: 50,
            pressureMb: 1013.0, pressureIn: 29.91,
            visibilityKm: 10.0, visibilityMiles: 6.2,
            uvIndex: 5.0,
            airQuality: nil
        )

        let weatherData = WeatherData(
            location: location,
            current: current,
            forecast: Forecast(days: []),
            alerts: nil,
            airQuality: nil
        )

        let key = "test_cache_key"
        await cache.cacheWeather(weatherData, for: key)

        let loaded = await cache.loadCachedWeather(for: key)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.location.name, "TestCity")
        XCTAssertEqual(loaded?.current.tempC, 20.0)

        await cache.clearAll()
    }

    func testSavedLocationsCache() async {
        let cache = CacheService()

        let locations = [
            SavedLocation(name: "New York", region: "New York", country: "USA", latitude: 40.7, longitude: -74.0),
            SavedLocation(name: "London", region: "England", country: "UK", latitude: 51.5, longitude: -0.1)
        ]

        await cache.saveFavoriteLocations(locations)
        let loaded = await cache.loadFavoriteLocations()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].name, "New York")
        XCTAssertEqual(loaded[1].name, "London")

        await cache.clearAll()
    }

    // MARK: - WMO Weather Icon Mapping Tests

    func testClearDayIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 0, isDay: true), "sun.max.fill")
    }

    func testClearNightIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 0, isDay: false), "moon.fill")
    }

    func testPartlyCloudyIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 2, isDay: true), "cloud.sun.fill")
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 2, isDay: false), "cloud.moon.fill")
    }

    func testHeavyRainIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 65, isDay: true), "cloud.heavyrain.fill")
    }

    func testThunderstormIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 95, isDay: true), "cloud.bolt.fill")
    }

    func testSnowIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 75, isDay: true), "snowflake")
    }

    func testFogIcon() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 45, isDay: true), "cloud.fog.fill")
    }

    // MARK: - WMO Weather Code Descriptions

    func testWMOCodeDescriptions() {
        XCTAssertEqual(WMOWeatherCode.description(for: 0), "Clear Sky")
        XCTAssertEqual(WMOWeatherCode.description(for: 2), "Partly Cloudy")
        XCTAssertEqual(WMOWeatherCode.description(for: 3), "Overcast")
        XCTAssertEqual(WMOWeatherCode.description(for: 65), "Heavy Rain")
        XCTAssertEqual(WMOWeatherCode.description(for: 95), "Thunderstorm")
        XCTAssertEqual(WMOWeatherCode.description(for: 75), "Heavy Snow")
        XCTAssertEqual(WMOWeatherCode.description(for: 999), "Unknown")
    }

    // MARK: - Air Quality Tests

    func testAQICategoryLabels() {
        let good = AirQualityInfo(usAQI: 25, pm2_5: nil, pm10: nil, o3: nil, no2: nil, so2: nil, co: nil)
        XCTAssertEqual(good.aqiCategory, "Good")

        let moderate = AirQualityInfo(usAQI: 75, pm2_5: nil, pm10: nil, o3: nil, no2: nil, so2: nil, co: nil)
        XCTAssertEqual(moderate.aqiCategory, "Moderate")

        let unhealthy = AirQualityInfo(usAQI: 175, pm2_5: nil, pm10: nil, o3: nil, no2: nil, so2: nil, co: nil)
        XCTAssertEqual(unhealthy.aqiCategory, "Unhealthy")

        let hazardous = AirQualityInfo(usAQI: 350, pm2_5: nil, pm10: nil, o3: nil, no2: nil, so2: nil, co: nil)
        XCTAssertEqual(hazardous.aqiCategory, "Hazardous")

        let unknown = AirQualityInfo(usAQI: nil, pm2_5: nil, pm10: nil, o3: nil, no2: nil, so2: nil, co: nil)
        XCTAssertEqual(unknown.aqiCategory, "N/A")
    }

    // MARK: - Model Identity Tests

    func testSavedLocationEquality() {
        let loc1 = SavedLocation(name: "NYC", region: "NY", country: "USA", latitude: 40.7, longitude: -74.0)
        let loc2 = SavedLocation(name: "NYC", region: "NY", country: "USA", latitude: 40.7, longitude: -74.0)
        XCTAssertEqual(loc1.id, loc2.id)
    }

    func testSavedLocationFromLocationInfo() {
        let info = LocationInfo(
            name: "Berlin", region: "Berlin", country: "Germany",
            latitude: 52.5, longitude: 13.4,
            timeZoneID: "Europe/Berlin", localtime: "2024-01-15T15:00"
        )
        let saved = SavedLocation(from: info)
        XCTAssertEqual(saved.name, "Berlin")
        XCTAssertEqual(saved.latitude, 52.5)
    }
}
