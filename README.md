# BoringWeather

A deliberately boring, retro-styled iOS weather app. No flashy gradients. No trendy animations. Just weather data, presented clearly in a nostalgic monospaced aesthetic.

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

**No API key required.** This app uses [Open-Meteo](https://open-meteo.com/), a free and open-source weather API that needs no signup, no login, and no API key.

## Setup

### 1. Open in Xcode

```bash
cd BoringWeather
open BoringWeather.xcodeproj
```

### 2. Build and Run

- Select an iPhone simulator (iOS 17+)
- Press `Cmd+R` to build and run
- Grant location permission when prompted
- That's it. No configuration needed.

## Running Tests

### Unit Tests
```
Cmd+U in Xcode
```
Or from command line:
```bash
xcodebuild test -project BoringWeather.xcodeproj -scheme BoringWeather -destination 'platform=iOS Simulator,name=iPhone 15'
```

Tests cover:
- Open-Meteo forecast JSON decoding
- Geocoding response decoding
- Air quality response decoding
- Unit conversions (C to F, kph to mph, mb to inHg, meters to km/mi, degrees to compass)
- UnitsService formatting (temperature, wind, pressure, visibility, time)
- Cache read/write operations
- WMO weather icon mapping
- WMO weather code descriptions
- Air quality category labels (US AQI 0-500 scale)
- Domain model identity and mapping

### UI Tests
UI tests verify tab navigation and search flow.

## Architecture

```
BoringWeather/
├── App/
│   ├── BoringWeatherApp.swift    # @main entry point
│   ├── ContentView.swift         # Tab bar root
│   └── DIContainer.swift         # Dependency injection
├── Models/
│   ├── WeatherModels.swift       # Domain models
│   └── APIResponseModels.swift   # Open-Meteo Codable models + mapping
├── Config/
│   └── APIConfig.swift           # Open-Meteo base URLs
├── Services/
│   ├── API/
│   │   └── WeatherAPIService.swift   # URLSession async/await
│   ├── Cache/
│   │   └── CacheService.swift        # FileManager JSON cache
│   ├── Location/
│   │   └── LocationService.swift     # CoreLocation wrapper
│   └── Units/
│       └── UnitsService.swift        # Unit conversions + formatting
├── Repository/
│   └── WeatherRepository.swift       # Data layer (network + cache)
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── LocationsViewModel.swift
│   ├── AlertsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Theme/
│   │   ├── RetroTheme.swift          # Colors, fonts, modifiers
│   │   └── WeatherIconMapper.swift   # WMO code to SF Symbol
│   ├── Components/
│   │   └── RetroComponents.swift     # Reusable UI components
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Locations/
│   │   └── LocationsView.swift
│   ├── Alerts/
│   │   └── AlertsView.swift
│   └── Settings/
│       └── SettingsView.swift
└── Resources/
    └── Assets.xcassets
```

### Pattern: MVVM + Repository

- **Views** observe `@ObservedObject` ViewModels
- **ViewModels** call the Repository for data
- **Repository** coordinates between API service and cache
- **Services** are injected via `DIContainer`
- **Models** are split: API response models (Codable) map to domain models

### API Provider: Open-Meteo

Three Open-Meteo endpoints are used:
- **Forecast API** (`api.open-meteo.com/v1/forecast`) — current weather, hourly, and 10-day daily forecast
- **Geocoding API** (`geocoding-api.open-meteo.com/v1/search`) — city search with autocomplete
- **Air Quality API** (`air-quality-api.open-meteo.com/v1/air-quality`) — US AQI, PM2.5, PM10, ozone, etc.

All unit conversions (metric to imperial) are handled in the mapping layer since Open-Meteo returns metric values.

### Weather Codes

Open-Meteo uses [WMO weather interpretation codes](https://open-meteo.com/en/docs). These are mapped to SF Symbols and human-readable descriptions in `WeatherIconMapper.swift` and `WMOWeatherCode` respectively.

### Caching

- JSON files in the app's Caches directory via `FileManager`
- Per-location weather cache
- Saved locations list persistence
- Offline mode with "last updated" timestamp

## Features

| Feature | Status |
|---------|--------|
| Current weather with full details | Done |
| 24-hour hourly forecast | Done |
| 10-day daily forecast | Done |
| Location services | Done |
| City search with autocomplete | Done |
| Save/reorder/delete locations | Done |
| Air quality index (US AQI) | Done |
| Unit settings (C/F, metric/imperial) | Done |
| 12h/24h time format | Done |
| Light/dark mode toggle | Done |
| Offline cache fallback | Done |
| Pull to refresh | Done |
| Skeleton loading states | Done |
| Error states with retry | Done |
| Dynamic Type support | Done |
| VoiceOver accessibility labels | Done |
| Haptic feedback | Done |
| Retro monospaced theme | Done |
| Weather alerts | N/A (Open-Meteo does not provide alerts) |

## Note on Weather Alerts

Open-Meteo does not provide a weather alerts endpoint. The Alerts tab is included in the UI but will display a message directing users to their local weather service for warnings. If you switch to a provider that supports alerts (e.g., WeatherAPI.com), the domain model and UI already support displaying them.

## Changing API Provider

The API layer is isolated in `WeatherAPIService.swift` and `APIResponseModels.swift`. To switch providers:

1. Create a new response model file for the provider
2. Add mapping extensions to convert to domain models
3. Update `WeatherAPIService` endpoints and parsing
4. Update `APIConfig` with the new provider's base URL and any API key logic

The rest of the app (ViewModels, Views, Repository, Cache) requires no changes.

## Design

The "boring" retro theme uses:
- Monospaced system fonts throughout
- Warm cream/off-white backgrounds (light mode)
- Near-black backgrounds (dark mode)
- Amber/brown accent color
- Thin borders and minimal card styling
- No gradients, no blur effects, no hero images
- SF Symbols for all weather condition icons
