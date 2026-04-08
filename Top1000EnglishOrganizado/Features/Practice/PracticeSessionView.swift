import SwiftUI

struct PracticeSessionView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    let mode: PracticeMode
    let startIndex: Int

    @State private var questions: [Question] = []
    @State private var index: Int = 0

    @State private var selected: Int? = nil
    @State private var revealed: Bool = false
    @State private var isCorrect: Bool = false

    @State private var correctCount: Int = 0
    @State private var xpGained: Int = 0
    @State private var wrongItems: [ReviewItem] = []

    @State private var showResults = false
    @State private var showChest   = false       // ← Baú de recompensa
    @State private var isAutoAdvancing: Bool = false

    // Hearts & lives
    @State private var showNoLives: Bool = false
    @State private var livesShakeIndex: Int? = nil

    // XP popup
    @State private var xpPopupTrigger: Int = 0

    // Streak counter (acertos seguidos)
    @State private var currentStreak: Int = 0

    // Word Mastery: chaves das perguntas respondidas nesta sessão
    @State private var masteredThisSession: Int = 0

    private let autoAdvanceDelay: Double = 0.70

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient conforme modo
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        mode.gradient.last?.opacity(0.06) ?? Color(.secondarySystemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                        .xpPopup(trigger: $xpPopupTrigger, amount: 10)

                    if questions.isEmpty {
                        Spacer()
                        loadingPlaceholder
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                QuestionCard(
                                    title: mode.rawValue,
                                    prompt: questions[index].prompt,
                                    audioText: extractEnglishText(from: questions[index].prompt)
                                )
                                .padding(.top, 4)
                                .padding(.horizontal, 16)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                                .id("q-\(questions[index].id)")

                                VStack(spacing: 10) {
                                    ForEach(questions[index].options.indices, id: \.self) { i in
                                        AnswerButton(
                                            text: questions[index].options[i],
                                            state: answerState(for: i),
                                            isDisabled: revealed || isAutoAdvancing
                                        ) {
                                            guard !revealed && !isAutoAdvancing else { return }
                                            Haptics.light()
                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                                selected = i
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)

                                // Streak badge quando acerta 3+ seguidos
                                if currentStreak >= 3 && revealed && isCorrect {
                                    streakBadge
                                        .padding(.horizontal, 16)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.bottom, 8)
                        }

                        Spacer(minLength: 0)

                        bottomCTA
                    }
                }

                // Overlay sem vidas
                if showNoLives {
                    NoLivesOverlay(
                        onWatchAd: {
                            // Mock: ad visto → recarrega 1 vida
                            app.refillLives()
                            showNoLives = false
                        },
                        onRefill: {
                            guard app.user.coins >= 50 else { return }
                            app.user.coins -= 50
                            app.refillLives()
                            showNoLives = false
                        },
                        onDismiss: {
                            showNoLives = false
                            dismiss()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(99)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(10)
                            .background(Color.black.opacity(0.05), in: Circle())
                    }
                }
            }
            .onAppear {
                questions = RandomEngine.buildSession(
                    mode: mode,
                    repo: app.content,
                    reviewPool: app.reviewPool,
                    count: app.sessionQuestionCount
                )

                if !questions.isEmpty {
                    index = min(max(startIndex, 0), questions.count - 1)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRunOutOfLives)) { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                    showNoLives = true
                }
            }
            // ── Baú de recompensa (substitui ResultsView como tela final) ──
            .fullScreenCover(isPresented: $showChest) {
                RewardChestView(
                    mode: mode,
                    correctCount: correctCount,
                    total: questions.count,
                    xpGained: xpGained,
                    wrongItems: wrongItems
                ) {
                    let rate = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
                    app.setProgress(for: mode, value: questions.count)
                    app.completePractice(mode: mode, xpGained: xpGained, correctRate: rate)
                    showChest = false
                    dismiss()
                }
                .environmentObject(app)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                // Modo e progresso
                VStack(alignment: .leading, spacing: 1) {
                    Text(mode.rawValue)
                        .font(.system(size: 18, weight: .heavy))

                    Text("\(min(index + 1, questions.count))/\(questions.count) perguntas")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Moedas
                HStack(spacing: 3) {
                    Text("🪙")
                        .font(.system(size: 13))
                    Text("\(app.user.coins)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.05), in: Capsule())

                // Corações
                HeartsView(lives: app.user.lives, maxLives: app.user.maxLives)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Barra de progresso
            ThinProgressBar(
                value: Double(index + 1) / Double(max(questions.count, 1)),
                height: 7,
                trackOpacity: 0.10,
                fill: mode.gradient.first ?? AppColors.brandGreen
            )
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.25), value: index)
        }
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Text("🔥")
                .font(.system(size: 16))
            Text("\(currentStreak) seguidos!")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [AppColors.brandOrange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: AppColors.brandOrange.opacity(0.4), radius: 8, x: 0, y: 3)
        )
    }

    // MARK: - Loading

    private var loadingPlaceholder: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.25)

            Text("Preparando sua prática")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)

            Text("Carregando as próximas perguntas")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        VStack(spacing: 10) {
            if revealed {
                FeedbackBanner(
                    isCorrect: isCorrect,
                    explanation: questions[index].explanation
                )
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button {
                handleMainButton()
            } label: {
                HStack(spacing: 8) {
                    if !revealed, selected != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(mainButtonTitle)
                        .font(.system(size: 17, weight: .heavy))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            mainButtonEnabled
                            ? AnyShapeStyle(ctaGradient)
                            : AnyShapeStyle(Color.gray.opacity(0.22))
                        )
                }
                .foregroundStyle(mainButtonEnabled ? .white : .secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .disabled(!mainButtonEnabled || isAutoAdvancing)
            .opacity(isAutoAdvancing ? 0.75 : 1.0)
            .buttonStyle(.plain)
            .animation(.spring(response: 0.28, dampingFraction: 0.75), value: mainButtonEnabled)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: revealed)
    }

    // MARK: - Helpers

    private var ctaGradient: LinearGradient {
        LinearGradient(
            colors: mode.gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var mainButtonEnabled: Bool {
        revealed ? true : (selected != nil)
    }

    private var mainButtonTitle: String {
        if revealed {
            return (index == questions.count - 1) ? "Finalizar 🏁" : "Próxima →"
        }
        return selected != nil ? "Verificar" : "Escolha uma opção"
    }

    private func handleMainButton() {
        guard !questions.isEmpty else { return }

        if !revealed {
            guard let selected else { return }
            revealed = true

            isCorrect = (selected == questions[index].correctIndex)

            let q = questions[index]

            if isCorrect {
                Haptics.success()
                correctCount += 1
                xpGained += 10
                currentStreak += 1

                // Mastery engine — registra acerto
                let prevLevel = app.masteryFor(key: q.reviewKey).level
                app.updateWordMastery(key: q.reviewKey, correct: true)
                let newLevel  = app.masteryFor(key: q.reviewKey).level
                if newLevel.rawValue > prevLevel.rawValue {
                    masteredThisSession += 1
                    // XP bônus ao subir de nível de mastery
                    xpGained += 5
                }

                // Dispara popup de XP
                xpPopupTrigger += 1

                // Auto-avança
                isAutoAdvancing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                    guard revealed else { return }
                    withAnimation(.easeInOut(duration: 0.20)) {
                        goNext()
                    }
                }
            } else {
                Haptics.error()
                currentStreak = 0

                // Mastery engine — registra erro
                app.updateWordMastery(key: q.reviewKey, correct: false)

                let correct = q.options[q.correctIndex]
                let reviewItem = ReviewItem(
                    key: q.reviewKey,
                    prompt: q.prompt,
                    correct: correct,
                    hint: q.explanation
                )

                wrongItems.append(reviewItem)
                app.addReview(reviewItem)

                // Perde vida (se não premium)
                app.loseLife()
            }
            return
        }

        if !isAutoAdvancing {
            withAnimation(.easeInOut(duration: 0.20)) {
                goNext()
            }
        }
    }

    private func goNext() {
        guard !questions.isEmpty else { return }
        if showResults { return }

        let nextValue = min(index + 1, questions.count)
        app.setProgress(for: mode, value: nextValue)

        revealed = false
        selected = nil
        isAutoAdvancing = false

        if index >= questions.count - 1 {
            showResults = true
        } else {
            index += 1
        }
    }

    /// Extrai o texto em inglês do prompt para pronunciar
    private func extractEnglishText(from prompt: String) -> String? {
        if let range = prompt.range(of: "\u{201C}(.*?)\u{201D}", options: .regularExpression) {
            return String(prompt[range]).trimmingCharacters(in: CharacterSet(charactersIn: "\u{201C}\u{201D}"))
        }
        if prompt.contains("\n") {
            let lines = prompt.components(separatedBy: "\n")
            return lines.last?.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\u{201C}\u{201D}"))
        }
        return nil
    }

    private func answerState(for i: Int) -> AnswerVisualState {
        guard revealed == true else {
            return (selected == i) ? .selected : .neutral
        }

        if i == questions[index].correctIndex { return .correct }
        if i == selected { return .wrong }
        return .neutral
    }
}
