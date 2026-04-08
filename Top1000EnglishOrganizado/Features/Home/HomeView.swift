import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppStore

    @State private var showSession = false
    @State private var selectedMode: PracticeMode = .words
    @State private var showScenarios = false
    @State private var showReviewSession = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    heroHeader
                    missionCard
                    reviewCard
                    rewardCard
                    streakCard
                    Spacer(minLength: 16)
                }
                .padding(.top, 12)
            }
            .safeAreaPadding(.horizontal, 16)
            .safeAreaPadding(.bottom, 120)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 96)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showSession) {
            PracticeSessionView(
                mode: selectedMode,
                startIndex: app.progress(for: selectedMode)
            )
            .environmentObject(app)
        }
        .sheet(isPresented: $showScenarios) {
            PracticeSessionView(
                mode: .scenario,
                startIndex: app.progress(for: .scenario)
            )
            .environmentObject(app)
        }
        .sheet(isPresented: $showReviewSession) {
            ReviewSessionView()
                .environmentObject(app)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }

    // MARK: - HERO

    private var heroHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppColors.heroNavy, AppColors.heroNavy2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 16)

            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("Fala, \(app.user.name)!")
                                .font(.system(size: 30, weight: .heavy))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)

                            Text("👋")
                                .font(.system(size: 26))
                        }

                        Text("Vamos evoluir hoje?")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.72))
                    }

                    Spacer()

                    LevelRingView(
                        level: app.user.level,
                        progress: levelProgress,
                        size: 74
                    )
                }

                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 2)
                    .padding(.vertical, 6)

                Button {
                    Haptics.light()

                    let mode = app.selectedPracticeMode

                    if mode == .scenario {
                        guard isScenarioUnlocked else { return }
                        showScenarios = true
                    } else {
                        selectedMode = mode
                        showSession = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Fazer progress")
                    }
                    .font(.system(size: 18, weight: .heavy))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppColors.brandBlue, AppColors.brandPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
                    .foregroundStyle(.white)
                    .shadow(
                        color: AppColors.brandPurple.opacity(pulse ? 0.40 : 0.26),
                        radius: pulse ? 28 : 16,
                        x: 0,
                        y: 14
                    )
                    .scaleEffect(pulse ? 1.01 : 1.0)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
    }

    // MARK: - MISSION

    private var missionCard: some View {
        CleanCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Missão do dia")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(app.dailyMissionStepsDone)/3 concluído")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 10) {
                    Button {
                        Haptics.light()
                        app.selectedPracticeMode = .words
                        selectedMode = .words
                        showSession = true
                    } label: {
                        MissionRow(
                            title: "Palavras",
                            icon: "checkmark.circle.fill",
                            iconTint: AppColors.brandGreen,
                            trailing: wordsTrailing,
                            trailingTint: app.progress(for: .words) >= sessionTotal ? AppColors.brandGreen : .secondary,
                            showProgressBar: app.progress(for: .words) > 0 && app.progress(for: .words) < sessionTotal,
                            progress: wordsProgress,
                            isSelected: app.selectedPracticeMode == .words,
                            isLast: false
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        Haptics.light()
                        app.selectedPracticeMode = .phrases
                        selectedMode = .phrases
                        showSession = true
                    } label: {
                        MissionRow(
                            title: "Frases",
                            icon: "text.justify.left",
                            iconTint: AppColors.brandBlue,
                            trailing: phrasesTrailing,
                            trailingTint: app.progress(for: .phrases) >= sessionTotal ? AppColors.brandGreen : .primary,
                            showProgressBar: app.progress(for: .phrases) > 0 && app.progress(for: .phrases) < sessionTotal,
                            progress: phrasesProgress,
                            isSelected: app.selectedPracticeMode == .phrases,
                            isLast: false
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        Haptics.light()
                        guard isScenarioUnlocked else { return }
                        app.selectedPracticeMode = .scenario
                        showScenarios = true
                    } label: {
                        MissionRow(
                            title: "Conversação",
                            icon: isScenarioUnlocked ? "message.fill" : "lock.fill",
                            iconTint: AppColors.brandPurple,
                            trailing: scenarioTrailing,
                            trailingTint: .secondary,
                            showProgressBar: isScenarioUnlocked && app.progress(for: .scenario) > 0 && app.progress(for: .scenario) < sessionTotal,
                            progress: scenarioProgress,
                            isSelected: isScenarioUnlocked && app.selectedPracticeMode == .scenario,
                            isLast: true
                        )
                        .opacity(isScenarioUnlocked ? 1.0 : 0.75)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
            }
        }
    }

    // MARK: - STREAK

    private var streakCard: some View {
        StreakRowView(
            title: "Sequência de 7 dias",
            streak: app.user.streak,
            activeCount: min(app.user.streak, 7)
        )
    }

    // MARK: - REWARD

    private var rewardCard: some View {
        RewardCardView(
            title: "Próxima recompensa",
            subtitle: "\(app.dailyMissionStepsDone)/3 etapas completas",
            progress: app.dailyMissionProgress
        )
    }

    // MARK: - REVIEW
    // Sempre visível. Vazio = "Tudo certo". Com erros = linha clicável igual MissionRow.

    private var reviewCard: some View {
        CleanCard {
            VStack(alignment: .leading, spacing: 14) {

                // Cabeçalho
                HStack {
                    Text("Revisão")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(app.reviewPoolTotal == 0
                         ? "0/0"
                         : "\(app.reviewClearedCount)/\(app.reviewPoolTotal)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                // Conteúdo interno — mesmo container branco do missionCard
                VStack(spacing: 10) {
                    if app.reviewPool.isEmpty {
                        // Estado padrão: nenhum erro acumulado
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppColors.brandGreen.opacity(0.14))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.brandGreen)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Tudo certo por aqui!")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.primary)
                                Text("Palavras e frases erradas aparecem aqui para revisar.")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)

                    } else {
                        // Há erros: linha clicável idêntica ao MissionRow
                        Button {
                            Haptics.light()
                            showReviewSession = true
                        } label: {
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(AppColors.brandPurple.opacity(0.14))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.brandPurple)
                                    }
                                    Text("Revisão Simplificada")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("\(app.reviewClearedCount)/\(app.reviewPoolTotal)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.secondary)
                                }

                                // Barra de progresso roxo igual ao MissionRow
                                ThinProgressBar(
                                    value: app.reviewPoolTotal > 0
                                        ? Double(app.reviewClearedCount) / Double(app.reviewPoolTotal)
                                        : 0,
                                    height: 6,
                                    trackOpacity: 0.10,
                                    fill: AppColors.brandPurple
                                )
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
            }
        }
    }

    // MARK: - Helpers

    private var levelProgress: Double {
        let perLevel = 250.0
        let mod = Double(app.user.xpTotal % 250)
        return max(0.0, min(1.0, mod / perLevel))
    }

    private var sessionTotal: Int {
        app.sessionQuestionCount
    }

    private var isScenarioUnlocked: Bool {
        app.isModeUnlocked(.scenario)
    }

    private var wordsTrailing: String {
        "\(app.progress(for: .words))/\(sessionTotal)"
    }

    private var phrasesTrailing: String {
        "\(app.progress(for: .phrases))/\(sessionTotal)"
    }

    private var scenarioTrailing: String {
        if !isScenarioUnlocked { return "Nível 10" }
        return "\(app.progress(for: .scenario))/\(sessionTotal)"
    }

    private var wordsProgress: Double {
        Double(app.progress(for: .words)) / Double(sessionTotal)
    }

    private var phrasesProgress: Double {
        Double(app.progress(for: .phrases)) / Double(sessionTotal)
    }

    private var scenarioProgress: Double {
        Double(app.progress(for: .scenario)) / Double(sessionTotal)
    }
}

// MARK: - MissionRow

private struct MissionRow: View {
    let title: String
    let icon: String
    let iconTint: Color
    let trailing: String
    let trailingTint: Color
    var showProgressBar: Bool = false
    var progress: Double = 0
    var isSelected: Bool = false
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconTint.opacity(0.14))
                        .frame(width: 34, height: 34)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(iconTint)
                }

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(trailing)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(trailingTint)
            }

            if showProgressBar {
                ThinProgressBar(
                    value: progress,
                    height: 6,
                    trackOpacity: 0.10,
                    fill: AppColors.brandBlue
                )
            }

            if !isLast {
                Divider().opacity(0.12)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? Color.black.opacity(0.035) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isSelected
                    ? AppColors.brandBlue.opacity(0.22)
                    : Color.clear,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
