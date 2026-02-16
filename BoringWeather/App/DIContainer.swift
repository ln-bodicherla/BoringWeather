import SwiftUI

@MainActor
final class DIContainer: ObservableObject {

    // MARK: - Services

    let apiService: WeatherAPIService
    let cacheService: CacheService
    let locationService: LocationService
    let unitsService: UnitsService
    let cloudBackupService: CloudBackupService

    // MARK: - Repository

    let weatherRepository: WeatherRepository

    // MARK: - Navigation

    @Published var selectedTab: AppTab = .home

    // MARK: - ViewModels

    let homeViewModel: HomeViewModel
    let locationsViewModel: LocationsViewModel
    let settingsViewModel: SettingsViewModel

    init() {
        let config = APIConfig.load()

        self.apiService = WeatherAPIService(config: config)
        self.cacheService = CacheService()
        self.locationService = LocationService()
        self.unitsService = UnitsService()
        self.cloudBackupService = CloudBackupService()

        self.weatherRepository = WeatherRepository(
            apiService: apiService,
            cacheService: cacheService
        )

        self.settingsViewModel = SettingsViewModel(unitsService: unitsService)
        self.settingsViewModel.cloudBackupService = cloudBackupService

        self.homeViewModel = HomeViewModel(
            repository: weatherRepository,
            locationService: locationService,
            unitsService: unitsService
        )

        self.locationsViewModel = LocationsViewModel(
            repository: weatherRepository,
            locationService: locationService
        )
        self.locationsViewModel.cloudBackupService = cloudBackupService

        // Start iCloud observation and restore data if fresh install
        cloudBackupService.start()
        Task {
            await cloudBackupService.restoreIfNeeded(
                cacheService: cacheService,
                unitsService: unitsService
            )
        }
    }
}
