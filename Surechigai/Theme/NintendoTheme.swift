import SwiftUI

enum NintendoTheme {
    static let streetPassGreen = Color(red: 0.18, green: 0.88, blue: 0.52)
    static let streetPassGlow = Color(red: 0.45, green: 1.0, blue: 0.72)
    static let nintendoRed = Color(red: 0.9, green: 0.0, blue: 0.07)
    static let nintendoYellow = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let skyTop = Color(red: 0.22, green: 0.55, blue: 0.98)
    static let skyBottom = Color(red: 0.08, green: 0.22, blue: 0.62)
    static let cardSurface = Color.white.opacity(0.14)
    static let cardBorder = Color.white.opacity(0.35)

    static let homeBackground = LinearGradient(
        colors: [skyTop, skyBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let stepNumberGradient = LinearGradient(
        colors: [.white, streetPassGlow],
        startPoint: .top,
        endPoint: .bottom
    )

    static let radarRingGradient = LinearGradient(
        colors: [streetPassGlow.opacity(0.9), streetPassGreen.opacity(0.2)],
        startPoint: .top,
        endPoint: .bottom
    )
}
