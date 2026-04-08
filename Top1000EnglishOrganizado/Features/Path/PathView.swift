import SwiftUI

// ─────────────────────────────────────────────────────────────────────
// Dados dos capítulos da trilha
// ─────────────────────────────────────────────────────────────────────

private struct Chapter {
    let title: String
    let subtitle: String
    let emoji: String
    let gradient: [Color]
    let nodeRange: ClosedRange<Int>
}

private let chapters: [Chapter] = [
    Chapter(title: "Básico",         subtitle: "100 palavras essenciais",      emoji: "🌱", gradient: [AppColors.brandGreen, Color(red: 0.00, green: 0.72, blue: 0.72)],   nodeRange: 1...3),
    Chapter(title: "Sobrevivência",  subtitle: "Situações do dia a dia",       emoji: "🏡", gradient: [AppColors.brandBlue, AppColors.brandPurple],                          nodeRange: 4...6),
    Chapter(title: "Intermediário",  subtitle: "Conversas mais complexas",     emoji: "⚡️", gradient: [AppColors.brandPurple, Color(red: 0.80, green: 0.20, blue: 0.90)],   nodeRange: 7...8),
    Chapter(title: "Avançado",       subtitle: "Fluência e expressões idiom.", emoji: "🚀", gradient: [AppColors.brandOrange, Color(red: 0.90, green: 0.20, blue: 0.30)],    nodeRange: 9...10),
]

// ─────────────────────────────────────────────────────────────────────
// PathView
// ─────────────────────────────────────────────────────────────────────

struct PathView: View {
    @EnvironmentObject private var app: AppStore
    @State private var showSession = false
    @State private var selectedNode: PathNodeData? = nil

    private let highestUnlocked = 3  // mock: primeiros 3 desbloqueados

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Cabeçalho fixo escuro
                    pathHeader

                    // Conteúdo da trilha
                    VStack(spacing: 0) {
                        ForEach(chapters.indices, id: \.self) { cIdx in
                            chapterSection(chapters[cIdx], chapterIndex: cIdx)
                        }
                    }
                    .padding(.bottom, 110)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showSession) {
            PracticeSessionView(mode: .words, startIndex: app.progress(for: .words))
                .environmentObject(app)
        }
        .sheet(item: $selectedNode) { node in
            NodeDetailSheet(node: node) {
                selectedNode = nil
                showSession = true
            }
        }
    }

    // ── Header ────────────────────────────────────────────────────

    private var pathHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [AppColors.heroNavy, AppColors.heroSlate],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trilha de Aprendizado")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(.white)
                        Text("Desbloqueie lições e conquiste medalhas")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.60))
                    }
                    Spacer()
                    // Progress geral
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 5)
                        Circle()
                            .trim(from: 0, to: Double(highestUnlocked) / 10.0)
                            .stroke(AppColors.brandGreen, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 0) {
                            Text("\(highestUnlocked)")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundStyle(.white)
                            Text("/10")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.55))
                        }
                    }
                    .frame(width: 56, height: 56)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .frame(height: 130)
        .shadow(color: .black.opacity(0.28), radius: 20, x: 0, y: 10)
    }

    // ── Chapter Section ──────────────────────────────────────────

    private func chapterSection(_ chapter: Chapter, chapterIndex: Int) -> some View {
        VStack(spacing: 0) {
            // Chapter header banner
            chapterHeader(chapter)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 8)

            // Nodes com zigzag
            zigzagNodes(chapter: chapter, chapterIndex: chapterIndex)
                .padding(.bottom, 8)
        }
    }

    private func chapterHeader(_ chapter: Chapter) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(
                        colors: chapter.gradient,
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                    .shadow(color: (chapter.gradient.first ?? .clear).opacity(0.35), radius: 10, x: 0, y: 5)
                Text(chapter.emoji).font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(chapter.title)
                    .font(.system(size: 16, weight: .heavy))
                Text(chapter.subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Quantas lições do capítulo foram desbloqueadas
            let total = chapter.nodeRange.count
            let done  = chapter.nodeRange.filter { $0 <= highestUnlocked }.count
            Text("\(done)/\(total)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(done == total ? AppColors.brandGreen : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(done == total ? AppColors.brandGreen.opacity(0.10) : Color.black.opacity(0.05))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }

    // ── Zigzag path ──────────────────────────────────────────────

    private func zigzagNodes(chapter: Chapter, chapterIndex: Int) -> some View {
        let nodes = buildNodes(for: chapter)
        return VStack(spacing: 0) {
            ForEach(nodes.indices, id: \.self) { i in
                let node = nodes[i]
                let alignment: HorizontalAlignment = zigzagAlignment(index: i, chapterIndex: chapterIndex)

                VStack(spacing: 0) {
                    HStack {
                        if alignment == .trailing { Spacer() }
                        PathNodeView(node: node) {
                            guard !node.isLocked else { Haptics.error(); return }
                            Haptics.medium()
                            selectedNode = node
                        }
                        .padding(.horizontal, 36)
                        if alignment == .leading { Spacer() }
                    }

                    // Conector para o próximo nó
                    if i < nodes.count - 1 {
                        connector(from: alignment, to: zigzagAlignment(index: i + 1, chapterIndex: chapterIndex), node: node)
                    }
                }
            }
        }
    }

    private func zigzagAlignment(index: Int, chapterIndex: Int) -> HorizontalAlignment {
        // Zigzag: alterna mas mantém consistência por capítulo
        let offset = chapterIndex % 2
        return (index + offset) % 2 == 0 ? .leading : .trailing
    }

    @ViewBuilder
    private func connector(from: HorizontalAlignment, to: HorizontalAlignment, node: PathNodeData) -> some View {
        let isDone = node.isCompleted
        let color: Color = isDone ? AppColors.brandGreen : Color.gray.opacity(0.25)

        if from == to {
            // Linha reta vertical
            VStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Circle()
                        .fill(color)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 36)
            .frame(maxWidth: .infinity, alignment: from == .leading ? .leading : .trailing)
            .padding(.horizontal, 72)
        } else {
            // Curva: zig
            ZStack {
                // Linha curva simulada com dots
                GeometryReader { geo in
                    let w = geo.size.width
                    Path { p in
                        let startX: CGFloat = from == .leading ? 108 : w - 108
                        let endX:   CGFloat = from == .leading ? w - 108 : 108
                        p.move(to: CGPoint(x: startX, y: 5))
                        p.addCurve(
                            to: CGPoint(x: endX, y: 55),
                            control1: CGPoint(x: startX, y: 40),
                            control2: CGPoint(x: endX, y: 20)
                        )
                    }
                    .stroke(
                        isDone ? AppColors.brandGreen : Color.gray.opacity(0.22),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: isDone ? [] : [6, 5])
                    )
                }
            }
            .frame(height: 60)
        }
    }

    private func buildNodes(for chapter: Chapter) -> [PathNodeData] {
        chapter.nodeRange.map { idx in
            PathNodeData(
                id: idx,
                lessonNumber: idx,
                chapter: chapter.title,
                chapterColor: chapter.gradient,
                emoji: nodeEmoji(for: idx),
                isCompleted: idx < highestUnlocked,
                isActive: idx == highestUnlocked,
                isLocked: idx > highestUnlocked
            )
        }
    }

    private func nodeEmoji(for index: Int) -> String {
        let emojis = ["📚","🔤","💡","🗣️","✍️","🎯","📖","🧠","⚡️","🏆"]
        return emojis[(index - 1) % emojis.count]
    }
}

// ─────────────────────────────────────────────────────────────────────
// NodeDetailSheet — Preview antes de iniciar a lição
// ─────────────────────────────────────────────────────────────────────

struct NodeDetailSheet: View {
    let node: PathNodeData
    let onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            VStack(spacing: 24) {
                // Ícone grande
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: node.chapterColor,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                        .shadow(color: (node.chapterColor.first ?? AppColors.brandBlue).opacity(0.35), radius: 20, x: 0, y: 10)
                    Text(node.emoji).font(.system(size: 46))
                }
                .padding(.top, 24)

                VStack(spacing: 8) {
                    Text("Lição \(node.lessonNumber)")
                        .font(.system(size: 28, weight: .heavy))
                    Text(node.chapter)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                // Info chips
                HStack(spacing: 12) {
                    infoChip(icon: "questionmark.circle.fill", label: "10 perguntas", color: AppColors.brandBlue)
                    infoChip(icon: "bolt.fill", label: "+100 XP", color: AppColors.brandOrange)
                    infoChip(icon: "clock.fill", label: "~3 min", color: AppColors.brandPurple)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onStart()
                        }
                    } label: {
                        Label("Começar lição", systemImage: "play.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(LinearGradient(
                                        colors: node.chapterColor,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .shadow(color: (node.chapterColor.first ?? AppColors.brandGreen).opacity(0.40), radius: 14, x: 0, y: 6)
                            )
                    }
                    .buttonStyle(.plain)

                    Button("Cancelar") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    private func infoChip(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.10), in: Capsule())
    }
}
