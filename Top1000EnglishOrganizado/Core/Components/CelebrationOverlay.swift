import SwiftUI

struct CelebrationOverlay: View {
    let type: CelebrationType
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }

                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(p.position)
                        .opacity(p.opacity)
                }

                VStack(spacing: 18) {
                    Text(type.emoji)
                        .font(.system(size: 72))
                        .scaleEffect(scale)

                    VStack(spacing: 8) {
                        Text(type.title)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(type.subtitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Continuar")
                            .font(.system(size: 17, weight: .heavy))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: type.colors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: .black.opacity(0.18), radius: 40, x: 0, y: 20)
                .padding(.horizontal, 32)
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                spawnParticles(in: geometry.size)

                withAnimation(.spring(response: 0.5, dampingFraction: 0.68)) {
                    scale = 1.0
                    opacity = 1.0
                }

                Haptics.success()

                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    dismiss()
                }
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            scale = 0.85
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }

    private func spawnParticles(in size: CGSize) {
        let colors: [Color] = [.yellow, .orange, .pink, .green, .blue, .purple]
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: center.x + CGFloat.random(in: -160...160),
                    y: center.y + CGFloat.random(in: -260...260)
                ),
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 6...14),
                opacity: Double.random(in: 0.6...1.0)
            )
        }

        withAnimation(.easeOut(duration: 2.5)) {
            particles = particles.map { p in
                Particle(
                    position: CGPoint(x: p.position.x, y: p.position.y + 200),
                    color: p.color,
                    size: p.size,
                    opacity: 0
                )
            }
        }
    }
}

enum CelebrationType {
    case levelUp(Int)
    case missionComplete
    case streakMilestone(Int)
    case perfectSession

    var emoji: String {
        switch self {
        case .levelUp: return "⬆️"
        case .missionComplete: return "🎯"
        case .streakMilestone: return "🔥"
        case .perfectSession: return "⭐️"
        }
    }

    var title: String {
        switch self {
        case .levelUp(let lvl): return "Nível \(lvl)!"
        case .missionComplete: return "Missão Completa!"
        case .streakMilestone(let d): return "\(d) dias seguidos!"
        case .perfectSession: return "Sessão Perfeita!"
        }
    }

    var subtitle: String {
        switch self {
        case .levelUp: return "Você subiu de nível. Continue assim!"
        case .missionComplete: return "Você completou todas as etapas de hoje. +25 moedas e +30 XP!"
        case .streakMilestone: return "Sua dedicação é incrível. Não pare agora!"
        case .perfectSession: return "100% de acertos! Você está mandando muito bem."
        }
    }

    var colors: [Color] {
        switch self {
        case .levelUp: return [AppColors.brandBlue, AppColors.brandPurple]
        case .missionComplete: return [AppColors.brandGreen, AppColors.brandBlue]
        case .streakMilestone: return [AppColors.brandOrange, .red]
        case .perfectSession: return [.yellow, AppColors.brandOrange]
        }
    }
}

private struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
}

struct CelebrationModifier: ViewModifier {
    @Binding var celebration: CelebrationType?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let type = celebration {
                CelebrationOverlay(type: type) {
                    celebration = nil
                }
                .zIndex(999)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: celebration == nil)
    }
}

extension View {
    func celebration(_ type: Binding<CelebrationType?>) -> some View {
        modifier(CelebrationModifier(celebration: type))
    }
}
