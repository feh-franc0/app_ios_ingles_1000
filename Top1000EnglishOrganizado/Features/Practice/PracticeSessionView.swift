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
    @State private var isAutoAdvancing: Bool = false

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

                        Spacer()
                    } else {
                        QuestionCard(
                            title: mode.rawValue,
                            prompt: questions[index].prompt,
                            audioText: extractEnglishText(from: questions[index].prompt)
                        )
                        .padding(.top, 4)
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .id("q-\(questions[index].id)")

                        VStack(spacing: 12) {
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

                        Spacer()

                        bottomCTA
                    }
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
            .sheet(isPresented: $showResults) {
                ResultsView(
                    mode: mode,
                    correctCount: correctCount,
                    total: questions.count,
                    xpGained: xpGained,
                    wrongItems: wrongItems
                ) {
                    for item in wrongItems {
                        app.addReview(item)
                    }

                    let rate = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
                    app.setProgress(for: mode, value: questions.count)
                    app.completePractice(mode: mode, xpGained: xpGained, correctRate: rate)

                    showResults = false
                    dismiss()
                }
                .environmentObject(app)
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.system(size: 20, weight: .heavy))

                    Text("Continue sua sessão")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(min(index + 1, questions.count))/\(questions.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.05), in: Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ThinProgressBar(
                value: Double(index + 1) / Double(max(questions.count, 1)),
                height: 8,
                trackOpacity: 0.10,
                fill: AppColors.brandGreen
            )
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.25), value: index)
        }
    }

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
                Text(mainButtonTitle)
                    .font(.system(size: 17, weight: .heavy))
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

        if !revealed {
            guard let selected else { return }
            revealed = true

            isCorrect = (selected == questions[index].correctIndex)

            if isCorrect {
                Haptics.success()
                correctCount += 1
                xpGained += 10

                isAutoAdvancing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                    guard revealed else { return }
                    withAnimation(.easeInOut(duration: 0.20)) {
                        goNext()
                    }
                }
            } else {
                Haptics.error()

                let q = questions[index]
                let correct = q.options[q.correctIndex]

                let reviewItem = ReviewItem(
                    key: q.reviewKey,
                    prompt: q.prompt,
                    correct: correct,
                    hint: q.explanation
                )

                wrongItems.append(reviewItem)

                // ✅ Adiciona imediatamente ao pool de revisão
                // (não espera o usuário tocar "Concluir")
                app.addReview(reviewItem)
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
        // Formato: "Qual a tradução de "word"?" → extrai "word"
        if let range = prompt.range(of: "\u{201C}(.*?)\u{201D}", options: .regularExpression) {
            return String(prompt[range]).trimmingCharacters(in: CharacterSet(charactersIn: "\u{201C}\u{201D}"))
        }
        // Formato frase: extrai a parte em inglês após \n
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
