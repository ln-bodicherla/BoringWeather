import SwiftUI

enum AppTab: String, CaseIterable {
    case home, locations, settings

    var title: String {
        switch self {
        case .home: return "Weather"
        case .locations: return "Places"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "cloud.sun.fill"
        case .locations: return "map.fill"
        case .settings: return "slider.horizontal.3"
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var tabBarY: CGFloat = 100
    @State private var selectedScale: [CGFloat] = [1, 1, 1]

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .padding(.bottom, 75)

            liquidTabBar
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                tabBarY = 0
            }
        }
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

    // MARK: - Liquid Glass Tab Bar

    private var liquidTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(AppTab.allCases.enumerated()), id: \.element) { index, tab in
                liquidTabItem(tab, index: index)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Glass material
                Capsule()
                    .fill(.ultraThinMaterial)

                // Inner glow
                Capsule()
                    .fill(Color.white.opacity(0.03))

                // Edge highlight
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.02),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: Color.black.opacity(0.4), radius: 20, y: 10)
            .shadow(color: RetroTheme.accentColor.opacity(0.05), radius: 30, y: 5)
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
        .offset(y: tabBarY)
    }

    private func liquidTabItem(_ tab: AppTab, index: Int) -> some View {
        let selected = container.selectedTab == tab

        return Button {
            // Bounce animation on tap
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                selectedScale[index] = 0.85
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    selectedScale[index] = 1.0
                    container.selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selected {
                        // Glowing background pill
                        Capsule()
                            .fill(RetroTheme.accentColor.opacity(0.12))
                            .frame(width: 44, height: 30)
                            .liquidGlow(color: RetroTheme.accentColor)

                        Image(systemName: tab.icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(RetroTheme.accentColor)
                            .shadow(color: RetroTheme.accentColor.opacity(0.6), radius: 8)
                    } else {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(RetroTheme.textTertiary)
                    }
                }
                .frame(height: 30)

                Text(tab.title)
                    .font(.system(size: 9, weight: selected ? .bold : .regular, design: .rounded))
                    .foregroundStyle(selected ? RetroTheme.accentColor : RetroTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(selectedScale[index])
        }
        .buttonStyle(.plain)
    }
}
