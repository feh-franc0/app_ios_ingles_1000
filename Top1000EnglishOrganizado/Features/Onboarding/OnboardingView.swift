import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var app: AppStore
    @State private var step: Int = 0
    @State private var name: String = ""
    @State private var selectedGoal: Int = 50
    @State private var selectedLevel: OnboardingLevel = .beginner
    @State private var animateIn = false

    private let goals = [20, 50, 100, 150]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.heroNavy, AppColors.heroNavy2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<4) { i in
                        Capsule()
                            .fill(i <= step ? Color.white : Color.white.opacity(0.25))
                            .frame(width: i == step ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: step)
                    }
                }
                .padding(.top, 60)

                Spacer()

                // Conteúdo do step atual
                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: nameStep
                    case 2: goalStep
                    case 3: levelStep
                    default: welcomeStep
                    }
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 30)

                Spacer()

                // Botão de avanço
                Button {
                    Haptics.medium()
                    advance()
                } label: {
                    Text(step == 3 ? "Começar agora" : "Continuar")
                        .font(.system(size: 18, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white)
                        )
                        .foregroundStyle(AppColors.heroNavy)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .disabled(step == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(step == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            }
        }
        .onAppear { triggerAnimation() }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Text("🇺🇸")
                .font(.system(size: 80))

            VStack(spacing: 12) {
                Text("Bem-vindo ao\nTop1000English")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Aprenda as 1000 palavras mais\nimportantes do inglês de forma prática.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
    }

    private var nameStep: some View {
        VStack(spacing: 24) {
            Text("👋")
                .font(.system(size: 64))

            VStack(spacing: 10) {
                Text("Qual é o seu nome?")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)

                Text("Vamos personalizar sua experiência")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.70))
            }

            TextField("Digite seu nome", text: $name)
                .font(.system(size: 20, weight: .bold))
                .padding(18)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
                .tint(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .padding(.horizontal, 32)
        }
    }

    private var goalStep: some View {
        VStack(spacing: 28) {
            Text("🎯")
                .font(.system(size: 64))

            VStack(spacing: 10) {
                Text("Qual sua meta diária?")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                Text("Você pode ajustar isso depois em Configurações")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.65))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ForEach(goals, id: \.self) { goal in
                    Button {
                        Haptics.light()
                        selectedGoal = goal
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(goal) XP por dia")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(selectedGoal == goal ? AppColors.heroNavy : .white)
                                Text(goalLabel(goal))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(selectedGoal == goal ? AppColors.heroNavy.opacity(0.7) : Color.white.opacity(0.6))
                            }
                            Spacer()
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppColors.heroNavy)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedGoal == goal ? Color.white : Color.white.opacity(0.10))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var levelStep: some View {
        VStack(spacing: 28) {
            Text("📊")
                .font(.system(size: 64))

            VStack(spacing: 10) {
                Text("Qual é o seu nível?")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                Text("Isso ajusta a dificuldade inicial do app")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.65))
            }

            VStack(spacing: 12) {
                ForEach(OnboardingLevel.allCases) { level in
                    Button {
                        Haptics.light()
                        selectedLevel = level
                    } label: {
                        HStack(spacing: 14) {
                            Text(level.emoji)
                                .font(.system(size: 28))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(level.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(selectedLevel == level ? AppColors.heroNavy : .white)
                                Text(level.description)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(selectedLevel == level ? AppColors.heroNavy.opacity(0.7) : Color.white.opacity(0.6))
                            }

                            Spacer()

                            if selectedLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppColors.heroNavy)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedLevel == level ? Color.white : Color.white.opacity(0.10))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Helpers

    private func advance() {
        if step < 3 {
            withAnimation(.easeOut(duration: 0.15)) { animateIn = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                step += 1
                triggerAnimation()
            }
        } else {
            finishOnboarding()
        }
    }

    private func triggerAnimation() {
        animateIn = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(0.05)) {
            animateIn = true
        }
    }

    private func finishOnboarding() {
        let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Estudante" : name
        app.completeOnboarding(name: finalName, dailyGoal: selectedGoal, level: selectedLevel.startLevel)
    }

    private func goalLabel(_ xp: Int) -> String {
        switch xp {
        case 20:  return "Leve — 5 min por dia"
        case 50:  return "Moderado — 10 min por dia"
        case 100: return "Intenso — 20 min por dia"
        default:  return "Máximo — 30 min por dia"
        }
    }
}

// MARK: - Nível de onboarding

enum OnboardingLevel: String, CaseIterable, Identifiable {
    case beginner, intermediate, advanced
    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner:     return "Iniciante"
        case .intermediate: return "Intermediário"
        case .advanced:     return "Avançado"
        }
    }

    var description: String {
        switch self {
        case .beginner:     return "Estou começando do zero"
        case .intermediate: return "Sei o básico, quero evoluir"
        case .advanced:     return "Já tenho uma boa base"
        }
    }

    var emoji: String {
        switch self {
        case .beginner:     return "🌱"
        case .intermediate: return "🌿"
        case .advanced:     return "🌳"
        }
    }

    var startLevel: Int {
        switch self {
        case .beginner:     return 1
        case .intermediate: return 5
        case .advanced:     return 10
        }
    }
}
