import SwiftUI
import Combine

// ─────────────────────────────────────────────────────────────────────
// MARK: - SpeedRunView
// Modo Blitz: 60 segundos, responda o máximo de perguntas possível.
// Sem penalidade por errar — só o tempo conta.
// ─────────────────────────────────────────────────────────────────────

struct SpeedRunView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [Question] = []
    @State private var index = 0
    @State private var score = 0
    @State private var combo = 0          // acertos seguidos
    @State private var bestCombo = 0
    @State private var timeLeft: Double = 60
    @State private var phase: SpeedPhase = .countdown
    @State private var countdown = 3
    @State private var showResult = false

    // Animação de resposta
    @State private var flashColor: Color = .clear
    @State private var flashOpacity: Double = 0
    @State private var scorePopText: String = ""
    @State private var scorePopOffset: CGFloat = 0
    @State private var scorePopOpacity: Double = 0
    @State private var timerScale: CGFloat = 1.0

    private let totalTime: Double = 60
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    enum SpeedPhase { case countdown, playing, finished }

    var body: some View {
        ZStack {
            // Background dinâmico — fica vermelho nos últimos 10s
            LinearGradient(
                colors: timeLeft <= 10
                    ? [AppColors.brandRed.opacity(0.25), AppColors.heroNavy]
                    : [AppColors.heroNavy, AppColors.heroSlate],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: timeLeft <= 10)

            // Flash de acerto/erro
            Color(flashColor)
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .animation(.easeOut(duration: 0.18), value: flashOpacity)

            switch phase {
            case .countdown: countdownView
            case .playing:   playingView
            case .finished:  finishedView
            }
        }
        .onReceive(timer) { _ in
            guard phase == .playing else { return }
            timeLeft = max(0, timeLeft - 0.1)
            if timeLeft <= 0 {
                endGame()
            }
        }
        .onAppear {
            loadQuestions()
            startCountdown()
        }
        .sheet(isPresented: $showResult) {
            speedResultSheet
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Countdown
    // ─────────────────────────────────────────────────────────────────

    private var countdownView: some View {
        VStack(spacing: 20) {
            Text("Speed Run")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(.white)

            Text("Responda o máximo em 60s")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.65))

            Text("\(countdown)")
                .font(.system(size: 96, weight: .heavy))
                .foregroundStyle(AppColors.brandOrange)
                .contentTransition(.numericText())
                .shadow(color: AppColors.brandOrange.opacity(0.60), radius: 20, x: 0, y: 0)
                .padding(.vertical, 20)

            HStack(spacing: 14) {
                infoChip(icon: "clock.fill",      label: "60 segundos",    color: AppColors.brandBlue)
                infoChip(icon: "bolt.fill",       label: "Sem penalidade", color: AppColors.brandGreen)
                infoChip(icon: "trophy.fill",     label: "Recorde pessoal",color: AppColors.gold)
            }
            .padding(.horizontal, 24)
        }
    }

    private func infoChip(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Playing
    // ─────────────────────────────────────────────────────────────────

    private var playingView: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack(alignment: .center) {
                // Timer
                VStack(spacing: 2) {
                    ZStack {
                        // Ring de tempo
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 5)
                        Circle()
                            .trim(from: 0, to: max(0, timeLeft / totalTime))
                            .stroke(
                                timeLeft > 10 ? AppColors.brandGreen : AppColors.brandRed,
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: timeLeft)

                        Text(String(format: "%.0f", timeLeft))
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(.white)
                            .scaleEffect(timerScale)
                    }
                    .frame(width: 60, height: 60)
                }

                Spacer()

                // Score + Combo
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("⭐️")
                        Text("\(score)")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    if combo >= 3 {
                        Text("🔥 \(combo)x combo!")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppColors.brandOrange)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Spacer()

                // Record
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Record")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.45))
                    Text("\(app.user.speedRecord.bestScore)")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(AppColors.gold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)

            if !questions.isEmpty {
                // Pergunta
                speedQuestion

                Spacer()

                // Botões de resposta
                speedAnswers
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
            }

            // Score pop
            Text(scorePopText)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(AppColors.brandGreen)
                .shadow(color: AppColors.brandGreen.opacity(0.6), radius: 8, x: 0, y: 0)
                .offset(y: scorePopOffset)
                .opacity(scorePopOpacity)
        }
    }

    private var speedQuestion: some View {
        let q = questions[index % questions.count]
        return VStack(spacing: 8) {
            Text("Qual a tradução?")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.55))

            Text(q.prompt
                .replacingOccurrences(of: "Qual a tradução de ", with: "")
                .replacingOccurrences(of: "?", with: "")
                .replacingOccurrences(of: "\u{201C}", with: "")
                .replacingOccurrences(of: "\u{201D}", with: "")
            )
            .font(.system(size: 36, weight: .heavy))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }

    private var speedAnswers: some View {
        let q = questions[index % questions.count]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            ForEach(q.options.indices, id: \.self) { i in
                Button {
                    handleAnswer(optionIndex: i, question: q)
                } label: {
                    Text(q.options[i])
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.12))
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
    // MARK: - Finished
    // ─────────────────────────────────────────────────────────────────

    private var finishedView: some View {
        VStack(spacing: 24) {
            Text(score > app.user.speedRecord.bestScore ? "🏆 Novo Record!" : "⏱ Tempo esgotado!")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)

            Text("Pontuação: \(score)")
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(AppColors.gold)
                .shadow(color: AppColors.gold.opacity(0.50), radius: 16, x: 0, y: 0)

            if score > app.user.speedRecord.bestScore {
                Text("Anterior: \(app.user.speedRecord.bestScore)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.55))
            }

            Button("Ver resultado completo") {
                showResult = true
            }
            .font(.system(size: 16, weight: .heavy))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.ctaGradient, in: RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 40)
        }
    }

    private var speedResultSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Título
                VStack(spacing: 8) {
                    Text(score > 0 && score == app.user.speedRecord.bestScore ? "🏆 Record Pessoal!" : "Speed Run")
                        .font(.system(size: 26, weight: .heavy))
                    Text("Sessão de \(String(format: "%.0f", totalTime))s")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                HStack(spacing: 12) {
                    statBox(emoji: "⭐️", value: "\(score)", label: "Pontos",    color: AppColors.gold)
                    statBox(emoji: "🔥", value: "\(bestCombo)x", label: "Melhor combo", color: AppColors.brandOrange)
                    statBox(emoji: "🏅", value: "\(app.user.speedRecord.bestScore)", label: "Record",  color: AppColors.brandPurple)
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Fechar")
                        .font(.system(size: 17, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.ctaGradient, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
                .buttonStyle(.plain)
            }
        }
        .presentationDetents([.medium])
    }

    private func statBox(emoji: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 22))
            Text(value).font(.system(size: 20, weight: .heavy))
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Logic
    // ─────────────────────────────────────────────────────────────────

    private func loadQuestions() {
        var qs = RandomEngine.buildSession(
            mode: .words,
            repo: app.content,
            reviewPool: app.reviewPool,
            count: 60
        )
        // Shuffle para variedade
        qs.shuffle()
        questions = qs
    }

    private func startCountdown() {
        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if countdown > 1 {
                countdown -= 1
                Haptics.light()
            } else {
                t.invalidate()
                withAnimation {
                    phase = .playing
                }
            }
        }
    }

    private func handleAnswer(optionIndex: Int, question: Question) {
        let correct = optionIndex == question.correctIndex

        if correct {
            combo += 1
            if combo > bestCombo { bestCombo = combo }

            // Score com multiplicador de combo
            let multiplier = min(combo, 5)
            let pts = 1 + (multiplier - 1)
            score += pts

            // Feedback visual
            flashFeedback(correct: true)
            showScorePop(pts: pts)
            Haptics.success()

            // Bônus de tempo nos combos
            if combo >= 5 { timeLeft = min(totalTime, timeLeft + 2) }
        } else {
            combo = 0
            flashFeedback(correct: false)
            Haptics.error()
        }

        // Avança para próxima pergunta
        withAnimation(.easeInOut(duration: 0.15)) {
            index += 1
        }
    }

    private func flashFeedback(correct: Bool) {
        flashColor   = correct ? AppColors.brandGreen : AppColors.brandRed
        flashOpacity = correct ? 0.18 : 0.22
        withAnimation(.easeOut(duration: 0.25)) {
            flashOpacity = 0
        }
    }

    private func showScorePop(pts: Int) {
        scorePopText    = pts > 1 ? "+\(pts) 🔥" : "+1"
        scorePopOffset  = 0
        scorePopOpacity = 1

        withAnimation(.easeOut(duration: 0.6)) {
            scorePopOffset  = -60
            scorePopOpacity = 0
        }
    }

    private func endGame() {
        phase = .finished
        app.recordSpeedRun(score: score)
        Haptics.success()

        // XP bônus proporcional ao score
        let xpBonus = min(score * 2, 50)
        app.user.xpTotal  += xpBonus
        app.user.coins    += score

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showResult = true
        }
    }
}
