import SwiftUI

struct ReviewSessionView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [Question] = []
    @State private var index: Int = 0

    @State private var selected: Int? = nil
    @State private var revealed: Bool = false
    @State private var isCorrect: Bool = false

    @State private var correctCount: Int = 0
    @State private var xpGained: Int = 0
    @State private var correctKeys: [String] = []

    @State private var showResults = false
    @State private var isAutoAdvancing: Bool = false

    private let autoAdvanceDelay: Double = 0.70

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    topBar

                    if questions.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView().scaleEffect(1.25)
                            Text("Preparando revisão")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                    } else {
                        QuestionCard(
                            title: "Revisão",
                            prompt: questions[index].prompt
                        )
                        .padding(.top, 4)
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .id("rq-\(questions[index].id)")

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
                questions = RandomEngine.buildReviewOnlySession(
                    reviewPool: app.reviewPool,
                    repo: app.content
                )
            }
            .sheet(isPresented: $showResults) {
                ReviewResultsView(
                    correctCount: correctCount,
                    total: questions.count,
                    xpGained: xpGained,
                    clearedSoFar: app.reviewClearedCount + correctCount,
                    poolTotal: app.reviewPoolTotal
                ) {
                    // Remove do pool os itens acertados
                    app.removeReviewItems(keys: correctKeys)
                    // Bônus de XP pelas palavras revisadas
                    if xpGained > 0 {
                        app.completeSession(
                            xpGained: xpGained,
                            correctRate: questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
                        )
                    }
                    showResults = false
                    dismiss()
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Revisão")
                        .font(.system(size: 20, weight: .heavy))
                    Text("Itens que você errou antes")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // Progresso acumulado: acertados no ciclo / total do ciclo
                Text("\(app.reviewClearedCount + correctCount)/\(app.reviewPoolTotal)")
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
                fill: AppColors.brandPurple
            )
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.25), value: index)
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
            colors: [AppColors.brandPurple, AppColors.brandBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var mainButtonEnabled: Bool { revealed ? true : (selected != nil) }

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
                xpGained += 8
                correctKeys.append(questions[index].reviewKey)

                isAutoAdvancing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                    guard revealed else { return }
                    withAnimation(.easeInOut(duration: 0.20)) { goNext() }
                }
            } else {
                Haptics.error()
            }
            return
        }

        if !isAutoAdvancing {
            withAnimation(.easeInOut(duration: 0.20)) { goNext() }
        }
    }

    private func goNext() {
        guard !questions.isEmpty else { return }
        if showResults { return }

        revealed = false
        selected = nil
        isAutoAdvancing = false

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

// MARK: - Tela de resultado da revisão

private struct ReviewResultsView: View {
    let correctCount: Int
    let total: Int
    let xpGained: Int
    let clearedSoFar: Int
    let poolTotal: Int
    let onFinish: () -> Void

    private var accuracy: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correctCount) / Double(total) * 100).rounded())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    // Ícone
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.brandPurple, AppColors.brandBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: AppColors.brandPurple.opacity(0.25), radius: 18, x: 0, y: 10)

                        Image(systemName: accuracy >= 80 ? "checkmark.seal.fill" : "arrow.triangle.2.circlepath")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 8) {
                        Text(accuracy >= 80 ? "Ótima revisão!" : "Continue praticando!")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(.primary)

                        Text("Você acertou \(correctCount) de \(total). Os acertos foram removidos da fila de revisão.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Stats
                    HStack(spacing: 12) {
                        statBox(title: "Revisados", value: "\(clearedSoFar)/\(poolTotal)", tint: AppColors.brandPurple)
                        statBox(title: "XP", value: "+\(xpGained)", tint: AppColors.brandGreen)
                        statBox(title: "Precisão", value: "\(accuracy)%", tint: AppColors.brandBlue)
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Button {
                        onFinish()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark")
                            Text("Concluir")
                        }
                        .font(.system(size: 18, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppColors.brandPurple, AppColors.brandBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: AppColors.brandPurple.opacity(0.22), radius: 16, x: 0, y: 10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func statBox(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(tint.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(tint.opacity(0.14), lineWidth: 1)
        )
    }
}
