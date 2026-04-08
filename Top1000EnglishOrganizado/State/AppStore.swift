import Combine
import Foundation

final class AppStore: ObservableObject {
    @Published var user: UserState {
        didSet {
            guard !isLoading else { return }
            persistUser()
        }
    }

    @Published var content      = ContentRepository()
    @Published var reviewPool: [ReviewItem] = []
    @Published var reviewPoolTotal: Int = 0

    var reviewClearedCount: Int { max(0, reviewPoolTotal - reviewPool.count) }

    var selectedPracticeMode: PracticeMode {
        get { PracticeMode(rawValue: user.selectedPracticeModeRawValue) ?? .words }
        set { user.selectedPracticeModeRawValue = newValue.rawValue }
    }

    var sessionQuestionCount: Int { user.level < 10 ? 25 : 50 }

    func isModeUnlocked(_ mode: PracticeMode) -> Bool {
        switch mode {
        case .words, .phrases: return true
        case .scenario:        return user.level >= 10
        }
    }

    private let storageKey = "top1000_user_state_v2"
    private let calendar   = Calendar.current
    private var isLoading  = false

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

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Onboarding
    // ─────────────────────────────────────────────────────────────────

    func completeOnboarding(name: String, dailyGoal: Int, level: Int) {
        user.name        = name
        user.dailyGoalXP = dailyGoal
        user.level       = level
        user.xpTotal     = level > 1 ? (level - 1) * 250 : 0
        user.hasCompletedOnboarding = true
        Haptics.success()
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Lives (corações)
    // ─────────────────────────────────────────────────────────────────

    var hasLives: Bool { user.lives > 0 }

    func loseLife() {
        guard user.lives > 0 else { return }
        user.lives -= 1
        if user.lives == 0 {
            NotificationCenter.default.post(name: .didRunOutOfLives, object: nil)
        }
        Haptics.error()
    }

    func refillLives() {
        user.lives = user.maxLives
        user.livesLastRechargeDate = Date()
    }

    func loseLifeIfNeeded(isPremium: Bool) {
        if !isPremium { loseLife() }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Streak Freeze
    // ─────────────────────────────────────────────────────────────────

    var canBuyStreakFreeze: Bool {
        user.coins >= StreakFreeze.coinCost &&
        user.streakFreeze.count < StreakFreeze.maxStock
    }

    func buyStreakFreeze() {
        guard canBuyStreakFreeze else { return }
        user.coins -= StreakFreeze.coinCost
        user.streakFreeze.count += 1
        Haptics.success()
    }

    /// Tenta usar um freeze para salvar o streak. Retorna true se usou.
    @discardableResult
    func tryUseStreakFreeze() -> Bool {
        guard user.streakFreeze.count > 0 else { return false }
        user.streakFreeze.count -= 1
        user.streakFreeze.usedDates.append(Date())
        return true
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Word Mastery Engine
    // ─────────────────────────────────────────────────────────────────

    /// Chame após cada resposta da sessão
    func updateWordMastery(key: String, correct: Bool) {
        var mastery = user.wordMasteries[key] ?? WordMastery(id: key)
        let previousLevel = mastery.level

        if correct {
            mastery.recordCorrect()
        } else {
            mastery.recordWrong()
        }

        user.wordMasteries[key] = mastery

        // Notifica quando a palavra atinge Domina pela primeira vez
        if mastery.level == .mastered && previousLevel != .mastered {
            NotificationCenter.default.post(
                name: .didMasterWord,
                object: nil,
                userInfo: ["key": key, "total": user.totalWordsMastered]
            )
        }

        // Desbloqueia título de word_hunter (50 palavras no nível ≥ remembers)
        if user.totalWordsLearned >= 50 { unlockTitle("word_hunter") }
        if user.totalWordsMastered >= 500 { unlockTitle("thousand_master") }
    }

    func masteryFor(key: String) -> WordMastery {
        user.wordMasteries[key] ?? WordMastery(id: key)
    }

    /// Retorna as N palavras mais fracas (para SpeedRun/Review priorizar)
    func weakestWords(limit: Int = 20) -> [WordMastery] {
        user.wordMasteries.values
            .sorted { $0.level.rawValue < $1.level.rawValue }
            .prefix(limit)
            .map { $0 }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Titles
    // ─────────────────────────────────────────────────────────────────

    func unlockTitle(_ id: String) {
        guard !user.unlockedTitleIDs.contains(id) else { return }
        user.unlockedTitleIDs.append(id)
        NotificationCenter.default.post(name: .didUnlockTitle, object: nil,
                                        userInfo: ["titleID": id])
        Haptics.success()
    }

    func equipTitle(_ id: String) {
        guard user.unlockedTitleIDs.contains(id) else { return }
        user.equippedTitleID = id
    }

    var equippedTitle: AppTitle? {
        AppTitle.all.first { $0.id == user.equippedTitleID }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Speed Run
    // ─────────────────────────────────────────────────────────────────

    func recordSpeedRun(score: Int) {
        user.speedRecord.totalRuns += 1
        if score > user.speedRecord.bestScore {
            user.speedRecord.bestScore = score
            if score >= 100 { unlockTitle("speed_demon") }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Boss Battle
    // ─────────────────────────────────────────────────────────────────

    func defeatBoss(_ id: String) {
        guard !user.defeatedBossIDs.contains(id) else { return }
        user.defeatedBossIDs.append(id)
        if user.defeatedBossIDs.count >= 3 { unlockTitle("boss_slayer") }
        // XP e moedas grandes pela vitória
        user.xpTotal  += 150
        user.coins    += 80
        NotificationCenter.default.post(name: .didDefeatBoss, object: nil,
                                        userInfo: ["bossID": id])
        Haptics.success()
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Reward Chest
    // ─────────────────────────────────────────────────────────────────

    func applyChestReward(_ reward: ChestReward) {
        user.xpTotal   += reward.xpBonus
        user.todayXP    = min(user.dailyGoalXP, user.todayXP + reward.xpBonus)
        user.coins     += reward.coinBonus
        user.streakFreeze.count = min(StreakFreeze.maxStock,
                                      user.streakFreeze.count + reward.freezeBonus)

        if let title = reward.titleUnlocked {
            unlockTitle(title.id)
        }
        // Level up check
        let newLevel = max(1, user.xpTotal / 250 + 1)
        if newLevel != user.level {
            user.level = newLevel
            NotificationCenter.default.post(name: .didLevelUp, object: nil,
                                            userInfo: ["level": newLevel])
        }
        checkAndUnlockBadges()
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Badges
    // ─────────────────────────────────────────────────────────────────

    func unlockBadge(_ id: String) {
        guard !user.unlockedBadgeIDs.contains(id) else { return }
        user.unlockedBadgeIDs.append(id)
        Haptics.success()
    }

    func checkAndUnlockBadges() {
        if user.streak >= 3   { unlockBadge("streak_3") }
        if user.streak >= 7   { unlockBadge("streak_7");  unlockTitle("streak_warrior") }
        if user.streak >= 30  { unlockBadge("streak_30"); unlockTitle("legend") }

        if user.level >= 5    { unlockBadge("level_5") }
        if user.level >= 10   { unlockBadge("level_10") }
        if user.level >= 20   { unlockBadge("level_20") }

        if user.xpTotal >= 1000   { unlockBadge("xp_1000") }
        if user.xpTotal >= 5000   { unlockBadge("xp_5000") }
        if user.xpTotal >= 10000  { unlockBadge("xp_10000") }

        if dailyMissionIsComplete { unlockBadge("mission_complete") }

        if user.perfectSessionCount >= 10 {
            unlockBadge("perfect")
            unlockTitle("perfectionist")
        }

        if user.totalWordsMastered >= 10 { unlockBadge("review_10") }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Review Pool
    // ─────────────────────────────────────────────────────────────────

    func addReview(_ item: ReviewItem) {
        if !reviewPool.contains(where: { $0.key == item.key }) {
            reviewPool.insert(item, at: 0)
            reviewPoolTotal += 1
        }
        if reviewPool.count > 50 { reviewPool = Array(reviewPool.prefix(50)) }
    }

    func removeReviewItems(keys: [String]) {
        reviewPool.removeAll { keys.contains($0.key) }
        if reviewPool.isEmpty { reviewPoolTotal = 0 }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Missão diária
    // ─────────────────────────────────────────────────────────────────

    var dailyMissionStepsDone: Int {
        var n = 0
        if user.dailyWordsProgress    >= sessionQuestionCount { n += 1 }
        if user.dailyPhrasesProgress  >= sessionQuestionCount { n += 1 }
        if user.dailyScenarioProgress >= sessionQuestionCount { n += 1 }
        return n
    }

    var dailyMissionProgress: Double { Double(dailyMissionStepsDone) / 3.0 }
    var dailyMissionIsComplete: Bool  { dailyMissionStepsDone == 3 }

    var nextDailyMissionStage: PracticeMode {
        if user.dailyWordsProgress    < sessionQuestionCount { return .words }
        if user.dailyPhrasesProgress  < sessionQuestionCount { return .phrases }
        return .scenario
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Session Commit
    // ─────────────────────────────────────────────────────────────────

    func completeSession(xpGained: Int, correctRate: Double) {
        refreshDailyIfNeeded()
        applyStreakIfNeeded()

        user.xpTotal  += xpGained
        user.todayXP   = min(user.dailyGoalXP, user.todayXP + xpGained)

        let baseCoins = max(1, Int(Double(xpGained) * 0.20))
        var bonus = 0
        if correctRate >= 0.80 { bonus += 10 }
        if correctRate >= 1.00 {
            bonus += 20
            user.perfectSessionCount += 1
        }
        user.coins += (baseCoins + bonus)

        let newLevel = max(1, user.xpTotal / 250 + 1)
        if newLevel != user.level {
            user.level = newLevel
            Haptics.success()
            NotificationCenter.default.post(name: .didLevelUp, object: nil,
                                            userInfo: ["level": newLevel])
        }

        user.lastSessionDay = startOfDay(Date())
        checkAndUnlockBadges()
    }

    func completePractice(mode: PracticeMode, xpGained: Int, correctRate: Double) {
        completeSession(xpGained: xpGained, correctRate: correctRate)
        updateTodayWeeklyProgress()
        applyDailyMissionRewardIfCompleted()
    }

    func completeScenarioOnly() {
        refreshDailyIfNeeded()
        applyStreakIfNeeded()
        user.dailyScenarioProgress = sessionQuestionCount
        updateTodayWeeklyProgress()
        applyDailyMissionRewardIfCompleted()
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Daily / Streak Logic
    // ─────────────────────────────────────────────────────────────────

    private func refreshDailyIfNeeded() {
        let today = startOfDay(Date())
        if user.lastDailyResetDay == nil || user.lastDailyResetDay! != today {
            user.todayXP               = 0
            user.dailyWordsProgress    = 0
            user.dailyPhrasesProgress  = 0
            user.dailyScenarioProgress = 0
            user.lastMissionRewardKey  = nil
            user.lastDailyResetDay     = today
        }
        updateTodayWeeklyProgress()
    }

    private func applyStreakIfNeeded() {
        let today     = startOfDay(Date())
        if user.lastStreakDay == today { return }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if let last = user.lastStreakDay {
            if last == yesterday {
                user.streak += 1
            } else {
                // Streak quebrado — tenta usar freeze
                let savedByFreeze = tryUseStreakFreeze()
                if !savedByFreeze {
                    user.streak = 1
                }
            }
        } else {
            user.streak = 1
        }

        user.lastStreakDay = today
    }

    private func applyDailyMissionRewardIfCompleted() {
        guard dailyMissionIsComplete else { return }
        let todayKey = dayKey(Date())
        if user.lastMissionRewardKey == todayKey { return }

        user.coins   += 25
        user.xpTotal += 30
        user.todayXP  = min(user.dailyGoalXP, user.todayXP + 30)
        user.lastMissionRewardKey = todayKey
        user.weeklyProgress[todayKey] = 1.0

        NotificationCenter.default.post(name: .didCompleteDailyMission, object: nil)
        Haptics.success()
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Progress helpers
    // ─────────────────────────────────────────────────────────────────

    func progress(for mode: PracticeMode) -> Int {
        switch mode {
        case .words:    return user.dailyWordsProgress
        case .phrases:  return user.dailyPhrasesProgress
        case .scenario: return user.dailyScenarioProgress
        }
    }

    func setProgress(for mode: PracticeMode, value: Int) {
        let safeValue = max(0, min(sessionQuestionCount, value))
        switch mode {
        case .words:    user.dailyWordsProgress    = safeValue
        case .phrases:  user.dailyPhrasesProgress  = safeValue
        case .scenario: user.dailyScenarioProgress = safeValue
        }
    }

    func weeklyDots() -> [Double] {
        let start = startOfWeek(Date())
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            return clamp01(user.weeklyProgress[dayKey(day)] ?? 0.0)
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Date helpers
    // ─────────────────────────────────────────────────────────────────

    private func startOfDay(_ date: Date) -> Date { calendar.startOfDay(for: date) }

    private func startOfWeek(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? startOfDay(date)
    }

    private func dayKey(_ date: Date) -> String { dayFormatter.string(from: startOfDay(date)) }
    private func clamp01(_ v: Double) -> Double { max(0, min(1, v)) }

    private func updateTodayWeeklyProgress() {
        let key = dayKey(Date())
        user.weeklyProgress[key] = dailyMissionProgress
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Persistence
    // ─────────────────────────────────────────────────────────────────

    private func persistUser() {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {}
    }

    private func loadUser() {
        guard
            let data   = UserDefaults.standard.data(forKey: storageKey),
            let saved  = try? JSONDecoder().decode(UserState.self, from: data)
        else { return }
        user = saved
    }
}
