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
    // Onboarding
    var hasCompletedOnboarding: Bool = false
    var name: String = ""

    // Progresso
    var streak: Int = 0
    var level: Int = 1
    var coins: Int = 0
    var xpTotal: Int = 0
    var dailyGoalXP: Int = 50
    var todayXP: Int = 0

    // Notificação diária
    var notificationEnabled: Bool = false
    var notificationHour: Int = 20
    var notificationMinute: Int = 0

    // Modo selecionado
    var selectedPracticeModeRawValue: String = PracticeMode.words.rawValue

    // Progresso missão diária
    var dailyWordsProgress: Int = 0
    var dailyPhrasesProgress: Int = 0
    var dailyScenarioProgress: Int = 0

    // Progresso semanal (0.0...1.0 por dia)
    var weeklyProgress: [String: Double] = [:]

    // Trava bônus missão (1x/dia)
    var lastMissionRewardKey: String? = nil

    // Controle diário / streak
    var lastDailyResetDay: Date? = nil
    var lastStreakDay: Date? = nil
    var lastSessionDay: Date? = nil

    // Badges desbloqueados
    var unlockedBadgeIDs: [String] = []

    // Trilha: nó mais avançado desbloqueado
    var highestPathNodeUnlocked: Int = 1
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
