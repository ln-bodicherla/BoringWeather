import SwiftUI

struct LocationsView: View {
    @ObservedObject var viewModel: LocationsViewModel
    @EnvironmentObject var container: DIContainer
    @Environment(\.colorScheme) var colorScheme
    @State private var editMode: EditMode = .inactive

    var body: some View {
        VStack(spacing: 0) {
            RetroNavBar(title: "Locations") {
                EmptyView()
            } trailing: {
                if !viewModel.savedLocations.isEmpty {
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Edit")
                            .font(RetroTheme.bodyFont)
                            .foregroundStyle(RetroTheme.accentColor)
                    }
                }
            }

            // Search bar
            searchBar

            // Content
            List {
                // Search results
                if !viewModel.searchResults.isEmpty {
                    Section {
                        ForEach(viewModel.searchResults) { result in
                            Button {
                                Task {
                                    await viewModel.addLocation(result)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.name)
                                            .font(RetroTheme.mono(14, weight: .semibold))
                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        Text("\(result.region), \(result.country)")
                                            .font(RetroTheme.captionFont)
                                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(RetroTheme.accentColor)
                                }
                            }
                        }
                    } header: {
                        Text("[ SEARCH RESULTS ]")
                            .font(RetroTheme.captionFont)
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                    }
                    .listRowBackground(colorScheme == .dark ? RetroTheme.cardDark : RetroTheme.cardLight)
                }

                // Saved locations
                Section {
                    if viewModel.savedLocations.isEmpty {
                        Text("No saved locations yet.\nSearch above to add cities.")
                            .font(RetroTheme.bodyFont)
                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        ForEach(viewModel.savedLocations) { location in
                            Button {
                                container.selectedTab = .home
                                Task {
                                    await container.homeViewModel.loadWeather(for: location)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(location.name)
                                            .font(RetroTheme.mono(14, weight: .semibold))
                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        Text("\(location.region), \(location.country)")
                                            .font(RetroTheme.captionFont)
                                            .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.2))
                                }
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
                    Text("[ SAVED LOCATIONS ]")
                        .font(RetroTheme.captionFont)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.4))
                }
                .listRowBackground(colorScheme == .dark ? RetroTheme.cardDark : RetroTheme.cardLight)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
        }
        .background(colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight)
        .task {
            await viewModel.loadSavedLocations()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                .font(.system(size: 14))

            TextField("Search city...", text: $viewModel.searchText)
                .font(RetroTheme.bodyFont)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.search()
                }

            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(0.7)
            }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? RetroTheme.cardDark : RetroTheme.cardLight)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
