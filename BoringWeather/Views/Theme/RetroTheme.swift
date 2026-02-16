import SwiftUI

// MARK: - Retro / Nostalgic / "Boring" Theme

enum RetroTheme {

    // MARK: - Colors

    static let bgLight = Color(red: 0.96, green: 0.94, blue: 0.90)       // warm cream
    static let bgDark = Color(red: 0.11, green: 0.11, blue: 0.12)        // near-black
    static let cardLight = Color(red: 0.99, green: 0.97, blue: 0.93)     // off-white
    static let cardDark = Color(red: 0.17, green: 0.17, blue: 0.18)      // dark gray
    static let accentColor = Color(red: 0.72, green: 0.45, blue: 0.20)   // warm amber/brown
    static let borderLight = Color(red: 0.82, green: 0.78, blue: 0.72)   // muted tan
    static let borderDark = Color(red: 0.30, green: 0.30, blue: 0.30)    // dim gray

    // MARK: - Fonts

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static let titleFont = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let headlineFont = Font.system(size: 18, weight: .semibold, design: .monospaced)
    static let bodyFont = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let captionFont = Font.system(size: 11, weight: .regular, design: .monospaced)
    static let temperatureFont = Font.system(size: 72, weight: .thin, design: .monospaced)
    static let smallTempFont = Font.system(size: 16, weight: .medium, design: .monospaced)

    // MARK: - Card Style

    static let cardCornerRadius: CGFloat = 4
    static let cardPadding: CGFloat = 16
    static let cardBorderWidth: CGFloat = 1

    // MARK: - Spacing

    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
}

// MARK: - View Modifiers

struct RetroCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(RetroTheme.cardPadding)
            .background(cardColor)
            .overlay(
                RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius)
                    .stroke(borderColor, lineWidth: RetroTheme.cardBorderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: RetroTheme.cardCornerRadius))
    }

    private var cardColor: Color {
        colorScheme == .dark ? RetroTheme.cardDark : RetroTheme.cardLight
    }

    private var borderColor: Color {
        colorScheme == .dark ? RetroTheme.borderDark : RetroTheme.borderLight
    }
}

struct RetroBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? RetroTheme.bgDark : RetroTheme.bgLight)
    }
}

extension View {
    func retroCard() -> some View {
        modifier(RetroCardModifier())
    }

    func retroBackground() -> some View {
        modifier(RetroBackgroundModifier())
    }
}
