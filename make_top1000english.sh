#!/usr/bin/env bash
set -e

ROOT_DIR="Top1000EnglishOrganizado"
ZIP_NAME="Top1000English_Organizado.zip"

rm -rf "$ROOT_DIR" "$ZIP_NAME"

mkdir -p "$ROOT_DIR/App"
mkdir -p "$ROOT_DIR/Core/DesignSystem"
mkdir -p "$ROOT_DIR/Core/Components"
mkdir -p "$ROOT_DIR/State"
mkdir -p "$ROOT_DIR/Domain/Models"
mkdir -p "$ROOT_DIR/Domain/Engine"
mkdir -p "$ROOT_DIR/Data/Repository"
mkdir -p "$ROOT_DIR/Features/Home"
mkdir -p "$ROOT_DIR/Features/Path"
mkdir -p "$ROOT_DIR/Features/Practice"
mkdir -p "$ROOT_DIR/Features/Review"
mkdir -p "$ROOT_DIR/Features/Profile"

cat > "$ROOT_DIR/App/ContentView.swift" <<'EOF'
import SwiftUI

// MARK: - App Entry View (Tabs)

struct ContentView: View {
    @StateObject private var app = AppStore()

    var body: some View {
        NavigationStack {
            TabView {
                HomeView()
                    .environmentObject(app)
                    .tabItem { Label("Início", systemImage: "house.fill") }

                PathView()
                    .environmentObject(app)
                    .tabItem { Label("Trilha", systemImage: "map.fill") }

                ReviewView()
                    .environmentObject(app)
                    .tabItem { Label("Revisão", systemImage: "arrow.triangle.2.circlepath") }

                ProfileView()
                    .environmentObject(app)
                    .tabItem { Label("Perfil", systemImage: "person.fill") }
            }
            .tint(AppColors.brandGreen)
        }
    }
}

#Preview {
    ContentView()
}
EOF

cat > "$ROOT_DIR/Core/DesignSystem/AppColors.swift" <<'EOF'
import SwiftUI

enum AppColors {
    static let brandGreen = Color(red: 0.12, green: 0.82, blue: 0.36)
    static let brandBlue  = Color(red: 0.12, green: 0.58, blue: 1.00)
    static let brandPurple = Color(red: 0.66, green: 0.32, blue: 0.96)
    static let brandOrange = Color(red: 1.00, green: 0.56, blue: 0.18)
    static let brandRed = Color(red: 0.98, green: 0.25, blue: 0.30)

    static let card = Color(.secondarySystemBackground).opacity(0.9)
    static let stroke = Color.white.opacity(0.10)
}
EOF

cat > "$ROOT_DIR/Core/DesignSystem/Haptics.swift" <<'EOF'
import UIKit

enum Haptics {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}
EOF

cat > "$ROOT_DIR/Core/DesignSystem/StrongBackground.swift" <<'EOF'
import SwiftUI

struct StrongBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.brandGreen.opacity(0.18),
                    AppColors.brandBlue.opacity(0.12),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [AppColors.brandPurple.opacity(animate ? 0.22 : 0.10), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: animate)

            RadialGradient(
                colors: [AppColors.brandOrange.opacity(animate ? 0.14 : 0.06), .clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}
EOF

cat > "$ROOT_DIR/Core/Components/GlassCard.swift" <<'EOF'
import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppColors.stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }
}
EOF

cat > "$ROOT_DIR/Core/Components/SectionTitle.swift" <<'EOF'
import SwiftUI

struct SectionTitle: View {
    let title: String
    let subtitle: String

    init(_ title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
EOF

cat > "$ROOT_DIR/Core/Components/StatChip.swift" <<'EOF'
import SwiftUI

struct StatChip: View {
    let icon: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(text)
                .font(.system(size: 13, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(tint.opacity(0.16), in: Capsule())
        .overlay(Capsule().stroke(tint.opacity(0.22), lineWidth: 1))
    }
}
EOF

cat > "$ROOT_DIR/Core/Components/Badge.swift" <<'EOF'
import SwiftUI

struct Badge: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 44, height: 44)
                .background(AppColors.brandBlue.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
EOF

cat > "$ROOT_DIR/Domain/Models/Models.swift" <<'EOF'
import SwiftUI

enum PracticeMode: String, CaseIterable, Identifiable {
    case words = "Palavras"
    case phrases = "Frases"
    case scenario = "Cenários"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .words: return "textformat.abc"
        case .phrases: return "quote.bubble.fill"
        case .scenario: return "sparkles.rectangle.stack.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .words: return [AppColors.brandGreen, AppColors.brandBlue]
        case .phrases: return [AppColors.brandPurple, AppColors.brandBlue]
        case .scenario: return [AppColors.brandOrange, AppColors.brandPurple]
        }
    }
}

struct UserState {
    var name: String = "Franco"
    var streak: Int = 7
    var level: Int = 5
    var coins: Int = 120

    var xpTotal: Int = 1240
    var dailyGoalXP: Int = 50
    var todayXP: Int = 32
}

struct WordItem: Identifiable {
    let id: String
    let en: String
    let pt: String
    let example: String
    let tags: [String]
    let difficulty: Int
}

struct PhraseItem: Identifiable {
    let id: String
    let en: String
    let pt: String
    let tags: [String]
    let difficulty: Int
}

struct ScenarioItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let tags: [String]
}

enum QuestionType {
    case multipleChoice
}

struct Question: Identifiable {
    let id: String
    let type: QuestionType
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let reviewKey: String
}

struct ReviewItem: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let prompt: String
    let correct: String
    let hint: String
}
EOF

cat > "$ROOT_DIR/Data/Repository/ContentRepository.swift" <<'EOF'
import Foundation

struct ContentRepository {
    let words: [WordItem] = [
        .init(id: "w1", en: "because", pt: "porque", example: "I stayed because I was happy.", tags: ["work","daily"], difficulty: 1),
        .init(id: "w2", en: "always", pt: "sempre", example: "I always study at night.", tags: ["daily"], difficulty: 1),
        .init(id: "w3", en: "maybe", pt: "talvez", example: "Maybe we can go tomorrow.", tags: ["travel","daily"], difficulty: 1),
        .init(id: "w4", en: "before", pt: "antes", example: "Call me before you leave.", tags: ["travel"], difficulty: 2),
        .init(id: "w5", en: "after", pt: "depois", example: "We will talk after lunch.", tags: ["daily"], difficulty: 2),
        .init(id: "w6", en: "between", pt: "entre", example: "Between 5 and 6 pm.", tags: ["work"], difficulty: 2),
        .init(id: "w7", en: "around", pt: "por volta de", example: "Around 7 o’clock.", tags: ["travel"], difficulty: 2),
        .init(id: "w8", en: "enough", pt: "suficiente", example: "That’s enough for today.", tags: ["daily"], difficulty: 3),
        .init(id: "w9", en: "often", pt: "frequentemente", example: "I often practice speaking.", tags: ["daily"], difficulty: 2),
        .init(id: "w10", en: "usually", pt: "geralmente", example: "I usually wake up early.", tags: ["daily"], difficulty: 2),
        .init(id: "w11", en: "quick", pt: "rápido", example: "A quick call.", tags: ["work"], difficulty: 2),
        .init(id: "w12", en: "slow", pt: "lento", example: "Speak slow, please.", tags: ["travel"], difficulty: 2),
        .init(id: "w13", en: "cheap", pt: "barato", example: "This is cheap.", tags: ["travel"], difficulty: 2),
        .init(id: "w14", en: "expensive", pt: "caro", example: "It’s too expensive.", tags: ["travel"], difficulty: 2),
        .init(id: "w15", en: "help", pt: "ajuda", example: "Can you help me?", tags: ["travel","daily"], difficulty: 1),
        .init(id: "w16", en: "right", pt: "certo / direita", example: "Turn right.", tags: ["travel"], difficulty: 2),
        .init(id: "w17", en: "left", pt: "esquerda", example: "Turn left.", tags: ["travel"], difficulty: 2),
        .init(id: "w18", en: "open", pt: "abrir / aberto", example: "Is the store open?", tags: ["travel"], difficulty: 1),
        .init(id: "w19", en: "close", pt: "fechar / perto", example: "Close the door.", tags: ["daily"], difficulty: 1),
        .init(id: "w20", en: "ready", pt: "pronto", example: "I’m ready.", tags: ["work","daily"], difficulty: 1),
    ]

    let phrases: [PhraseItem] = [
        .init(id: "p1", en: "Could you help me?", pt: "Você pode me ajudar?", tags: ["travel","daily"], difficulty: 1),
        .init(id: "p2", en: "How much is this?", pt: "Quanto custa isso?", tags: ["travel"], difficulty: 1),
        .init(id: "p3", en: "I would like a coffee, please.", pt: "Eu gostaria de um café, por favor.", tags: ["cafe","travel"], difficulty: 1),
        .init(id: "p4", en: "Where is the bathroom?", pt: "Onde é o banheiro?", tags: ["travel"], difficulty: 1),
        .init(id: "p5", en: "I have a reservation.", pt: "Eu tenho uma reserva.", tags: ["hotel","travel"], difficulty: 1),
        .init(id: "p6", en: "Can you speak slowly?", pt: "Você pode falar devagar?", tags: ["travel"], difficulty: 1),
        .init(id: "p7", en: "What time does it open?", pt: "Que horas abre?", tags: ["travel"], difficulty: 2),
        .init(id: "p8", en: "I’m here for work.", pt: "Eu estou aqui a trabalho.", tags: ["work"], difficulty: 1),
        .init(id: "p9", en: "Let’s start the meeting.", pt: "Vamos começar a reunião.", tags: ["work"], difficulty: 2),
        .init(id: "p10", en: "I will be there in 10 minutes.", pt: "Eu estarei aí em 10 minutos.", tags: ["daily"], difficulty: 2),
        .init(id: "p11", en: "I don’t understand.", pt: "Eu não entendo.", tags: ["daily"], difficulty: 1),
        .init(id: "p12", en: "Can I pay by card?", pt: "Posso pagar no cartão?", tags: ["travel"], difficulty: 1),
        .init(id: "p13", en: "I’m looking for this address.", pt: "Estou procurando este endereço.", tags: ["travel"], difficulty: 2),
        .init(id: "p14", en: "I need a taxi.", pt: "Eu preciso de um táxi.", tags: ["travel"], difficulty: 1),
        .init(id: "p15", en: "One more, please.", pt: "Mais um, por favor.", tags: ["cafe","daily"], difficulty: 1),
        .init(id: "p16", en: "That’s enough for today.", pt: "Isso é suficiente por hoje.", tags: ["daily"], difficulty: 2),
        .init(id: "p17", en: "I’m ready.", pt: "Eu estou pronto.", tags: ["daily"], difficulty: 1),
        .init(id: "p18", en: "Turn right.", pt: "Vire à direita.", tags: ["travel"], difficulty: 1),
        .init(id: "p19", en: "Turn left.", pt: "Vire à esquerda.", tags: ["travel"], difficulty: 1),
        .init(id: "p20", en: "It’s too expensive.", pt: "Está caro demais.", tags: ["travel"], difficulty: 2),
    ]

    let scenarios: [ScenarioItem] = [
        .init(id: "s1", name: "Cafeteria", icon: "cup.and.saucer.fill", description: "Pedir, pagar, agradecer.", tags: ["cafe","daily"]),
        .init(id: "s2", name: "Aeroporto", icon: "airplane.departure", description: "Check-in, portão, horários.", tags: ["travel"]),
        .init(id: "s3", name: "Trabalho", icon: "briefcase.fill", description: "Reuniões, prazos, status.", tags: ["work"]),
    ]
}
EOF

cat > "$ROOT_DIR/Domain/Engine/RandomEngine.swift" <<'EOF'
import Foundation

struct RandomEngine {
    static func buildSession(
        mode: PracticeMode,
        repo: ContentRepository,
        reviewPool: [ReviewItem],
        count: Int = 10
    ) -> [Question] {

        let reviewCount = min(Int(Double(count) * 0.30), reviewPool.count)
        let newCount = count - reviewCount

        var questions: [Question] = []

        // 30% revisão
        if reviewCount > 0 {
            let picks = Array(reviewPool.shuffled().prefix(reviewCount))
            for item in picks {
                questions.append(
                    Question(
                        id: "r-\(item.key)",
                        type: .multipleChoice,
                        prompt: item.prompt,
                        options: makeOptions(correct: item.correct, pool: repo, mode: mode),
                        correctIndex: 0,
                        explanation: item.hint,
                        reviewKey: item.key
                    )
                    .normalizedCorrectFirst()
                )
            }
        }

        // 70% novos
        let newQs: [Question] = {
            switch mode {
            case .words:
                return makeWordQuestions(repo.words, repo: repo, limit: newCount)
            case .phrases:
                return makePhraseQuestions(repo.phrases, repo: repo, limit: newCount)
            case .scenario:
                return makeScenarioQuestions(repo: repo, limit: newCount)
            }
        }()

        questions.append(contentsOf: newQs)
        questions = shuffleAvoidingSamePrompt(questions)
        return Array(questions.prefix(count))
    }

    private static func makeWordQuestions(_ words: [WordItem], repo: ContentRepository, limit: Int) -> [Question] {
        var result: [Question] = []
        let picks = Array(words.shuffled().prefix(limit))

        for w in picks {
            let prompt = "Qual a tradução de “\(w.en)” ?"
            let correct = w.pt

            var options = [correct]
            let distractors = repo.words
                .filter { $0.id != w.id }
                .map { $0.pt }
                .shuffled()
                .prefix(3)

            options.append(contentsOf: distractors)
            options = options.shuffled()

            let correctIndex = options.firstIndex(of: correct) ?? 0
            let explanation = "Exemplo: “\(w.example)”"

            result.append(
                Question(
                    id: "w-\(w.id)",
                    type: .multipleChoice,
                    prompt: prompt,
                    options: options,
                    correctIndex: correctIndex,
                    explanation: explanation,
                    reviewKey: "w:\(w.en)"
                )
            )
        }

        return result
    }

    private static func makePhraseQuestions(_ phrases: [PhraseItem], repo: ContentRepository, limit: Int) -> [Question] {
        var result: [Question] = []
        let picks = Array(phrases.shuffled().prefix(limit))

        for p in picks {
            let prompt = "Qual a tradução da frase?\n“\(p.en)”"
            let correct = p.pt

            var options = [correct]
            let distractors = repo.phrases
                .filter { $0.id != p.id }
                .map { $0.pt }
                .shuffled()
                .prefix(3)

            options.append(contentsOf: distractors)
            options = options.shuffled()

            let correctIndex = options.firstIndex(of: correct) ?? 0
            let explanation = "Tag: \(p.tags.first ?? "daily")"

            result.append(
                Question(
                    id: "p-\(p.id)",
                    type: .multipleChoice,
                    prompt: prompt,
                    options: options,
                    correctIndex: correctIndex,
                    explanation: explanation,
                    reviewKey: "p:\(p.en)"
                )
            )
        }

        return result
    }

    private static func makeScenarioQuestions(repo: ContentRepository, limit: Int) -> [Question] {
        var result: [Question] = []
        let scenario = repo.scenarios.randomElement() ?? repo.scenarios[0]

        let relatedPhrases = repo.phrases.filter { !$0.tags.isEmpty && $0.tags.contains(where: scenario.tags.contains) }
        let relatedWords = repo.words.filter { !$0.tags.isEmpty && $0.tags.contains(where: scenario.tags.contains) }

        let phrasePool = (relatedPhrases.isEmpty ? repo.phrases : relatedPhrases)
        let wordPool = (relatedWords.isEmpty ? repo.words : relatedWords)

        let half = max(1, limit / 2)
        result.append(contentsOf: makePhraseQuestions(Array(phrasePool.shuffled().prefix(half)), repo: repo, limit: half))
        result.append(contentsOf: makeWordQuestions(Array(wordPool.shuffled().prefix(limit - half)), repo: repo, limit: (limit - half)))

        result = result.map { q in
            Question(
                id: q.id + "-s:\(scenario.id)",
                type: q.type,
                prompt: "Cenário: \(scenario.name)\n\n" + q.prompt,
                options: q.options,
                correctIndex: q.correctIndex,
                explanation: q.explanation,
                reviewKey: q.reviewKey
            )
        }

        return result
    }

    private static func makeOptions(correct: String, pool: ContentRepository, mode: PracticeMode) -> [String] {
        var options = [correct]

        let distractors: [String] = {
            switch mode {
            case .words:
                return pool.words.map { $0.pt }.filter { $0 != correct }.shuffled()
            case .phrases, .scenario:
                return pool.phrases.map { $0.pt }.filter { $0 != correct }.shuffled()
            }
        }()

        options.append(contentsOf: distractors.prefix(3))
        return options.shuffled()
    }

    private static func shuffleAvoidingSamePrompt(_ input: [Question]) -> [Question] {
        var arr = input.shuffled()
        for i in 1..<arr.count {
            if arr[i].prompt == arr[i-1].prompt {
                arr.swapAt(i, max(0, i-1))
            }
        }
        return arr
    }
}

private extension Question {
    func normalizedCorrectFirst() -> Question {
        let correct = options[correctIndex]
        var newOptions = options.filter { $0 != correct }
        newOptions.insert(correct, at: 0)
        return Question(
            id: id,
            type: type,
            prompt: prompt,
            options: newOptions,
            correctIndex: 0,
            explanation: explanation,
            reviewKey: reviewKey
        )
    }
}
EOF

cat > "$ROOT_DIR/State/AppStore.swift" <<'EOF'
import Combine
import Foundation

final class AppStore: ObservableObject {
    @Published var user = UserState()
    @Published var content = ContentRepository()
    @Published var reviewPool: [ReviewItem] = []

    func addReview(_ item: ReviewItem) {
        if !reviewPool.contains(where: { $0.key == item.key }) {
            reviewPool.insert(item, at: 0)
        }
        if reviewPool.count > 50 { reviewPool = Array(reviewPool.prefix(50)) }
    }

    func completeSession(xpGained: Int, correctRate: Double) {
        user.xpTotal += xpGained
        user.todayXP = min(user.dailyGoalXP, user.todayXP + xpGained)

        let newLevel = max(1, user.xpTotal / 250 + 1)
        if newLevel != user.level {
            user.level = newLevel
            Haptics.success()
        }
    }
}
EOF

cat > "$ROOT_DIR/Features/Home/ModePill.swift" <<'EOF'
import SwiftUI

struct ModePill: View {
    let mode: PracticeMode
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: mode.icon)
                .font(.system(size: 13, weight: .bold))
            Text(mode.rawValue)
                .font(.system(size: 13, weight: .bold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isSelected
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: mode.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(Color(.secondarySystemBackground).opacity(0.55))
                )
        }
        .foregroundStyle(isSelected ? .white : .primary)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.white.opacity(0.18) : Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: isSelected ? mode.gradient.first!.opacity(0.28) : .clear, radius: 14, x: 0, y: 10)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
    }
}
EOF

cat > "$ROOT_DIR/Features/Home/HomeView.swift" <<'EOF'
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppStore
    @State private var showSession = false
    @State private var selectedMode: PracticeMode = .words

    @State private var pulse = true

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meta diária")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)

                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(app.user.todayXP)/\(app.user.dailyGoalXP) XP hoje")
                                        .font(.system(size: 22, weight: .bold))
                                    Text("Consistência: 5 min por dia > 1h uma vez na semana.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()

                                Button {
                                    Haptics.light()
                                    showSession = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.fill")
                                        Text("Continuar")
                                    }
                                    .font(.system(size: 15, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.brandGreen, AppColors.brandBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 18)
                                    )
                                    .foregroundStyle(.white)
                                    .shadow(color: AppColors.brandGreen.opacity(0.35), radius: pulse ? 22 : 12, x: 0, y: 10)
                                    .scaleEffect(pulse ? 1.02 : 1.0)
                                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                                }
                                .buttonStyle(.plain)
                            }

                            ProgressView(value: Double(app.user.todayXP), total: Double(app.user.dailyGoalXP))
                                .tint(AppColors.brandGreen)
                                .scaleEffect(x: 1, y: 1.35, anchor: .center)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Modo de prática")
                                .font(.system(size: 16, weight: .bold))

                            HStack(spacing: 10) {
                                ForEach(PracticeMode.allCases) { mode in
                                    ModePill(mode: mode, isSelected: selectedMode == mode)
                                        .onTapGesture {
                                            Haptics.light()
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                selectedMode = mode
                                            }
                                        }
                                }
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        SectionTitle("Trilha de hoje", subtitle: "10 perguntas • feedback instantâneo • XP e streak")
                        TrailPreview()
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Top1000")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 10) {
                    StatChip(icon: "flame.fill", text: "\(app.user.streak)", tint: AppColors.brandOrange)
                    StatChip(icon: "sparkles", text: "\(app.user.xpTotal)", tint: AppColors.brandPurple)
                    StatChip(icon: "circle.hexagongrid.fill", text: "\(app.user.level)", tint: AppColors.brandBlue)
                }
            }
        }
        .sheet(isPresented: $showSession) {
            PracticeSessionView(mode: selectedMode)
                .environmentObject(app)
        }
        .onAppear {
            // Mantém a animação estável (evita “teleporte” de layout)
            pulse = true
        }
    }

    private var header: some View {
        GlassCard {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.brandGreen, AppColors.brandBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: AppColors.brandGreen.opacity(0.28), radius: 14, x: 0, y: 10)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fala, \(app.user.name) 👋")
                        .font(.system(size: 20, weight: .bold))
                    Text("Vamos praticar as palavras/frases mais usadas e subir de nível.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppColors.card)
                        .frame(width: 72, height: 54)

                    VStack(spacing: 4) {
                        Text("\(app.user.coins)")
                            .font(.system(size: 16, weight: .bold))
                        Text("moedas")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct TrailPreview: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Sessão rápida")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Text("10 perguntas")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.brandGreen.opacity(0.14), in: Capsule())
                }

                HStack(spacing: 10) {
                    ForEach(0..<6) { i in
                        Circle()
                            .fill(i < 2 ? AppColors.brandGreen : AppColors.brandBlue.opacity(0.22))
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                Text("Dica: errou → vai pra revisão automaticamente.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
EOF

cat > "$ROOT_DIR/Features/Path/PathNode.swift" <<'EOF'
import SwiftUI

struct PathNode: View {
    let index: Int
    let isLocked: Bool
    let onTap: () -> Void

    @State private var hover = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                if index % 2 == 0 { Spacer() }

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                isLocked
                                ? AnyShapeStyle(Color.gray.opacity(0.18))
                                : AnyShapeStyle(
                                    LinearGradient(
                                        colors: [AppColors.brandGreen, AppColors.brandBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                            .shadow(
                                color: isLocked ? .clear : AppColors.brandGreen.opacity(0.30),
                                radius: hover ? 22 : 12,
                                x: 0,
                                y: 12
                            )
                            .scaleEffect(hover ? 1.03 : 1.0)
                            .animation(.spring(response: 0.35, dampingFraction: 0.70), value: hover)

                        Image(systemName: isLocked ? "lock.fill" : "star.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isLocked ? .secondary : .white)
                    }

                    Text(isLocked ? "Bloqueado" : "Lição \(index)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                if index % 2 != 0 { Spacer() }
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            hover = pressing
        }, perform: {})
    }
}
EOF

cat > "$ROOT_DIR/Features/Path/PathView.swift" <<'EOF'
import SwiftUI

struct PathView: View {
    @EnvironmentObject private var app: AppStore
    @State private var showSession = false

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    SectionTitle("Trilha", subtitle: "Desbloqueie nós e ganhe moedas")
                        .padding(.top, 12)

                    VStack(spacing: 18) {
                        ForEach(1...10, id: \.self) { idx in
                            PathNode(index: idx, isLocked: idx > 3) {
                                if idx <= 3 {
                                    Haptics.medium()
                                    showSession = true
                                } else {
                                    Haptics.error()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Trilha")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSession) {
            PracticeSessionView(mode: .words)
                .environmentObject(app)
        }
    }
}
EOF

cat > "$ROOT_DIR/Features/Review/ReviewView.swift" <<'EOF'
import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var app: AppStore

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    SectionTitle("Revisão", subtitle: "O que você erra mais aparece aqui")
                        .padding(.top, 12)

                    if app.reviewPool.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sem itens para revisar 🙌")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Quando você errar uma palavra/frase, ela entra aqui automaticamente.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            ForEach(app.reviewPool) { item in
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.prompt)
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Correto: \(item.correct)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(AppColors.brandGreen)
                                        Text(item.hint)
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Revisão")
        .navigationBarTitleDisplayMode(.inline)
    }
}
EOF

cat > "$ROOT_DIR/Features/Profile/ProfileView.swift" <<'EOF'
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var app: AppStore

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    GlassCard {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.brandPurple, AppColors.brandBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 62, height: 62)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.user.name)
                                    .font(.system(size: 20, weight: .bold))
                                Text("Nível \(app.user.level) • \(app.user.xpTotal) XP")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Badges")
                                .font(.system(size: 16, weight: .bold))

                            HStack(spacing: 10) {
                                Badge(icon: "cup.and.saucer.fill", title: "Café")
                                Badge(icon: "airplane.departure", title: "Aeroporto")
                                Badge(icon: "briefcase.fill", title: "Trabalho")
                            }
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Assinatura")
                                .font(.system(size: 16, weight: .bold))
                            Text("Bloqueie distrações, libere speaking ilimitado e cenários avançados.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)

                            Button {
                                Haptics.light()
                            } label: {
                                Text("Ver Premium")
                                    .font(.system(size: 15, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.brandOrange, AppColors.brandPurple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 18)
                                    )
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }
}
EOF

cat > "$ROOT_DIR/Features/Practice/AnswerButton.swift" <<'EOF'
import SwiftUI

enum AnswerVisualState { case neutral, selected, correct, wrong }

struct AnswerButton: View {
    let text: String
    let state: AnswerVisualState
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            .padding(14)
            .background(bg, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var bg: Color {
        switch state {
        case .neutral: return Color(.secondarySystemBackground).opacity(0.55)
        case .selected: return AppColors.brandBlue.opacity(0.18)
        case .correct: return AppColors.brandGreen.opacity(0.18)
        case .wrong: return AppColors.brandRed.opacity(0.18)
        }
    }

    private var border: Color {
        switch state {
        case .neutral: return Color.primary.opacity(0.08)
        case .selected: return AppColors.brandBlue.opacity(0.35)
        case .correct: return AppColors.brandGreen.opacity(0.35)
        case .wrong: return AppColors.brandRed.opacity(0.35)
        }
    }

    private var icon: String {
        switch state {
        case .neutral: return "circle"
        case .selected: return "circle.inset.filled"
        case .correct: return "checkmark.circle.fill"
        case .wrong: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch state {
        case .neutral: return .secondary
        case .selected: return AppColors.brandBlue
        case .correct: return AppColors.brandGreen
        case .wrong: return AppColors.brandRed
        }
    }
}
EOF

cat > "$ROOT_DIR/Features/Practice/QuestionCard.swift" <<'EOF'
import SwiftUI

struct QuestionCard: View {
    let title: String
    let prompt: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)

                Text(prompt)
                    .font(.system(size: 20, weight: .bold))
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, 16)
    }
}
EOF

cat > "$ROOT_DIR/Features/Practice/FeedbackBanner.swift" <<'EOF'
import SwiftUI

struct FeedbackBanner: View {
    let isCorrect: Bool
    let explanation: String

    var body: some View {
        GlassCard {
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isCorrect ? AppColors.brandGreen : AppColors.brandRed)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isCorrect ? "Boa! +10 XP" : "Quase! Vai pra revisão.")
                        .font(.system(size: 14, weight: .bold))

                    Text(explanation)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }
}
EOF

cat > "$ROOT_DIR/Features/Practice/Metric.swift" <<'EOF'
import SwiftUI

struct Metric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 18, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(tint.opacity(0.20), lineWidth: 1))
    }
}
EOF

cat > "$ROOT_DIR/Features/Practice/ResultsView.swift" <<'EOF'
import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    let mode: PracticeMode
    let correctCount: Int
    let total: Int
    let xpGained: Int
    let wrongItems: [ReviewItem]
    let onCommit: () -> Void

    private var accuracy: Int {
        guard total > 0 else { return 0 }
        let value = (Double(correctCount) / Double(total)) * 100.0
        return Int(value.rounded())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                StrongBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Resultado")
                                    .font(.system(size: 20, weight: .bold))

                                HStack(spacing: 10) {
                                    Metric(title: "Precisão", value: "\(accuracy)%", tint: AppColors.brandBlue)
                                    Metric(title: "XP", value: "+\(xpGained)", tint: AppColors.brandGreen)
                                    Metric(title: "Acertos", value: "\(correctCount)/\(total)", tint: AppColors.brandPurple)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        if !wrongItems.isEmpty {
                            SectionTitle("Entrou pra revisão", subtitle: "Você vai ver isso de novo pra fixar")
                                .padding(.horizontal, 16)

                            VStack(spacing: 10) {
                                ForEach(wrongItems) { item in
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(item.prompt)
                                                .font(.system(size: 14, weight: .bold))

                                            Text("Correto: \(item.correct)")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(AppColors.brandGreen)

                                            Text(item.hint)
                                                .font(.system(size: 12))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }

                        GlassCard {
                            Button {
                                onCommit()
                                Haptics.success()
                                dismiss()
                            } label: {
                                Text("Concluir")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.brandGreen, AppColors.brandBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 18)
                                    )
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Finalizado")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
EOF

cat > "$ROOT_DIR/Features/Practice/PracticeSessionView.swift" <<'EOF'
import SwiftUI

struct PracticeSessionView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    let mode: PracticeMode

    @State private var questions: [Question] = []
    @State private var index: Int = 0

    @State private var selected: Int? = nil
    @State private var revealed: Bool = false
    @State private var isCorrect: Bool = false

    @State private var correctCount: Int = 0
    @State private var xpGained: Int = 0
    @State private var wrongItems: [ReviewItem] = []

    @State private var showResults = false

    var body: some View {
        NavigationStack {
            ZStack {
                StrongBackground()

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
                        QuestionCard(title: mode.rawValue, prompt: questions[index].prompt)

                        VStack(spacing: 10) {
                            ForEach(questions[index].options.indices, id: \.self) { i in
                                AnswerButton(
                                    text: questions[index].options[i],
                                    state: answerState(for: i),
                                    isDisabled: revealed
                                ) {
                                    Haptics.light()
                                    selected = i
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
            }
            .sheet(isPresented: $showResults) {
                ResultsView(
                    mode: mode,
                    correctCount: correctCount,
                    total: questions.count,
                    xpGained: xpGained,
                    wrongItems: wrongItems
                ) {
                    for item in wrongItems { app.addReview(item) }
                    let rate = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
                    app.completeSession(xpGained: xpGained, correctRate: rate)
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

                Text("\(index+1)/\(max(questions.count, 10))")
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
            .disabled(!mainButtonEnabled)
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
        if !revealed {
            guard let selected else { return }
            revealed = true

            isCorrect = (selected == questions[index].correctIndex)
            if isCorrect {
                Haptics.success()
                correctCount += 1
                xpGained += 10
            } else {
                Haptics.error()
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

        revealed = false
        selected = nil

        if index == questions.count - 1 {
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
EOF

# Zip
(cd "$ROOT_DIR" && zip -r "../$ZIP_NAME" . >/dev/null)

echo "✅ Gerado: $ZIP_NAME"
echo "📁 Pasta com arquivos: $ROOT_DIR"

chmod +x make_top1000english.sh

cat <<'DONE'

✅ Pronto.
Agora rode:

  ./make_top1000english.sh

Vai criar:
- Top1000EnglishOrganizado/ (com a estrutura)
- Top1000English_Organizado.zip

Depois, no Xcode, arrasta as pastas pra dentro do projeto e marca:
- Copy items if needed
- Add to targets

DONE

chmod +x "$ROOT_DIR"/../make_top1000english.sh || true

# Criar zip do próprio script também (opcional)
zip -r "$ZIP_NAME" "$ROOT_DIR" >/dev/null 2>&1 || true

# Por fim, imprime instruções
printf "\n✅ Script e estrutura prontos. Rode: ./make_top1000english.sh\n"
