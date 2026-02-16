import SwiftUI

enum AppTab: String, CaseIterable {
    case home, locations, settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .locations: return "Locations"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "sun.dust.fill"
        case .locations: return "map.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            tabContent
            tabBar
        }
        .preferredColorScheme(resolvedColorScheme)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch container.selectedTab {
        case .home:
            HomeView(viewModel: container.homeViewModel)
        case .locations:
            LocationsView(viewModel: container.locationsViewModel)
        case .settings:
            SettingsView(viewModel: container.settingsViewModel)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(borderColor)
                .frame(height: 1)

            HStack(spacing: 0) {
                tabItem(.home)
                tabItem(.locations)
                tabItem(.settings)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .padding(.horizontal, 4)
        }
        .background(bgColor)
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let selected = container.selectedTab == tab

        return Button {
            container.selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18))
                Text(tab.title)
                    .font(.system(size: 10, weight: selected ? .bold : .regular, design: .monospaced))
            }
            .foregroundColor(selected ? RetroTheme.accentColor : unselectedColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(selected ? RetroTheme.accentColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Theme

    private var resolvedColorScheme: ColorScheme? {
        switch settingsVM.appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    // MARK: - Colors

    private var bgColor: Color {
        colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight
    }

    private var borderColor: Color {
        colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight
    }

    private var unselectedColor: Color {
        colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4)
    }
}
