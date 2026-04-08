import SwiftUI
import Foundation

// ─────────────────────────────────────────────────────────────────────
// MARK: - PracticeMode
// ─────────────────────────────────────────────────────────────────────

enum PracticeMode: String, CaseIterable, Identifiable {
    case words    = "Palavras"
    case phrases  = "Frases"
    case scenario = "Cenários"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .words:    return "textformat.abc"
        case .phrases:  return "quote.bubble.fill"
        case .scenario: return "sparkles.rectangle.stack.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .words:    return [AppColors.brandGreen, AppColors.brandBlue]
        case .phrases:  return [AppColors.brandPurple, AppColors.brandBlue]
        case .scenario: return [AppColors.brandOrange, AppColors.brandPurple]
        }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Word Mastery (5 níveis por palavra)
// ─────────────────────────────────────────────────────────────────────

enum MasteryLevel: Int, Codable, CaseIterable {
    case seen       = 0   // Visto
    case recognizes = 1   // Reconhece
    case remembers  = 2   // Lembra
    case uses       = 3   // Usa
    case mastered   = 4   // Domina ⭐

    var label: String {
        switch self {
        case .seen:       return "Visto"
        case .recognizes: return "Reconhece"
        case .remembers:  return "Lembra"
        case .uses:       return "Usa"
        case .mastered:   return "Domina"
        }
    }

    var color: Color {
        switch self {
        case .seen:       return Color.gray.opacity(0.50)
        case .recognizes: return AppColors.brandBlue
        case .remembers:  return AppColors.brandPurple
        case .uses:       return AppColors.brandOrange
        case .mastered:   return AppColors.brandGreen
        }
    }

    var emoji: String {
        switch self {
        case .seen:       return "👁"
        case .recognizes: return "🔵"
        case .remembers:  return "💡"
        case .uses:       return "⚡️"
        case .mastered:   return "⭐️"
        }
    }
}

struct WordMastery: Codable, Identifiable {
    var id: String          // chave da palavra/frase (word.id)
    var level: MasteryLevel = .seen
    var correctStreak: Int  = 0   // acertos consecutivos no nível atual
    var totalCorrect: Int   = 0
    var totalAttempts: Int  = 0
    var lastSeen: Date?     = nil

    /// Quantos acertos certos precisamos para subir de nível
    static let correctsToLevelUp = 3

    mutating func recordCorrect() {
        totalAttempts += 1
        totalCorrect  += 1
        correctStreak += 1
        lastSeen = Date()

        if correctStreak >= WordMastery.correctsToLevelUp, level.rawValue < MasteryLevel.mastered.rawValue {
            level = MasteryLevel(rawValue: level.rawValue + 1) ?? .mastered
            correctStreak = 0
        }
    }

    mutating func recordWrong() {
        totalAttempts += 1
        correctStreak  = 0
        lastSeen = Date()

        // Rebaixa um nível (mas não abaixo de seen)
        if level.rawValue > MasteryLevel.seen.rawValue {
            level = MasteryLevel(rawValue: level.rawValue - 1) ?? .seen
        }
    }

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalAttempts)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Streak Freeze
// ─────────────────────────────────────────────────────────────────────

struct StreakFreeze: Codable {
    var count: Int = 0
    var usedDates: [Date] = []
    static let coinCost = 50
    static let maxStock = 3
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Prestige Titles
// ─────────────────────────────────────────────────────────────────────

struct AppTitle: Identifiable, Codable {
    let id: String
    let name: String          // "Caçador de Palavras"
    let requirement: String   // descrição para UI
    let emoji: String
    let rarity: BadgeRarity
}

extension AppTitle {
    static let all: [AppTitle] = [
        AppTitle(id: "beginner",         name: "Iniciante",              requirement: "Começou a jornada",              emoji: "🌱", rarity: .common),
        AppTitle(id: "word_hunter",      name: "Caçador de Palavras",    requirement: "Domine 50 palavras",             emoji: "🎯", rarity: .common),
        AppTitle(id: "phrase_master",    name: "Mestre das Frases",      requirement: "Complete 10 sessões de frases",  emoji: "💬", rarity: .rare),
        AppTitle(id: "streak_warrior",   name: "Guerreiro da Sequência", requirement: "Streak de 7 dias",               emoji: "🔥", rarity: .rare),
        AppTitle(id: "perfectionist",    name: "Perfeccionista",         requirement: "10 sessões sem errar",           emoji: "💎", rarity: .epic),
        AppTitle(id: "boss_slayer",      name: "Mata-Bosses",            requirement: "Derrote 3 bosses",               emoji: "⚔️", rarity: .epic),
        AppTitle(id: "speed_demon",      name: "Speed Demon",            requirement: "100+ pts no Speed Run",          emoji: "⚡️", rarity: .epic),
        AppTitle(id: "legend",           name: "Lenda do Inglês",        requirement: "Streak de 30 dias",              emoji: "👑", rarity: .legendary),
        AppTitle(id: "thousand_master",  name: "Mestre das 1000",        requirement: "Domine 500 palavras",            emoji: "🏆", rarity: .legendary),
    ]
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Badge Rarity
// ─────────────────────────────────────────────────────────────────────

enum BadgeRarity: String, Codable, CaseIterable {
    case common, rare, epic, legendary

    var label: String {
        switch self {
        case .common:    return "Comum"
        case .rare:      return "Raro"
        case .epic:      return "Épico"
        case .legendary: return "Lendário"
        }
    }

    var color: Color {
        switch self {
        case .common:    return Color.gray
        case .rare:      return AppColors.brandBlue
        case .epic:      return AppColors.brandPurple
        case .legendary: return AppColors.gold
        }
    }

    var gradient: [Color] {
        switch self {
        case .common:    return [Color.gray, Color.gray.opacity(0.70)]
        case .rare:      return [AppColors.brandBlue, AppColors.brandPurple]
        case .epic:      return [AppColors.brandPurple, Color(red: 0.80, green: 0.20, blue: 0.90)]
        case .legendary: return [AppColors.gold, AppColors.brandOrange]
        }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Reward Chest Loot
// ─────────────────────────────────────────────────────────────────────

enum ChestTier: String {
    case bronze, silver, gold, legendary

    var emoji: String {
        switch self {
        case .bronze:    return "📦"
        case .silver:    return "🗝️"
        case .gold:      return "💰"
        case .legendary: return "🏆"
        }
    }

    var gradient: [Color] {
        switch self {
        case .bronze:    return [Color(red: 0.72, green: 0.45, blue: 0.20), Color(red: 0.55, green: 0.30, blue: 0.10)]
        case .silver:    return [Color.gray, Color(red: 0.55, green: 0.55, blue: 0.60)]
        case .gold:      return [AppColors.gold, AppColors.brandOrange]
        case .legendary: return [AppColors.brandPurple, AppColors.gold]
        }
    }
}

struct ChestReward {
    let tier: ChestTier
    let xpBonus: Int
    let coinBonus: Int
    let freezeBonus: Int          // streak freezes ganhos
    let titleUnlocked: AppTitle?  // título especial (raro)
    let message: String

    static func generate(accuracy: Double, streak: Int, isPerfect: Bool) -> ChestReward {
        if isPerfect && streak >= 7 {
            return ChestReward(tier: .legendary, xpBonus: 50, coinBonus: 100, freezeBonus: 1,
                               titleUnlocked: nil,
                               message: "Incrível! Sessão perfeita com streak ativo!")
        } else if isPerfect {
            return ChestReward(tier: .gold, xpBonus: 30, coinBonus: 60, freezeBonus: 0,
                               titleUnlocked: nil,
                               message: "Sessão perfeita! Zero erros 🎯")
        } else if accuracy >= 0.80 {
            return ChestReward(tier: .silver, xpBonus: 15, coinBonus: 30, freezeBonus: 0,
                               titleUnlocked: nil,
                               message: "Ótimo resultado! Acima de 80%")
        } else {
            return ChestReward(tier: .bronze, xpBonus: 5, coinBonus: 10, freezeBonus: 0,
                               titleUnlocked: nil,
                               message: "Continue praticando para evoluir!")
        }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Speed Run Record
// ─────────────────────────────────────────────────────────────────────

struct SpeedRecord: Codable {
    var bestScore: Int   = 0   // maior pontuação no Speed Run
    var totalRuns: Int   = 0
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Boss Battle
// ─────────────────────────────────────────────────────────────────────

struct BossData {
    let id: String
    let name: String
    let emoji: String
    let hp: Int           // vidas do boss
    let description: String
    let chapterGradient: [Color]
}

extension BossData {
    static let all: [BossData] = [
        BossData(id: "boss_1", name: "The Basics Titan",   emoji: "🐉", hp: 15, description: "Guardião das 100 primeiras palavras",     chapterGradient: [AppColors.brandGreen, Color(red: 0.00, green: 0.72, blue: 0.72)]),
        BossData(id: "boss_2", name: "The Phrase Demon",   emoji: "👹", hp: 15, description: "Mestre das frases do cotidiano",           chapterGradient: [AppColors.brandBlue, AppColors.brandPurple]),
        BossData(id: "boss_3", name: "The Vocab Wraith",   emoji: "💀", hp: 20, description: "Vocabulário intermediário avançado",       chapterGradient: [AppColors.brandPurple, Color(red: 0.80, green: 0.20, blue: 0.90)]),
        BossData(id: "boss_4", name: "The Fluency God",    emoji: "⚡️", hp: 25, description: "O desafio final — fluência total",        chapterGradient: [AppColors.brandOrange, Color(red: 0.90, green: 0.20, blue: 0.30)]),
    ]
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - UserState
// ─────────────────────────────────────────────────────────────────────

struct UserState: Codable {
    // Onboarding
    var hasCompletedOnboarding: Bool = false
    var name: String = ""

    // Progresso
    var streak: Int     = 0
    var level: Int      = 1
    var coins: Int      = 0
    var xpTotal: Int    = 0
    var dailyGoalXP: Int = 50
    var todayXP: Int    = 0

    // Vidas (corações)
    var lives: Int      = 5
    var maxLives: Int   = 5
    var livesLastRechargeDate: Date? = nil

    // Streak Freeze
    var streakFreeze: StreakFreeze = StreakFreeze()

    // Notificação diária
    var notificationEnabled: Bool  = false
    var notificationHour: Int      = 20
    var notificationMinute: Int    = 0

    // Modo selecionado
    var selectedPracticeModeRawValue: String = PracticeMode.words.rawValue

    // Progresso missão diária
    var dailyWordsProgress: Int    = 0
    var dailyPhrasesProgress: Int  = 0
    var dailyScenarioProgress: Int = 0

    // Progresso semanal (0.0...1.0 por dia)
    var weeklyProgress: [String: Double] = [:]

    // Trava bônus missão (1x/dia)
    var lastMissionRewardKey: String? = nil

    // Controle diário / streak
    var lastDailyResetDay: Date? = nil
    var lastStreakDay: Date?     = nil
    var lastSessionDay: Date?   = nil

    // Badges desbloqueados
    var unlockedBadgeIDs: [String] = []

    // Títulos
    var unlockedTitleIDs: [String]  = ["beginner"]
    var equippedTitleID: String     = "beginner"

    // Word Mastery (dicionário key→mastery)
    var wordMasteries: [String: WordMastery] = [:]

    // Speed Run record
    var speedRecord: SpeedRecord = SpeedRecord()

    // Boss battles vencidos
    var defeatedBossIDs: [String] = []

    // Sessões perfeitas (100% acerto)
    var perfectSessionCount: Int = 0

    // Trilha: nó mais avançado desbloqueado
    var highestPathNodeUnlocked: Int = 1
}

extension UserState {
    var didWordsToday: Bool    { dailyWordsProgress    >= 10 }
    var didPhrasesToday: Bool  { dailyPhrasesProgress  >= 10 }
    var didScenarioToday: Bool { dailyScenarioProgress >= 10 }

    var dailyWordsProgressClamped: Int    { min(max(dailyWordsProgress, 0), 10) }
    var dailyPhrasesProgressClamped: Int  { min(max(dailyPhrasesProgress, 0), 10) }
    var dailyScenarioProgressClamped: Int { min(max(dailyScenarioProgress, 0), 10) }

    /// Total de palavras/frases com mastery ≥ .remembers (conta como "aprendida")
    var totalWordsLearned: Int {
        wordMasteries.values.filter { $0.level.rawValue >= MasteryLevel.remembers.rawValue }.count
    }

    /// Total com mastery == .mastered
    var totalWordsMastered: Int {
        wordMasteries.values.filter { $0.level == .mastered }.count
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - Existing content models (unchanged)
// ─────────────────────────────────────────────────────────────────────

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
