import SwiftUI

@MainActor
final class LocationsViewModel: ObservableObject {
    @Published var savedLocations: [SavedLocation] = []
    @Published var searchResults: [SearchLocation] = []
    @Published var searchText: String = ""
    @Published var isSearching = false
    @Published var selectedLocation: SavedLocation?

    private let repository: WeatherRepository
    private let locationService: LocationService
    private var searchTask: Task<Void, Never>?
    var cloudBackupService: CloudBackupService?

    init(repository: WeatherRepository, locationService: LocationService) {
        self.repository = repository
        self.locationService = locationService
    }

    func loadSavedLocations() async {
        savedLocations = await repository.loadFavoriteLocations()
    }

    func search() {
        searchTask?.cancel()
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 2 else {
            searchResults = []
            return
        }

        isSearching = true
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                let results = try await repository.searchLocations(query: query)
                if !Task.isCancelled {
                    self.searchResults = results
                }
            } catch {
                if !Task.isCancelled {
                    self.searchResults = []
                }
            }
            self.isSearching = false
        }
    }

    func addLocation(_ location: SearchLocation) async {
        let saved = SavedLocation(
            name: location.name,
            region: location.region,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude
        )

        guard !savedLocations.contains(where: { $0.id == saved.id }) else { return }

        savedLocations.append(saved)
        await repository.saveFavoriteLocations(savedLocations)
        cloudBackupService?.backupLocations(savedLocations)

        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        searchText = ""
        searchResults = []
    }

    func removeLocation(at offsets: IndexSet) async {
        savedLocations.remove(atOffsets: offsets)
        await repository.saveFavoriteLocations(savedLocations)
        cloudBackupService?.backupLocations(savedLocations)
    }

    func moveLocation(from source: IndexSet, to destination: Int) async {
        savedLocations.move(fromOffsets: source, toOffset: destination)
        await repository.saveFavoriteLocations(savedLocations)
        cloudBackupService?.backupLocations(savedLocations)
    }
}
