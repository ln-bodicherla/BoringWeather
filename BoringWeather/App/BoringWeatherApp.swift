import SwiftUI

@main
struct BoringWeatherApp: App {
    @StateObject private var container = DIContainer()
    @AppStorage("appTheme") private var appTheme: String = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .environmentObject(container.settingsViewModel)
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
