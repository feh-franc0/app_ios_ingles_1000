import Combine
import Foundation

final class AppStore: ObservableObject {
    @Published var user: UserState {
        didSet {
            guard !isLoading else { return }
            persistUser()
        }
    }

    @Published var content = ContentRepository()
    @Published var reviewPool: [ReviewItem] = []
    @Published var reviewPoolTotal: Int = 0  // cresce a cada erro, zera quando pool esvazia

    /// Quantos itens foram acertados na revisão até agora (neste ciclo)
    var reviewClearedCount: Int { max(0, reviewPoolTotal - reviewPool.count) }

    var selectedPracticeMode: PracticeMode {
        get {
            PracticeMode(rawValue: user.selectedPracticeModeRawValue) ?? .words
        }
        set {
            user.selectedPracticeModeRawValue = newValue.rawValue
        }
    }
    
    var sessionQuestionCount: Int {
        user.level < 10 ? 25 : 50
    }

    func isModeUnlocked(_ mode: PracticeMode) -> Bool {
        switch mode {
        case .words, .phrases:
            return true
        case .scenario:
            return user.level >= 10
        }
    }

    private let storageKey = "top1000_user_state_v1"
    private let calendar = Calendar.current
    private var isLoading = false

    // DateFormatter cache (evita custo repetido)
    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        self.user = UserState()
        isLoading = true
        loadUser()
        refreshDailyIfNeeded()
        isLoading = false
    }

    // MARK: - Onboarding

    func completeOnboarding(name: String, dailyGoal: Int, level: Int) {
        user.name = name
        user.dailyGoalXP = dailyGoal
        user.level = level
        user.xpTotal = level > 1 ? (level - 1) * 250 : 0
        user.hasCompletedOnboarding = true
        Haptics.success()
    }

    // MARK: - Badges

    func unlockBadge(_ id: String) {
        guard !user.unlockedBadgeIDs.contains(id) else { return }
        user.unlockedBadgeIDs.append(id)
        Haptics.success()
    }

    func checkAndUnlockBadges() {
        // Streak badges
        if user.streak >= 3  { unlockBadge("streak_3") }
        if user.streak >= 7  { unlockBadge("streak_7") }
        if user.streak >= 30 { unlockBadge("streak_30") }

        // Nível badges
        if user.level >= 5  { unlockBadge("level_5") }
        if user.level >= 10 { unlockBadge("level_10") }
        if user.level >= 20 { unlockBadge("level_20") }

        // XP badges
        if user.xpTotal >= 1000  { unlockBadge("xp_1000") }
        if user.xpTotal >= 5000  { unlockBadge("xp_5000") }
        if user.xpTotal >= 10000 { unlockBadge("xp_10000") }

        // Missão completa
        if dailyMissionIsComplete { unlockBadge("mission_complete") }
    }

    // MARK: - Review

    func addReview(_ item: ReviewItem) {
        if !reviewPool.contains(where: { $0.key == item.key }) {
            reviewPool.insert(item, at: 0)
            reviewPoolTotal += 1
        }
        if reviewPool.count > 50 { reviewPool = Array(reviewPool.prefix(50)) }
    }

    func removeReviewItems(keys: [String]) {
        reviewPool.removeAll { keys.contains($0.key) }
        // Zera o ciclo quando o pool está totalmente limpo
        if reviewPool.isEmpty { reviewPoolTotal = 0 }
    }

    // MARK: - Missão diária (UX)

    var dailyMissionStepsDone: Int {
        var n = 0
        if user.dailyWordsProgress >= sessionQuestionCount { n += 1 }
        if user.dailyPhrasesProgress >= sessionQuestionCount { n += 1 }
        if user.dailyScenarioProgress >= sessionQuestionCount { n += 1 }
        return n
    }

    var dailyMissionProgress: Double {
        Double(dailyMissionStepsDone) / 3.0 // 0.0 ... 1.0
    }

    var dailyMissionIsComplete: Bool {
        dailyMissionStepsDone == 3
    }

    /// Qual etapa vem agora (pra UI decidir o CTA)
    var nextDailyMissionStage: PracticeMode {
        if user.dailyWordsProgress < sessionQuestionCount { return .words }
        if user.dailyPhrasesProgress < sessionQuestionCount { return .phrases }
        return .scenario
    }

    // MARK: - Meta semanal (bolinhas)

    /// Retorna 7 valores (0.0 a 1.0) do progresso por dia na semana atual.
    func weeklyDots() -> [Double] {
        let start = startOfWeek(Date())
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            let key = dayKey(day)
            return clamp01(user.weeklyProgress[key] ?? 0.0)
        }
    }

    // MARK: - Session Commit (XP + coins + streak + level)

    /// Mantém compatibilidade com o que você já chama hoje.
    func completeSession(xpGained: Int, correctRate: Double) {
        refreshDailyIfNeeded()
        applyStreakIfNeeded()

        // XP
        user.xpTotal += xpGained
        user.todayXP = min(user.dailyGoalXP, user.todayXP + xpGained)

        // Coins (recompensa + bônus)
        let baseCoins = max(1, Int(Double(xpGained) * 0.20))
        var bonus = 0
        if correctRate >= 0.80 { bonus += 10 }
        if correctRate >= 1.00 { bonus += 20 }
        user.coins += (baseCoins + bonus)

        // Level up
        let newLevel = max(1, user.xpTotal / 250 + 1)
        if newLevel != user.level {
            user.level = newLevel
            Haptics.success()
            NotificationCenter.default.post(
                name: .didLevelUp,
                object: nil,
                userInfo: ["level": newLevel]
            )
        }

        user.lastSessionDay = startOfDay(Date())
        checkAndUnlockBadges()
    }

    /// ✅ Novo: complete prática + marca etapa da missão automaticamente
    func completePractice(mode: PracticeMode, xpGained: Int, correctRate: Double) {
        completeSession(xpGained: xpGained, correctRate: correctRate)

        updateTodayWeeklyProgress()
        applyDailyMissionRewardIfCompleted()
    }

    /// ✅ Quando terminar um cenário (mesmo sem XP), você pode chamar isso.
    func completeScenarioOnly() {
        refreshDailyIfNeeded()
        applyStreakIfNeeded()

        user.dailyScenarioProgress = sessionQuestionCount

        updateTodayWeeklyProgress()
        applyDailyMissionRewardIfCompleted()
    }

    // MARK: - Daily/Streak Logic

    private func refreshDailyIfNeeded() {
        let today = startOfDay(Date())

        if user.lastDailyResetDay == nil || user.lastDailyResetDay! != today {
            // reset XP diário
            user.todayXP = 0

            // ✅ reset missão do dia
            user.dailyWordsProgress = 0
            user.dailyPhrasesProgress = 0
            user.dailyScenarioProgress = 0

            // ✅ libera bônus de missão do dia novo
            user.lastMissionRewardKey = nil

            user.lastDailyResetDay = today
        }

        // garante que o semanal esteja com o dia atualizado
        updateTodayWeeklyProgress()
    }

    private func applyStreakIfNeeded() {
        let today = startOfDay(Date())
        if user.lastStreakDay == today { return }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if let last = user.lastStreakDay {
            user.streak = (last == yesterday) ? (user.streak + 1) : 1
        } else {
            user.streak = 1
        }

        user.lastStreakDay = today
    }

    // MARK: - Regras de recompensa da missão (gameficado)

    private func applyDailyMissionRewardIfCompleted() {
        guard dailyMissionIsComplete else { return }

        let todayKey = dayKey(Date())

        // paga 1x por dia
        if user.lastMissionRewardKey == todayKey { return }

        // bônus de missão completa
        user.coins += 25
        user.xpTotal += 30
        user.todayXP = min(user.dailyGoalXP, user.todayXP + 30)

        // marca pagamento
        user.lastMissionRewardKey = todayKey

        // atualiza % semanal pra garantir 100%
        user.weeklyProgress[todayKey] = 1.0

        // Dispara celebração de missão completa
        NotificationCenter.default.post(name: .didCompleteDailyMission, object: nil)

        Haptics.success()
    }

    // MARK: - Weekly persistence

    private func updateTodayWeeklyProgress() {
        let key = dayKey(Date())
        user.weeklyProgress[key] = dailyMissionProgress
    }

    // MARK: - Date helpers

    private func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func startOfWeek(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? startOfDay(date)
    }

    private func dayKey(_ date: Date) -> String {
        dayFormatter.string(from: startOfDay(date))
    }

    private func clamp01(_ v: Double) -> Double {
        max(0, min(1, v))
    }

    // MARK: - Persistence

    private func persistUser() {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // silencioso no MVP
        }
    }

    private func loadUser() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let saved = try? JSONDecoder().decode(UserState.self, from: data)
        else { return }

        user = saved
    }
    
    func progress(for mode: PracticeMode) -> Int {
        switch mode {
        case .words:
            return user.dailyWordsProgress
        case .phrases:
            return user.dailyPhrasesProgress
        case .scenario:
            return user.dailyScenarioProgress
        }
    }
    
    func setProgress(for mode: PracticeMode, value: Int) {
        let safeValue = max(0, min(sessionQuestionCount, value))

        switch mode {
        case .words:
            user.dailyWordsProgress = safeValue
        case .phrases:
            user.dailyPhrasesProgress = safeValue
        case .scenario:
            user.dailyScenarioProgress = safeValue
        }
    }
}
