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

    // ✅ Trava anti duplo-avanço / clique spam
    @State private var isAutoAdvancing: Bool = false

    // UX: tempo do feedback antes de avançar automaticamente (quando acerta)
    private let autoAdvanceDelay: Double = 0.70

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    topBar

                    if questions.isEmpty {
                        Spacer()
                        ProgressView().scaleEffect(1.2)
                        Text("Montando sua sessão…")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    } else {
                        // ✅ Transição suave entre perguntas
                        QuestionCard(title: mode.rawValue, prompt: questions[index].prompt)
                            .padding(.top, 2)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                            .id("q-\(questions[index].id)")

                        VStack(spacing: 10) {
                            ForEach(questions[index].options.indices, id: \.self) { i in
                                AnswerButton(
                                    text: questions[index].options[i],
                                    state: answerState(for: i),
                                    isDisabled: revealed || isAutoAdvancing // ✅ trava também no auto-advance
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

                        Spacer()

                        bottomCTA
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }
                }
            }
            .onAppear {
                questions = RandomEngine.buildSession(
                    mode: mode,
                    repo: app.content,
                    reviewPool: app.reviewPool,
                    count: 10
                )

                if !questions.isEmpty {
                    index = min(startIndex, questions.count - 1)
                }
            }
            .sheet(isPresented: $showResults) {
                ResultsView(
                    mode: mode,
                    correctCount: correctCount,
                    total: questions.count,
                    xpGained: xpGained,
                    wrongItems: wrongItems
                ) {
                    // 1) manda erradas pra revisão
                    for item in wrongItems { app.addReview(item) }

                    // 2) commit da sessão (UMA vez só)
                    let rate = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
                    app.setProgress(for: mode, value: questions.count)
                    app.completePractice(mode: mode, xpGained: xpGained, correctRate: rate)

                    // 3) fecha results
                    showResults = false

                    // 4) fecha a sessão e volta pra Home
                    dismiss()
                }
                .environmentObject(app)
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text(mode.rawValue)
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Text("\(index + 1)/\(max(questions.count, 10))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ProgressView(value: Double(index), total: Double(max(questions.count, 10)))
                .tint(AppColors.brandGreen)
                .scaleEffect(x: 1, y: 1.35, anchor: .center)
                .padding(.horizontal, 16)
        }
    }

    private var bottomCTA: some View {
        VStack(spacing: 10) {
            if revealed {
                FeedbackBanner(isCorrect: isCorrect, explanation: questions[index].explanation)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button {
                handleMainButton()
            } label: {
                Text(mainButtonTitle)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        RoundedRectangle(cornerRadius: 18)
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
            // ✅ desabilita durante auto-advance (anti bug)
            .disabled(!mainButtonEnabled || isAutoAdvancing)
            .opacity(isAutoAdvancing ? 0.75 : 1.0)
            .buttonStyle(.plain)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: revealed)
    }

    private var ctaGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.brandGreen, AppColors.brandBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var mainButtonEnabled: Bool {
        // Se já revelou, sempre pode ir “Próxima/Finalizar”
        // Se não revelou, precisa ter selecionado algo
        revealed ? true : (selected != nil)
    }

    private var mainButtonTitle: String {
        if revealed {
            return (index == questions.count - 1) ? "Finalizar" : "Próxima"
        }
        return "Verificar"
    }

    private func handleMainButton() {
        guard !questions.isEmpty else { return }

        // 1) Ainda não revelou -> verificar resposta
        if !revealed {
            guard let selected else { return }
            revealed = true

            isCorrect = (selected == questions[index].correctIndex)
            if isCorrect {
                Haptics.success()
                correctCount += 1
                xpGained += 10

                // ✅ “Duolingo vibe”: acertou -> avança sozinho
                isAutoAdvancing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                    // proteção extra caso a view já tenha sido fechada
                    guard revealed else { return }
                    withAnimation(.easeInOut(duration: 0.20)) {
                        goNext()
                    }
                }
            } else {
                Haptics.error()

                // manda pra revisão
                let q = questions[index]
                let correct = q.options[q.correctIndex]
                wrongItems.append(
                    ReviewItem(
                        key: q.reviewKey,
                        prompt: q.prompt,
                        correct: correct,
                        hint: q.explanation
                    )
                )
            }
            return
        }

        // 2) Já revelou -> se errou, usuário clica para avançar
        if !isAutoAdvancing {
            withAnimation(.easeInOut(duration: 0.20)) {
                goNext()
            }
        }
    }

    // ✅ Função central: limpa estado e avança
    private func goNext() {
        revealed = false
        selected = nil
        isAutoAdvancing = false

        let nextValue = min(index + 1, questions.count)
        app.setProgress(for: mode, value: nextValue)

        if index >= questions.count - 1 {
            showResults = true
        } else {
            index += 1
        }
    }

    private func answerState(for i: Int) -> AnswerVisualState {
        guard revealed else {
            return (selected == i) ? .selected : .neutral
        }
        if i == questions[index].correctIndex { return .correct }
        if i == selected { return .wrong }
        return .neutral
    }
}
