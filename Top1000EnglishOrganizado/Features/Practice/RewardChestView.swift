import SwiftUI

// ─────────────────────────────────────────────────────────────────────
// MARK: - RewardChestView
// Substituiu a tela de ResultsView como tela final de sessão.
// Abre o baú com animação, revela as recompensas, depois mostra stats.
// ─────────────────────────────────────────────────────────────────────

struct RewardChestView: View {
    @EnvironmentObject private var app: AppStore

    let mode: PracticeMode
    let correctCount: Int
    let total: Int
    let xpGained: Int
    let wrongItems: [ReviewItem]
    let onFinish: () -> Void

    // ── Estados da animação ────────────────────────────────────────
    @State private var phase: ChestPhase = .idle
    @State private var chestScale: CGFloat   = 1.0
    @State private var chestShake: CGFloat   = 0
    @State private var lidAngle: Double      = 0
    @State private var particlesVisible      = false
    @State private var rewardsVisible        = false
    @State private var statsVisible          = false
    @State private var glowOpacity: Double   = 0

    // ── Partículas ─────────────────────────────────────────────────
    @State private var particles: [ChestParticle] = []
    @State private var screenSize: CGSize = CGSize(width: 390, height: 844)

    private enum ChestPhase { case idle, shaking, opening, revealed }

    private var reward: ChestReward {
        ChestReward.generate(
            accuracy: correctRate,
            streak: app.user.streak,
            isPerfect: correctCount == total && total > 0
        )
    }

    private var correctRate: Double {
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total)
    }

    var body: some View {
        ZStack {
            // Captura dimensões reais da tela (evita UIScreen.main deprecated)
            GeometryReader { geo in Color.clear.onAppear { screenSize = geo.size } }
                .ignoresSafeArea()

            // Fundo gradiente escuro
            LinearGradient(
                colors: [AppColors.heroNavy, AppColors.heroSlate, Color(red: 0.12, green: 0.06, blue: 0.28)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Glow do tier
            RadialGradient(
                colors: [(reward.tier.gradient.first ?? .clear).opacity(glowOpacity * 0.45), .clear],
                center: .center, startRadius: 30, endRadius: 280
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: glowOpacity)

            // Partículas
            ForEach(particles) { p in
                Text(p.symbol)
                    .font(.system(size: p.size))
                    .position(x: p.x, y: p.y)
                    .opacity(p.opacity)
                    .rotationEffect(.degrees(p.rotation))
            }

            VStack(spacing: 0) {
                Spacer()

                // ── Baú ────────────────────────────────────────────
                chestView
                    .padding(.bottom, 32)

                // ── Tier label ──────────────────────────────────────
                if phase == .idle || phase == .shaking {
                    Text("Toque para abrir!")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .transition(.opacity)
                }

                // ── Recompensas reveladas ───────────────────────────
                if rewardsVisible {
                    rewardsPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 24)
                }

                Spacer()

                // ── Stats + Botão Concluir ──────────────────────────
                if statsVisible {
                    bottomPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .onTapGesture {
            guard phase == .idle else { return }
            startOpeningSequence()
        }
        .onAppear {
            spawnParticleLoop()
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Chest View
    // ─────────────────────────────────────────────────────────────────

    private var chestView: some View {
        ZStack(alignment: .bottom) {
            // Sombra glow
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [(reward.tier.gradient.first ?? AppColors.brandOrange).opacity(0.40), .clear],
                        center: .center, startRadius: 10, endRadius: 70
                    )
                )
                .frame(width: 160, height: 30)
                .offset(y: 20)
                .blur(radius: 8)

            VStack(spacing: 0) {
                // Tampa do baú (rotaciona para abrir)
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(
                            colors: reward.tier.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 110, height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.20), lineWidth: 1.5)
                        )
                    Text(reward.tier.emoji)
                        .font(.system(size: 22))
                }
                .rotation3DEffect(.degrees(lidAngle), axis: (1, 0, 0), anchor: .bottom)

                // Corpo do baú
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(
                        colors: reward.tier.gradient.map { $0.opacity(0.80) },
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 130, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.20), lineWidth: 1.5)
                    )
                    .overlay(
                        // Fechadura
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.35))
                                .frame(width: 22, height: 22)
                            Image(systemName: phase == .revealed ? "lock.open.fill" : "lock.fill")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.white.opacity(0.80))
                        }
                    )
            }
        }
        .scaleEffect(chestScale)
        .offset(x: chestShake)
        .shadow(
            color: (reward.tier.gradient.first ?? AppColors.brandOrange).opacity(0.45),
            radius: 30, x: 0, y: 16
        )
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Rewards Panel
    // ─────────────────────────────────────────────────────────────────

    private var rewardsPanel: some View {
        VStack(spacing: 16) {
            Text(reward.message)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 14) {
                rewardChip(emoji: "⭐️", value: "+\(reward.xpBonus) XP",   color: AppColors.brandGreen)
                rewardChip(emoji: "🪙", value: "+\(reward.coinBonus)",      color: AppColors.gold)
                if reward.freezeBonus > 0 {
                    rewardChip(emoji: "🛡️", value: "+\(reward.freezeBonus) Freeze", color: AppColors.brandBlue)
                }
            }
        }
    }

    private func rewardChip(emoji: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 26))
            Text(value)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.35), lineWidth: 1.5)
                )
        )
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Bottom Panel
    // ─────────────────────────────────────────────────────────────────

    private var bottomPanel: some View {
        VStack(spacing: 14) {
            // Stats rápidos
            HStack(spacing: 10) {
                miniStat(value: "\(correctCount)/\(total)", label: "Acertos",
                         color: AppColors.brandBlue)
                miniStat(value: "\(Int(correctRate * 100))%", label: "Precisão",
                         color: correctRate >= 0.80 ? AppColors.brandGreen : AppColors.brandOrange)
                miniStat(value: "+\(xpGained)", label: "XP",
                         color: AppColors.brandPurple)
            }

            // Botão concluir
            Button {
                Haptics.success()
                app.applyChestReward(reward)
                onFinish()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .bold))
                    Text("Continuar")
                        .font(.system(size: 18, weight: .heavy))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(
                            colors: reward.tier.gradient,
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .shadow(color: (reward.tier.gradient.first ?? .clear).opacity(0.45),
                                radius: 14, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func miniStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Animation Sequence
    // ─────────────────────────────────────────────────────────────────

    private func startOpeningSequence() {
        Haptics.medium()
        phase = .shaking

        // 1. Baú treme
        withAnimation(.easeInOut(duration: 0.08).repeatCount(6, autoreverses: true)) {
            chestShake = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            chestShake = 0
            phase = .opening

            // 2. Tampa abre (rotation3D)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                lidAngle = -130
                chestScale = 1.12
                glowOpacity = 1.0
            }

            // 3. Partículas explodem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                Haptics.success()
                explodeParticles()

                // 4. Recompensas aparecem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                    phase = .revealed
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                        rewardsVisible = true
                    }

                    // 5. Stats aparecem depois
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                            statsVisible = true
                        }
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Particles
    // ─────────────────────────────────────────────────────────────────

    private let symbols = ["⭐️","💰","🪙","✨","🎉","💎","🔥","🎯","⚡️","🏆"]

    private func explodeParticles() {
        particles = (0..<30).map { _ in
            ChestParticle(
                symbol: symbols.randomElement() ?? "⭐️",
                x: screenSize.width / 2,
                y: screenSize.height * 0.42,
                size: CGFloat.random(in: 16...32),
                opacity: 1.0,
                rotation: Double.random(in: -180...180)
            )
        }

        for i in particles.indices {
            let dx = CGFloat.random(in: -180...180)
            let dy = CGFloat.random(in: -260 ... -60)
            withAnimation(.easeOut(duration: Double.random(in: 0.7...1.3))) {
                particles[i].x += dx
                particles[i].y += dy
                particles[i].opacity = 0
                particles[i].rotation += Double.random(in: -360...360)
            }
        }
    }

    private func spawnParticleLoop() {
        // Partículas flutuantes enquanto idle
        guard phase == .idle else { return }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - ChestParticle model
// ─────────────────────────────────────────────────────────────────────

private struct ChestParticle: Identifiable {
    let id = UUID()
    let symbol: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
    var rotation: Double
}
