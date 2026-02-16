import SwiftUI

// MARK: - Section Header

struct RetroSectionHeader: View {
    let title: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Text("[ \(title) ]")
                .font(RetroTheme.headlineFont)
                .foregroundStyle(textColor)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var textColor: Color {
        colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8)
    }
}

// MARK: - Detail Row

struct RetroDetailRow: View {
    let label: String
    let value: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(RetroTheme.accentColor)
                .frame(width: 20)
            Text(label)
                .font(RetroTheme.bodyFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
            Spacer()
            Text(value)
                .font(RetroTheme.bodyFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Retro Loading Screen

struct RetroSkeletonView: View {
    @State private var visibleLines = 0
    @State private var cursorVisible = true
    @Environment(\.colorScheme) var colorScheme

    private let lines = [
        "> BORINGWEATHER v1.0",
        "> Initializing weather module...",
        "> Requesting GPS coordinates...",
        "> Connecting to Open-Meteo...",
        "> Fetching forecast data...",
        "> Parsing atmospheric readings...",
        "> Loading hourly forecast...",
        "> Rendering display...",
        ""
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
                .frame(height: 40)

            ForEach(0..<min(visibleLines, lines.count), id: \.self) { index in
                Text(lines[index])
                    .font(RetroTheme.mono(13))
                    .foregroundStyle(lineColor(for: index))
            }

            // Blinking cursor
            if visibleLines < lines.count {
                HStack(spacing: 0) {
                    Text("> ")
                        .font(RetroTheme.mono(13))
                        .foregroundStyle(RetroTheme.accentColor)
                    Rectangle()
                        .fill(RetroTheme.accentColor)
                        .frame(width: 8, height: 14)
                        .opacity(cursorVisible ? 1 : 0)
                }
            }

            Spacer()

            // Progress bar
            HStack(spacing: 4) {
                Text("[")
                    .font(RetroTheme.mono(12))
                    .foregroundStyle(dimColor)

                GeometryReader { geo in
                    let progress = min(CGFloat(visibleLines) / CGFloat(lines.count), 1.0)
                    let filledWidth = geo.size.width * progress

                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(dimColor.opacity(0.2))
                        Rectangle()
                            .fill(RetroTheme.accentColor.opacity(0.6))
                            .frame(width: filledWidth)
                    }
                }
                .frame(height: 8)
                .clipShape(Rectangle())

                Text("]")
                    .font(RetroTheme.mono(12))
                    .foregroundStyle(dimColor)

                Text("\(min(visibleLines * 100 / max(lines.count, 1), 100))%")
                    .font(RetroTheme.mono(11))
                    .foregroundStyle(dimColor)
                    .frame(width: 36, alignment: .trailing)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .onAppear {
            startTyping()
            startCursorBlink()
        }
    }

    private func lineColor(for index: Int) -> Color {
        if index == 0 {
            return RetroTheme.accentColor
        }
        return colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5)
    }

    private var dimColor: Color {
        colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.25)
    }

    private func startTyping() {
        for i in 1...lines.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation(.none) {
                    visibleLines = i
                }
            }
        }
    }

    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            cursorVisible.toggle()
        }
    }
}

// MARK: - Error State

struct RetroErrorView: View {
    let message: String
    let retryAction: () async -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Text("--- ERROR ---")
                .font(RetroTheme.headlineFont)
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            Text(message)
                .font(RetroTheme.bodyFont)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task { await retryAction() }
            } label: {
                Text("[ RETRY ]")
                    .font(RetroTheme.bodyFont)
                    .foregroundStyle(RetroTheme.accentColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(RetroTheme.accentColor, lineWidth: 1)
                    )
            }
        }
        .padding()
    }
}

// MARK: - Offline Banner

struct RetroOfflineBanner: View {
    let lastUpdated: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 12))
            Text("OFFLINE")
                .font(RetroTheme.captionFont)
            Text("•")
            Text(lastUpdated)
                .font(RetroTheme.captionFont)
        }
        .foregroundStyle(RetroTheme.accentColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(RetroTheme.accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(RetroTheme.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Custom Navigation Bar

struct RetroNavBar<Leading: View, Trailing: View>: View {
    let title: String
    let leading: Leading
    let trailing: Trailing
    @Environment(\.colorScheme) var colorScheme

    init(
        title: String,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                leading
                    .frame(width: 44, alignment: .leading)

                Spacer()

                Text(title)
                    .font(RetroTheme.mono(16, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)

                Spacer()

                trailing
                    .frame(width: 44, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight)

            Rectangle()
                .fill(colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight)
                .frame(height: 1)
        }
    }
}

// MARK: - Divider

struct RetroDivider: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight)
            .frame(height: 1)
    }
}
