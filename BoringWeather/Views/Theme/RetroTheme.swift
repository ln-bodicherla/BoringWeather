import SwiftUI

// MARK: - Liquid Glass Theme

enum RetroTheme {

    // MARK: - Colors

    static let bgLight = Color(red: 0.03, green: 0.03, blue: 0.07)
    static let bgDark = Color(red: 0.02, green: 0.02, blue: 0.05)
    static let cardLight = Color.white.opacity(0.07)
    static let cardDark = Color.white.opacity(0.05)
    static let accentColor = Color(red: 0.35, green: 0.78, blue: 1.0)
    static let borderLight = Color.white.opacity(0.15)
    static let borderDark = Color.white.opacity(0.08)

    static let accentPurple = Color(red: 0.65, green: 0.4, blue: 1.0)
    static let accentPink = Color(red: 1.0, green: 0.4, blue: 0.65)
    static let accentGold = Color(red: 1.0, green: 0.82, blue: 0.3)
    static let accentMint = Color(red: 0.3, green: 1.0, blue: 0.75)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.35)

    // MARK: - Gradients

    static let accentGradient = LinearGradient(
        colors: [accentColor, accentPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Fonts

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 14, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 11, weight: .medium, design: .rounded)
    static let temperatureFont = Font.system(size: 96, weight: .ultraLight, design: .rounded)
    static let smallTempFont = Font.system(size: 16, weight: .medium, design: .rounded)

    // MARK: - Card Style

    static let cardCornerRadius: CGFloat = 24
    static let cardPadding: CGFloat = 18
    static let cardBorderWidth: CGFloat = 0.5

    // MARK: - Spacing

    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
}

// MARK: - Liquid Glass Card

struct RetroCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(RetroTheme.cardPadding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius)
                        .fill(Color.white.opacity(0.03))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius))
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct RetroBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(RetroTheme.bgDark)
    }
}

extension View {
    func retroCard() -> some View {
        modifier(RetroCardModifier())
    }

    func retroBackground() -> some View {
        modifier(RetroBackgroundModifier())
    }

    func glowEffect(color: Color = RetroTheme.accentColor, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
    }

    func liquidGlow(color: Color = RetroTheme.accentColor) -> some View {
        self
            .shadow(color: color.opacity(0.5), radius: 12, x: 0, y: 0)
            .shadow(color: color.opacity(0.2), radius: 30, x: 0, y: 5)
    }
}

// MARK: - Animated Liquid Blob

struct LiquidBlob: Shape {
    var phase: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2

        var path = Path()
        let points = 8
        for i in 0..<points {
            let angle = (Double(i) / Double(points)) * 2 * .pi
            let wobble = sin(phase + Double(i) * 1.3) * 0.15 + sin(phase * 0.7 + Double(i) * 0.9) * 0.1
            let radius = r * (1.0 + wobble)
            let x = cx + CGFloat(cos(angle)) * radius
            let y = cy + CGFloat(sin(angle)) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                let prevAngle = (Double(i - 1) / Double(points)) * 2 * .pi
                let prevWobble = sin(phase + Double(i - 1) * 1.3) * 0.15 + sin(phase * 0.7 + Double(i - 1) * 0.9) * 0.1
                let prevRadius = r * (1.0 + prevWobble)
                let cp1x = cx + CGFloat(cos(prevAngle + .pi / Double(points))) * prevRadius * 1.1
                let cp1y = cy + CGFloat(sin(prevAngle + .pi / Double(points))) * prevRadius * 1.1
                let cp2x = cx + CGFloat(cos(angle - .pi / Double(points))) * radius * 1.1
                let cp2y = cy + CGFloat(sin(angle - .pi / Double(points))) * radius * 1.1
                path.addCurve(to: CGPoint(x: x, y: y),
                              control1: CGPoint(x: cp1x, y: cp1y),
                              control2: CGPoint(x: cp2x, y: cp2y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Floating Particle System

struct FloatingParticles: View {
    let count: Int
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<count, id: \.self) { i in
                ParticleDot(
                    color: color,
                    size: CGFloat.random(in: 1.5...4),
                    startX: CGFloat.random(in: 0...geo.size.width),
                    startY: CGFloat.random(in: 0...geo.size.height),
                    duration: Double.random(in: 4...8),
                    delay: Double(i) * 0.3
                )
            }
        }
    }
}

struct ParticleDot: View {
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let startY: CGFloat
    let duration: Double
    let delay: Double

    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size > 3 ? 1 : 0)
            .position(x: startX, y: startY)
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -40...40)
                    )
                    opacity = Double.random(in: 0.3...0.8)
                }
            }
    }
}

// MARK: - Breathing Glow Ring

struct BreathingRing: View {
    let color: Color
    let size: CGFloat
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 1)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    scale = 1.2
                    opacity = 0.05
                }
            }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: geo.size.width * phase)
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            phase = 2
                        }
                    }
                }
                .mask(content)
            )
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
