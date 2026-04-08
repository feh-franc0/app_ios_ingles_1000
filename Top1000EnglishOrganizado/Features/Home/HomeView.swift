import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppStore

    @State private var showSession    = false
    @State private var selectedMode: PracticeMode = .words
    @State private var showScenarios  = false
    @State private var showReviewSession = false
    @State private var pulse          = false
    @State private var celebration: CelebrationType? = nil
    @State private var showSpeedRun = false
    @State private var showBossBattle = false

    // Controle do modo selecionado nos pills
    @State private var activePill: PracticeMode = .words

    var body: some View {
        ZStack(alignment: .top) {
            // Fundo base
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Hero com background escuro ─────────────────
                    heroSection
                        .padding(.bottom, 28)

                    // ── Cards na parte branca ──────────────────────
                    VStack(spacing: 16) {
                        missionCard
                        quickStatsRow
                        wordMasteryCard
                        reviewCard
                        streakCard
                        extraModesRow
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showSession) {
            PracticeSessionView(mode: selectedMode,
                                startIndex: app.progress(for: selectedMode))
                .environmentObject(app)
        }
        .sheet(isPresented: $showScenarios) {
            PracticeSessionView(mode: .scenario,
                                startIndex: app.progress(for: .scenario))
                .environmentObject(app)
        }
        .sheet(isPresented: $showReviewSession) {
            ReviewSessionView().environmentObject(app)
        }
        .sheet(isPresented: $showSpeedRun) {
            SpeedRunView().environmentObject(app)
        }
        .sheet(isPresented: $showBossBattle) {
            BossBattleView(boss: BossData.all[0]).environmentObject(app)
        }
        .celebration($celebration)
        .onReceive(NotificationCenter.default.publisher(for: .didLevelUp)) { notif in
            if let level = notif.userInfo?["level"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    celebration = .levelUp(level)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didCompleteDailyMission)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                celebration = .missionComplete
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Hero Section
    // ────────────────────────────────────────────────────────────────

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Background escuro
            LinearGradient(
                colors: [AppColors.heroNavy, AppColors.heroSlate, AppColors.heroNavy2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Brilho sutil no topo
            RadialGradient(
                colors: [AppColors.brandBlue.opacity(0.22), .clear],
                center: .topTrailing, startRadius: 40, endRadius: 280
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                // Top bar: avatar + saudação + moedas + vidas
                topBar
                    .padding(.top, 60)
                    .padding(.horizontal, 20)

                // XP Progress
                xpProgressBar
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                // Mode pills + CTA
                VStack(spacing: 14) {
                    modePills
                    ctaButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        // Curva inferior
        .clipShape(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
        )
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 18)
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.brandPurple, AppColors.brandBlue],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                Text(String(app.user.name.prefix(1)).uppercased())
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Olá, \(app.user.name) 👋")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
                Text("Nível \(app.user.level) • \(app.user.xpTotal) XP")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.60))
            }

            Spacer()

            // Corações
            HStack(spacing: 4) {
                ForEach(0..<app.user.maxLives, id: \.self) { i in
                    Image(systemName: i < app.user.lives ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(i < app.user.lives ? AppColors.brandRed : Color.white.opacity(0.25))
                }
            }

            // Moedas
            HStack(spacing: 5) {
                Text("🪙")
                    .font(.system(size: 14))
                Text("\(app.user.coins)")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.12), in: Capsule())
        }
    }

    private var xpProgressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Progresso diário")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.55))
                Spacer()
                Text("\(min(app.user.todayXP, app.user.dailyGoalXP))/\(app.user.dailyGoalXP) XP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            // Barra de progresso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.brandGreen, AppColors.brandBlue],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(16, geo.size.width * min(1.0, dailyProgress)),
                            height: 8
                        )
                        .shadow(color: AppColors.brandGreen.opacity(0.55), radius: 6, x: 0, y: 2)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dailyProgress)
                }
            }
            .frame(height: 8)
        }
    }

    private var modePills: some View {
        HStack(spacing: 10) {
            ForEach(PracticeMode.allCases) { mode in
                modePill(mode)
            }
        }
    }

    private func modePill(_ mode: PracticeMode) -> some View {
        let isActive = activePill == mode
        let isLocked = mode == .scenario && !isScenarioUnlocked

        return Button {
            guard !isLocked else { Haptics.error(); return }
            Haptics.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                activePill = mode
                app.selectedPracticeMode = mode
            }
        } label: {
            HStack(spacing: 6) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                } else {
                    Image(systemName: mode.icon)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(mode.rawValue)
                    .font(.system(size: 13, weight: .heavy))
                    .lineLimit(1)
            }
            .foregroundStyle(isActive ? .white : Color.white.opacity(0.55))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                if isActive {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: mode.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: (mode.gradient.first ?? AppColors.brandGreen).opacity(0.45),
                            radius: 10, x: 0, y: 4
                        )
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isActive)
    }

    private var ctaButton: some View {
        Button {
            Haptics.medium()
            let mode = activePill
            if mode == .scenario {
                guard isScenarioUnlocked else { return }
                showScenarios = true
            } else {
                selectedMode = mode
                showSession = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .black))
                Text("Praticar agora")
                    .font(.system(size: 18, weight: .heavy))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: activePill.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: (activePill.gradient.first ?? AppColors.brandGreen).opacity(pulse ? 0.55 : 0.32),
                        radius: pulse ? 22 : 14,
                        x: 0, y: 10
                    )
                    .scaleEffect(pulse ? 1.005 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: activePill)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Mission Card
    // ────────────────────────────────────────────────────────────────

    private var missionCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandOrange.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text("🎯").font(.system(size: 15))
                    }
                    Text("Missão do dia")
                        .font(.system(size: 17, weight: .heavy))
                }
                Spacer()
                // Progresso circular
                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 3)
                        .frame(width: 36, height: 36)
                    Circle()
                        .trim(from: 0, to: app.dailyMissionProgress)
                        .stroke(AppColors.brandGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                    Text("\(app.dailyMissionStepsDone)/3")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            // Divider
            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 18)

            // Rows
            VStack(spacing: 0) {
                missionRow(
                    mode: .words,
                    emoji: "📝",
                    title: "Palavras",
                    done: app.user.didWordsToday,
                    progress: wordsProgress,
                    trailing: wordsTrailing,
                    isLast: false
                ) {
                    app.selectedPracticeMode = .words
                    selectedMode = .words
                    showSession = true
                }

                missionRow(
                    mode: .phrases,
                    emoji: "💬",
                    title: "Frases",
                    done: app.user.didPhrasesToday,
                    progress: phrasesProgress,
                    trailing: phrasesTrailing,
                    isLast: false
                ) {
                    app.selectedPracticeMode = .phrases
                    selectedMode = .phrases
                    showSession = true
                }

                missionRow(
                    mode: .scenario,
                    emoji: isScenarioUnlocked ? "🗣️" : "🔒",
                    title: "Conversação",
                    done: isScenarioUnlocked && app.user.didScenarioToday,
                    progress: scenarioProgress,
                    trailing: scenarioTrailing,
                    isLast: true,
                    isLocked: !isScenarioUnlocked
                ) {
                    guard isScenarioUnlocked else { return }
                    app.selectedPracticeMode = .scenario
                    showScenarios = true
                }
            }
            .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    private func missionRow(
        mode: PracticeMode,
        emoji: String,
        title: String,
        done: Bool,
        progress: Double,
        trailing: String,
        isLast: Bool,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.light()
            guard !isLocked else { Haptics.error(); return }
            action()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    // Ícone
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                done
                                ? AnyShapeStyle(AppColors.brandGreen.opacity(0.12))
                                : AnyShapeStyle(mode.gradient.first?.opacity(0.10) ?? Color.clear)
                            )
                            .frame(width: 42, height: 42)
                        Text(emoji).font(.system(size: 20))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(isLocked ? Color.secondary : .primary)

                        if !isLocked && progress > 0 && progress < 1.0 {
                            // Mini barra de progresso
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.black.opacity(0.06)).frame(height: 4)
                                    Capsule()
                                        .fill(LinearGradient(colors: mode.gradient, startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * progress, height: 4)
                                }
                            }
                            .frame(height: 4)
                        } else if isLocked {
                            Text("Nível 10 para desbloquear")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Trailing
                    if done {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppColors.brandGreen)
                    } else {
                        Text(trailing)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.secondary.opacity(0.45))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)

                if !isLast {
                    Rectangle()
                        .fill(Color.black.opacity(0.04))
                        .frame(height: 1)
                        .padding(.horizontal, 18)
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.65 : 1.0)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Quick Stats Row
    // ────────────────────────────────────────────────────────────────

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            quickStatCard(
                value: "\(app.user.streak)",
                label: "dias",
                emoji: "🔥",
                gradient: [AppColors.brandOrange, .red]
            )
            quickStatCard(
                value: "\(app.user.coins)",
                label: "moedas",
                emoji: "🪙",
                gradient: [AppColors.gold, AppColors.brandOrange]
            )
            quickStatCard(
                value: "\(app.user.level)",
                label: "nível",
                emoji: "⭐️",
                gradient: [AppColors.brandPurple, AppColors.brandBlue]
            )
        }
    }

    private func quickStatCard(value: String, label: String, emoji: String, gradient: [Color]) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 22))
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.primary)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Review Card
    // ────────────────────────────────────────────────────────────────

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandPurple.opacity(0.12))
                            .frame(width: 32, height: 32)
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.brandPurple)
                    }
                    Text("Revisão")
                        .font(.system(size: 17, weight: .heavy))
                }
                Spacer()
                if app.reviewPoolTotal > 0 {
                    Text("\(app.reviewClearedCount)/\(app.reviewPoolTotal)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.brandPurple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.brandPurple.opacity(0.10), in: Capsule())
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 18)

            if app.reviewPool.isEmpty {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColors.brandGreen.opacity(0.12))
                            .frame(width: 46, height: 46)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppColors.brandGreen)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Tudo limpo! 🎉")
                            .font(.system(size: 15, weight: .bold))
                        Text("Palavras erradas aparecem aqui para praticar.")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            } else {
                Button {
                    Haptics.light()
                    showReviewSession = true
                } label: {
                    VStack(spacing: 10) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppColors.brandPurple.opacity(0.12))
                                    .frame(width: 46, height: 46)
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(AppColors.brandPurple)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Revisão rápida")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.primary)
                                Text("\(app.reviewPool.count) item(s) para revisar")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.secondary.opacity(0.45))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.black.opacity(0.06)).frame(height: 6)
                                Capsule()
                                    .fill(AppColors.purpleGradient)
                                    .frame(
                                        width: geo.size.width * max(0.02, Double(app.reviewClearedCount) / Double(max(1, app.reviewPoolTotal))),
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Streak Card
    // ────────────────────────────────────────────────────────────────

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("🔥").font(.system(size: 20))
                    Text("Sequência")
                        .font(.system(size: 17, weight: .heavy))
                }
                Spacer()
                Text("\(app.user.streak) dias")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.brandOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.brandOrange.opacity(0.10), in: Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 18)

            // Dias da semana
            HStack(spacing: 8) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { i, day in
                    let isActive = i < min(app.user.streak, 7)
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(isActive
                                      ? AnyShapeStyle(LinearGradient(colors: [AppColors.gold, AppColors.brandOrange], startPoint: .top, endPoint: .bottom))
                                      : AnyShapeStyle(Color.black.opacity(0.05))
                                )
                                .frame(width: 38, height: 38)
                                .shadow(
                                    color: isActive ? AppColors.gold.opacity(0.40) : .clear,
                                    radius: 8, x: 0, y: 4
                                )
                            if isActive {
                                Text("🔥").font(.system(size: 16))
                            } else {
                                Text(day)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text(day)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(isActive ? AppColors.brandOrange : Color.secondary.opacity(0.50))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)

            if app.user.streak == 0 {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text("Complete uma missão hoje para começar sua sequência!")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Word Mastery Card
    // ────────────────────────────────────────────────────────────────

    private var wordMasteryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Text("📚").font(.system(size: 18))
                Text("Vocabulário em Progresso")
                    .font(.system(size: 17, weight: .heavy))
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 10)

                    Capsule()
                        .fill(AppColors.brandPurple)
                        .frame(
                            width: max(16, geo.size.width * min(1.0, wordMasteryProgress)),
                            height: 10
                        )
                        .shadow(color: AppColors.brandPurple.opacity(0.45), radius: 6, x: 0, y: 2)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: wordMasteryProgress)
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 18)
            .padding(.bottom, 12)

            // Stats
            HStack(spacing: 4) {
                Text("\(app.user.totalWordsLearned)/1000 palavras")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                Text("•")
                    .foregroundStyle(.secondary)
                Text("\(app.user.totalWordsMastered) dominadas")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("⭐️").font(.system(size: 12))
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Extra Modes Row
    // ────────────────────────────────────────────────────────────────

    private var extraModesRow: some View {
        HStack(spacing: 10) {
            // Speed Run Card
            Button {
                Haptics.light()
                showSpeedRun = true
            } label: {
                VStack(spacing: 12) {
                    Text("⚡️")
                        .font(.system(size: 40))
                    VStack(spacing: 4) {
                        Text("Speed Run")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(.white)
                        Text("60 segundos")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.80))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        colors: [AppColors.brandOrange, AppColors.brandOrange.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(24)
                .shadow(color: AppColors.brandOrange.opacity(0.35), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            // Boss Battle Card
            Button {
                Haptics.light()
                showBossBattle = true
            } label: {
                VStack(spacing: 12) {
                    Text("⚔️")
                        .font(.system(size: 40))
                    VStack(spacing: 4) {
                        Text("Boss Battle")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(.white)
                        Text("Desafio épico")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.80))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        colors: [AppColors.brandPurple, AppColors.brandBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(24)
                .shadow(color: AppColors.brandPurple.opacity(0.35), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Helpers
    // ────────────────────────────────────────────────────────────────

    private let weekDays = ["S", "T", "Q", "Q", "S", "S", "D"]

    private var dailyProgress: Double {
        guard app.user.dailyGoalXP > 0 else { return 0 }
        return min(1.0, Double(app.user.todayXP) / Double(app.user.dailyGoalXP))
    }

    private var levelProgress: Double {
        let mod = Double(app.user.xpTotal % 250)
        return max(0.0, min(1.0, mod / 250.0))
    }

    private var wordMasteryProgress: Double {
        return min(1.0, Double(app.user.totalWordsLearned) / 1000.0)
    }

    private var sessionTotal: Int { app.sessionQuestionCount }
    private var isScenarioUnlocked: Bool { app.isModeUnlocked(.scenario) }

    private var wordsTrailing: String    { "\(app.progress(for: .words))/\(sessionTotal)" }
    private var phrasesTrailing: String  { "\(app.progress(for: .phrases))/\(sessionTotal)" }
    private var scenarioTrailing: String {
        if !isScenarioUnlocked { return "Nível 10" }
        return "\(app.progress(for: .scenario))/\(sessionTotal)"
    }

    private var wordsProgress: Double   { Double(app.progress(for: .words))    / Double(sessionTotal) }
    private var phrasesProgress: Double { Double(app.progress(for: .phrases))  / Double(sessionTotal) }
    private var scenarioProgress: Double{ Double(app.progress(for: .scenario)) / Double(sessionTotal) }
}
