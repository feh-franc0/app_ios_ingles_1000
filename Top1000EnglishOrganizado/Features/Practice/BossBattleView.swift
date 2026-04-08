import SwiftUI

// ─────────────────────────────────────────────────────────────────────
// MARK: - BossBattleView
// Batalha de boss: 15-25 perguntas, 10s por pergunta, max 3 erros.
// Vitória → XP e coins grandes + badge de boss.
// ─────────────────────────────────────────────────────────────────────

struct BossBattleView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    let boss: BossData

    @State private var questions: [Question] = []
    @State private var index = 0
    @State private var bossHP: Int
    @State private var playerHP = 3          // vidas do jogador (máx 3 erros)
    @State private var questionTimeLeft: Double = 10
    @State private var phase: BossPhase = .intro
    @State private var lastAnswerCorrect: Bool? = nil
    @State private var bossShake: CGFloat = 0
    @State private var playerShake: CGFloat = 0
    @State private var attackFlash: Bool = false

    private let questionTime: Double = 10
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    enum BossPhase { case intro, battle, victory, defeat }

    init(boss: BossData) {
        self.boss = boss
        self._bossHP = State(initialValue: boss.hp)
    }

    var body: some View {
        ZStack {
            // Background do capítulo
            LinearGradient(
                colors: boss.chapterGradient.map { $0.opacity(0.30) } + [AppColors.heroNavy],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            switch phase {
            case .intro:   introView
            case .battle:  battleView
            case .victory: victoryView
            case .defeat:  defeatView
            }
        }
        .onReceive(timer) { _ in
            guard phase == .battle else { return }
            questionTimeLeft = max(0, questionTimeLeft - 0.1)
            if questionTimeLeft <= 0 {
                handleTimeout()
            }
        }
        .onAppear {
            loadQuestions()
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Intro
    // ─────────────────────────────────────────────────────────────────

    private var introView: some View {
        VStack(spacing: 28) {
            Spacer()

            // Boss avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: boss.chapterGradient,
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 140, height: 140)
                    .shadow(color: (boss.chapterGradient.first ?? .clear).opacity(0.50), radius: 30, x: 0, y: 10)

                Text(boss.emoji)
                    .font(.system(size: 72))
            }

            VStack(spacing: 10) {
                Text("Boss Battle")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color.white.opacity(0.60))
                    .textCase(.uppercase)
                    .tracking(3)

                Text(boss.name)
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(boss.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.65))
                    .multilineTextAlignment(.center)
            }

            // Regras
            VStack(spacing: 10) {
                bossRuleRow(icon: "clock.fill",      text: "10 segundos por pergunta",      color: AppColors.brandBlue)
                bossRuleRow(icon: "heart.fill",      text: "Máximo 3 erros permitidos",     color: AppColors.brandRed)
                bossRuleRow(icon: "bolt.fill",       text: "+150 XP e 80 moedas ao vencer", color: AppColors.gold)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                    phase = .battle
                }
            } label: {
                Label("Iniciar Batalha!", systemImage: "bolt.fill")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: boss.chapterGradient,
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .shadow(color: (boss.chapterGradient.first ?? .clear).opacity(0.45), radius: 14, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func bossRuleRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.80))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Battle
    // ─────────────────────────────────────────────────────────────────

    private var battleView: some View {
        VStack(spacing: 0) {
            // Status bar
            HStack(alignment: .center, spacing: 16) {
                // Vidas do jogador
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < playerHP ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(i < playerHP ? AppColors.brandRed : Color.white.opacity(0.22))
                    }
                }
                .offset(x: playerShake)

                Spacer()

                // Timer circular
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: max(0, questionTimeLeft / questionTime))
                        .stroke(
                            questionTimeLeft > 4 ? AppColors.brandGreen : AppColors.brandRed,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text(String(format: "%.0f", questionTimeLeft))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .frame(width: 48, height: 48)
                .animation(.linear(duration: 0.1), value: questionTimeLeft)

                Spacer()

                // HP do Boss
                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(boss.emoji).font(.system(size: 16))
                        Text("\(bossHP)/\(boss.hp) HP")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                    // HP bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.12)).frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(colors: boss.chapterGradient, startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * max(0, Double(bossHP) / Double(boss.hp)), height: 6)
                        }
                    }
                    .frame(width: 80, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: bossHP)
                }
                .offset(x: bossShake)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)

            // Boss
            Text(boss.emoji)
                .font(.system(size: 80))
                .scaleEffect(attackFlash ? 1.15 : 1.0)
                .offset(x: bossShake)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: bossShake)
                .padding(.bottom, 16)

            // Pergunta
            if !questions.isEmpty {
                bossQuestion
                Spacer(minLength: 8)
                bossAnswers
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
    }

    private var bossQuestion: some View {
        let q = questions[index % questions.count]
        return VStack(spacing: 10) {
            Text("Pergunta \(index + 1)/\(boss.hp)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.50))

            Text(q.prompt)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 14)
    }

    private var bossAnswers: some View {
        let q = questions[index % questions.count]
        return VStack(spacing: 10) {
            ForEach(q.options.indices, id: \.self) { i in
                Button {
                    handleBossAnswer(optionIndex: i, question: q)
                } label: {
                    Text(q.options[i])
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Victory
    // ─────────────────────────────────────────────────────────────────

    private var victoryView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🏆").font(.system(size: 80))
                .shadow(color: AppColors.gold.opacity(0.60), radius: 20, x: 0, y: 0)

            Text("VITÓRIA!")
                .font(.system(size: 40, weight: .heavy))
                .foregroundStyle(AppColors.gold)

            Text("Você derrotou \(boss.name)!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.75))

            HStack(spacing: 16) {
                rewardBubble(emoji: "⭐️", value: "+150 XP")
                rewardBubble(emoji: "🪙", value: "+80 moedas")
                if !app.user.defeatedBossIDs.contains(boss.id) {
                    rewardBubble(emoji: "🏅", value: "1º derrota!")
                }
            }

            Spacer()

            Button {
                app.defeatBoss(boss.id)
                dismiss()
            } label: {
                Text("Reclamar recompensa 🎉")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(AppColors.goldGradient, in: RoundedRectangle(cornerRadius: 20))
                    .shadow(color: AppColors.gold.opacity(0.45), radius: 14, x: 0, y: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .buttonStyle(.plain)
        }
    }

    private func rewardBubble(emoji: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 28))
            Text(value)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Defeat
    // ─────────────────────────────────────────────────────────────────

    private var defeatView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(boss.emoji).font(.system(size: 80))
            Text("Derrota...")
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(AppColors.brandRed)
            Text("O boss venceu dessa vez. Tente novamente!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    resetBattle()
                } label: {
                    Label("Tentar novamente", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(LinearGradient(colors: boss.chapterGradient, startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)

                Button("Voltar") { dismiss() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .padding(.bottom, 32)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Logic
    // ─────────────────────────────────────────────────────────────────

    private func loadQuestions() {
        questions = RandomEngine.buildSession(
            mode: .words,
            repo: app.content,
            reviewPool: app.reviewPool,
            count: max(boss.hp, 25)
        ).shuffled()
    }

    private func handleBossAnswer(optionIndex: Int, question: Question) {
        let correct = optionIndex == question.correctIndex
        questionTimeLeft = questionTime

        if correct {
            Haptics.success()
            bossHP -= 1
            // Boss "leva dano" — shake
            withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true)) {
                bossShake = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { bossShake = 0 }

            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                attackFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { attackFlash = false }
            }

            if bossHP <= 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.70)) {
                        phase = .victory
                    }
                }
                return
            }
        } else {
            Haptics.error()
            playerHP -= 1
            // Player "leva dano" — shake corações
            withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true)) {
                playerShake = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { playerShake = 0 }

            if playerHP <= 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.70)) {
                        phase = .defeat
                    }
                }
                return
            }
        }

        withAnimation(.easeInOut(duration: 0.15)) {
            index += 1
        }
    }

    private func handleTimeout() {
        // Tempo esgotado = erro
        handleBossAnswer(optionIndex: -1, question: questions[index % questions.count])
    }

    private func resetBattle() {
        bossHP          = boss.hp
        playerHP        = 3
        index           = 0
        questionTimeLeft = questionTime
        questions.shuffle()
        withAnimation {
            phase = .intro
        }
    }
}
