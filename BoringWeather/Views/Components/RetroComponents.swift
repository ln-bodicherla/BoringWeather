import SwiftUI

// MARK: - Section Header

struct RetroSectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(RetroTheme.mono(12, weight: .bold))
                .foregroundStyle(RetroTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(3)

            // Animated gradient line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [RetroTheme.accentColor.opacity(0.5), RetroTheme.accentPurple.opacity(0.2), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Detail Row

struct RetroDetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(RetroTheme.accentColor)
                .frame(width: 20)
            Text(label)
                .font(RetroTheme.bodyFont)
                .foregroundStyle(RetroTheme.textSecondary)
            Spacer()
            Text(value)
                .font(RetroTheme.bodyFont)
                .foregroundStyle(RetroTheme.textPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Liquid Loading Screen

struct RetroSkeletonView: View {
    @State private var blobPhase: Double = 0
    @State private var ringScale: [CGFloat] = [0.5, 0.5, 0.5]
    @State private var ringOpacity: [Double] = [0, 0, 0]
    @State private var textOpacity: Double = 0
    @State private var dotCount = 0
    @State private var progressWidth: CGFloat = 0

    var body: some View {
        ZStack {
            // Floating particles behind everything
            FloatingParticles(count: 15, color: RetroTheme.accentColor.opacity(0.5))
                .allowsHitTesting(false)

            VStack(spacing: 32) {
                Spacer()

                // Central liquid blob with rings
                ZStack {
                    // Expanding rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(
                                RetroTheme.accentColor.opacity(0.3),
                                lineWidth: 0.8
                            )
                            .frame(width: CGFloat(80 + i * 40), height: CGFloat(80 + i * 40))
                            .scaleEffect(ringScale[i])
                            .opacity(ringOpacity[i])
                    }

                    // Liquid blob
                    LiquidBlob(phase: blobPhase)
                        .fill(
                            RadialGradient(
                                colors: [
                                    RetroTheme.accentColor.opacity(0.6),
                                    RetroTheme.accentPurple.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 8)

                    // Inner glow
                    LiquidBlob(phase: blobPhase + 1.5)
                        .fill(RetroTheme.accentColor.opacity(0.4))
                        .frame(width: 40, height: 40)
                        .blur(radius: 4)

                    // Center bright dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                        .liquidGlow(color: RetroTheme.accentColor)
                }
                .frame(height: 200)

                // Status text
                VStack(spacing: 10) {
                    Text("SYNCING")
                        .font(RetroTheme.mono(16, weight: .bold))
                        .foregroundStyle(RetroTheme.textPrimary)
                        .tracking(6)
                        .opacity(textOpacity)

                    HStack(spacing: 2) {
                        Text("Fetching atmospheric data")
                            .font(RetroTheme.mono(12))
                            .foregroundStyle(RetroTheme.textTertiary)
                        ForEach(0..<3, id: \.self) { i in
                            Text(".")
                                .font(RetroTheme.mono(12))
                                .foregroundStyle(RetroTheme.textTertiary)
                                .opacity(dotCount > i ? 1 : 0)
                        }
                    }
                    .opacity(textOpacity)
                }

                // Glass progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(height: 4)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RetroTheme.accentColor, RetroTheme.accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progressWidth * geo.size.width, height: 4)
                            .liquidGlow(color: RetroTheme.accentColor)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 50)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Blob animation
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                blobPhase = .pi * 2
            }

            // Ring pulses
            for i in 0..<3 {
                withAnimation(
                    .easeOut(duration: 2)
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 0.6)
                ) {
                    ringScale[i] = 1.5
                    ringOpacity[i] = 0
                }
                // Set initial visible state
                ringOpacity[i] = 0.5
            }

            // Text fade in
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1
            }

            // Loading dots
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    dotCount = (dotCount + 1) % 4
                }
            }

            // Progress bar
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                progressWidth = 0.85
            }
        }
    }
}

// MARK: - Error State

struct RetroErrorView: View {
    let message: String
    let retryAction: () async -> Void
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Pulsing background
                Circle()
                    .fill(RetroTheme.accentPink.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulse ? 1.2 : 0.9)

                Circle()
                    .fill(RetroTheme.accentPink.opacity(0.05))
                    .frame(width: 70, height: 70)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(RetroTheme.accentPink)
                    .liquidGlow(color: RetroTheme.accentPink)
            }

            Text("Connection Lost")
                .font(RetroTheme.mono(20, weight: .bold))
                .foregroundStyle(RetroTheme.textPrimary)
                .tracking(1)

            Text(message)
                .font(RetroTheme.mono(13))
                .foregroundStyle(RetroTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                Task { await retryAction() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .bold))
                    Text("Try Again")
                        .font(RetroTheme.mono(14, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .fill(RetroTheme.accentGradient.opacity(0.5))
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(RetroTheme.accentColor.opacity(0.3), lineWidth: 0.5)
                )
                .liquidGlow(color: RetroTheme.accentColor)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Offline Banner

struct RetroOfflineBanner: View {
    let lastUpdated: String
    @State private var blink = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(RetroTheme.accentPink)
                .frame(width: 5, height: 5)
                .opacity(blink ? 1 : 0.3)

            Image(systemName: "wifi.slash")
                .font(.system(size: 10))
            Text("Offline")
                .font(RetroTheme.mono(11, weight: .medium))
            Text("·")
            Text(lastUpdated)
                .font(RetroTheme.mono(10))
        }
        .foregroundStyle(RetroTheme.textSecondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .stroke(RetroTheme.accentPink.opacity(0.25), lineWidth: 0.5)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                blink = true
            }
        }
    }
}

// MARK: - Custom Navigation Bar

struct RetroNavBar<Leading: View, Trailing: View>: View {
    let title: String
    let leading: Leading
    let trailing: Trailing

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
                    .font(RetroTheme.mono(17, weight: .bold))
                    .foregroundStyle(RetroTheme.textPrimary)
                    .tracking(2)

                Spacer()

                trailing
                    .frame(width: 44, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RetroTheme.bgDark.opacity(0.7)
                        .background(.ultraThinMaterial.opacity(0.5))
                }
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            RetroTheme.accentColor.opacity(0.2),
                            RetroTheme.accentPurple.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
    }
}

// MARK: - Divider

struct RetroDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color.white.opacity(0.08), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 0.5)
    }
}
