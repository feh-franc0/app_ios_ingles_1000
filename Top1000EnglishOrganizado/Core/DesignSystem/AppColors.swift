import SwiftUI

enum AppColors {
    // ─── Brand primárias ──────────────────────────────────────────
    static let brandGreen  = Color(red: 0.08, green: 0.82, blue: 0.42)  // sucesso / acerto
    static let brandBlue   = Color(red: 0.12, green: 0.55, blue: 0.98)  // ação / CTA
    static let brandPurple = Color(red: 0.58, green: 0.30, blue: 0.98)  // progresso / nível
    static let brandOrange = Color(red: 1.00, green: 0.58, blue: 0.14)  // reward / conversação
    static let brandRed    = Color(red: 0.98, green: 0.22, blue: 0.28)  // erro / vida perdida
    static let gold        = Color(red: 1.00, green: 0.82, blue: 0.15)  // moedas / streak

    // ─── Hero / fundo escuro ──────────────────────────────────────
    static let heroNavy  = Color(red: 0.04, green: 0.08, blue: 0.18)
    static let heroNavy2 = Color(red: 0.06, green: 0.14, blue: 0.30)
    static let heroSlate = Color(red: 0.10, green: 0.18, blue: 0.36)

    // ─── Superfícies ──────────────────────────────────────────────
    static let card      = Color(.secondarySystemBackground).opacity(0.92)
    static let stroke    = Color.white.opacity(0.12)
    static let softGray  = Color.black.opacity(0.06)

    // ─── Gradientes prontos ───────────────────────────────────────
    static let heroGradient = LinearGradient(
        colors: [heroNavy, heroSlate],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let ctaGradient = LinearGradient(
        colors: [brandBlue, brandPurple],
        startPoint: .leading, endPoint: .trailing
    )

    static let greenGradient = LinearGradient(
        colors: [brandGreen, Color(red: 0.00, green: 0.72, blue: 0.72)],
        startPoint: .leading, endPoint: .trailing
    )

    static let purpleGradient = LinearGradient(
        colors: [brandPurple, Color(red: 0.30, green: 0.14, blue: 0.72)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [gold, brandOrange],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // ─── Tipografia helpers ───────────────────────────────────────
    static let textPrimary   = Color.primary
    static let textSecondary = Color.secondary
    static let textOnDark    = Color.white
}

// MARK: - Hex init
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}
