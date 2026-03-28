import SwiftUI

enum AppColors {
    // ✅ Paleta “gruda no app” (viva, mas premium)
    static let brandGreen  = Color(red: 0.10, green: 0.84, blue: 0.42) // sucesso
    static let brandBlue   = Color(red: 0.12, green: 0.62, blue: 1.00) // ação/CTA
    static let brandPurple = Color(red: 0.62, green: 0.36, blue: 0.98) // progresso/nível
    static let brandOrange = Color(red: 1.00, green: 0.64, blue: 0.22) // “reward”
    static let brandRed    = Color(red: 0.98, green: 0.25, blue: 0.30)

    // ✅ Reward (moedas)
    static let gold = Color(red: 1.00, green: 0.84, blue: 0.20)

    // ✅ Superfícies (glass)
    static let card   = Color(.secondarySystemBackground).opacity(0.92)
    static let stroke = Color.white.opacity(0.12)

    // ✅ Neutros úteis
    static let softGray = Color.white.opacity(0.08)
    
    static let heroNavy  = Color(red: 0.03, green: 0.09, blue: 0.20)
    static let heroNavy2 = Color(red: 0.05, green: 0.16, blue: 0.32)
}
