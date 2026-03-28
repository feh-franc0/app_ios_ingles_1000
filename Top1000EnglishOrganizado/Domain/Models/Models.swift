import SwiftUI
import Foundation

enum PracticeMode: String, CaseIterable, Identifiable {
    case words = "Palavras"
    case phrases = "Frases"
    case scenario = "Cenários"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .words: return "textformat.abc"
        case .phrases: return "quote.bubble.fill"
        case .scenario: return "sparkles.rectangle.stack.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .words: return [AppColors.brandGreen, AppColors.brandBlue]
        case .phrases: return [AppColors.brandPurple, AppColors.brandBlue]
        case .scenario: return [AppColors.brandOrange, AppColors.brandPurple]
        }
    }
}

struct UserState: Codable {
    var name: String = "Franco"
    var streak: Int = 7
    var level: Int = 5
    var coins: Int = 120

    var xpTotal: Int = 1240
    var dailyGoalXP: Int = 50
    var todayXP: Int = 32

    // ✅ modo selecionado pelo usuário
    var selectedPracticeModeRawValue: String = PracticeMode.words.rawValue

    // ✅ progresso real da missão diária
    var dailyWordsProgress: Int = 0
    var dailyPhrasesProgress: Int = 0
    var dailyScenarioProgress: Int = 0

    // ✅ Progresso semanal (0.0 ... 1.0 por dia)
    // chave exemplo: "2026-02-27"
    var weeklyProgress: [String: Double] = [:]

    // ✅ trava pra pagar o bônus da missão 1x por dia
    var lastMissionRewardKey: String? = nil

    // Controle diário / streak
    var lastDailyResetDay: Date? = nil
    var lastStreakDay: Date? = nil
    var lastSessionDay: Date? = nil
}

extension UserState {
    var didWordsToday: Bool { dailyWordsProgress >= 10 }
    var didPhrasesToday: Bool { dailyPhrasesProgress >= 10 }
    var didScenarioToday: Bool { dailyScenarioProgress >= 10 }

    var dailyWordsProgressClamped: Int { min(max(dailyWordsProgress, 0), 10) }
    var dailyPhrasesProgressClamped: Int { min(max(dailyPhrasesProgress, 0), 10) }
    var dailyScenarioProgressClamped: Int { min(max(dailyScenarioProgress, 0), 10) }
}

struct WordItem: Identifiable {
    let id: String
    let en: String
    let pt: String
    let example: String
    let tags: [String]
    let difficulty: Int
}

struct PhraseItem: Identifiable {
    let id: String
    let en: String
    let pt: String
    let tags: [String]
    let difficulty: Int
}

struct ScenarioItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let tags: [String]
}

enum QuestionType {
    case multipleChoice
}

struct Question: Identifiable {
    let id: String
    let type: QuestionType
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let reviewKey: String
}

struct ReviewItem: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let prompt: String
    let correct: String
    let hint: String
}
