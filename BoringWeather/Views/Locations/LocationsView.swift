import SwiftUI

struct LocationsView: View {
    @ObservedObject var viewModel: LocationsViewModel
    @EnvironmentObject var container: DIContainer
    @Environment(\.colorScheme) var colorScheme
    @State private var editMode: EditMode = .inactive
    @State private var listAppeared = false

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "Places") {
                EmptyView()
            } trailing: {
                if !viewModel.savedLocations.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .font(RetroTheme.mono(13, weight: .medium))
                            .foregroundStyle(RetroTheme.accentColor)
                    }
                }
            }

            searchBar

            List {
                if !viewModel.searchResults.isEmpty {
                    Section {
                        ForEach(viewModel.searchResults) { result in
                            Button {
                                Task { await viewModel.addLocation(result) }
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.name)
                                            .font(RetroTheme.mono(15, weight: .semibold))
                                            .foregroundStyle(RetroTheme.textPrimary)
                                        Text("\(result.region), \(result.country)")
                                            .font(RetroTheme.mono(11))
                                            .foregroundStyle(RetroTheme.textTertiary)
                                    }
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(RetroTheme.accentMint.opacity(0.12))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "plus")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(RetroTheme.accentMint)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } header: {
                        Text("Search Results")
                            .font(RetroTheme.mono(10, weight: .bold))
                            .foregroundStyle(RetroTheme.textTertiary)
                            .tracking(2)
                            .textCase(.uppercase)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                }

                Section {
                    if viewModel.savedLocations.isEmpty {
                        emptyLocationsView
                    } else {
                        ForEach(Array(viewModel.savedLocations.enumerated()), id: \.element.id) { index, location in
                            Button {
                                container.selectedTab = .home
                                Task {
                                    await container.homeViewModel.loadWeather(for: location)
                                }
                            } label: {
                                locationRow(location, index: index)
                            }
                        }
                        .onDelete { offsets in
                            Task { await viewModel.removeLocation(at: offsets) }
                        }
                        .onMove { from, to in
                            Task { await viewModel.moveLocation(from: from, to: to) }
                        }
                    }
                } header: {
                    Text("Saved Places")
                        .font(RetroTheme.mono(10, weight: .bold))
                        .foregroundStyle(RetroTheme.textTertiary)
                        .tracking(2)
                        .textCase(.uppercase)
                }
                .listRowBackground(Color.white.opacity(0.04))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
        }
        .background(
            ZStack {
                RetroTheme.bgDark
                // Subtle ambient blobs
                LiquidBlob(phase: 0)
                    .fill(RetroTheme.accentColor.opacity(0.06))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: 100, y: -200)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        )
        .task {
            await viewModel.loadSavedLocations()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                listAppeared = true
            }
        }
    }

    // MARK: - Location Row

    private func locationRow(_ location: SavedLocation, index: Int) -> some View {
        HStack(spacing: 14) {
            // Gradient avatar circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                RetroTheme.accentColor.opacity(0.15),
                                RetroTheme.accentPurple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(RetroTheme.accentColor.opacity(0.2), lineWidth: 0.5)
                    )

                Image(systemName: "mappin")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(RetroTheme.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(RetroTheme.mono(15, weight: .semibold))
                    .foregroundStyle(RetroTheme.textPrimary)
                Text("\(location.region), \(location.country)")
                    .font(RetroTheme.mono(11))
                    .foregroundStyle(RetroTheme.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(RetroTheme.textTertiary)
        }
        .padding(.vertical, 6)
        .offset(x: listAppeared ? 0 : 40)
        .opacity(listAppeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05), value: listAppeared)
    }

    // MARK: - Empty State

    private var emptyLocationsView: some View {
        VStack(spacing: 20) {
            ZStack {
                BreathingRing(color: RetroTheme.accentColor.opacity(0.2), size: 80)
                BreathingRing(color: RetroTheme.accentPurple.opacity(0.15), size: 60)

                Image(systemName: "globe")
                    .font(.system(size: 32))
                    .foregroundStyle(RetroTheme.textTertiary)
            }
            .frame(height: 90)

            Text("No saved places")
                .font(RetroTheme.mono(16, weight: .semibold))
                .foregroundStyle(RetroTheme.textSecondary)

            Text("Search to add your favorite cities")
                .font(RetroTheme.mono(12))
                .foregroundStyle(RetroTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    // MARK: - Glass Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(RetroTheme.accentColor.opacity(0.6))
                .font(.system(size: 15, weight: .medium))

            TextField("Search city...", text: $viewModel.searchText)
                .font(RetroTheme.mono(14))
                .foregroundStyle(RetroTheme.textPrimary)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.search()
                }

            if viewModel.isSearching {
                ProgressView()
                    .tint(RetroTheme.accentColor)
                    .scaleEffect(0.7)
            }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.searchResults = []
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 22, height: 22)
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(RetroTheme.textTertiary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
