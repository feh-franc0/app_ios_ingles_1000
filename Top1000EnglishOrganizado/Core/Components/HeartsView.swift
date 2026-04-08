import SwiftUI

/// Corações estilo Duolingo — exibidos no topo da sessão de prática
struct HeartsView: View {
    let lives: Int
    let maxLives: Int
    @State private var shakingIndex: Int? = nil

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxLives, id: \.self) { i in
                Image(systemName: i < lives ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(i < lives ? Color.red : Color.gray.opacity(0.3))
                    .scaleEffect(shakingIndex == i ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: shakingIndex)
            }
        }
        .onChange(of: lives) { old, new in
            if new < old {
                // Anima o coração que foi perdido
                let lost = new
                shakingIndex = lost
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shakingIndex = nil
                }
            }
        }
    }
}

/// Overlay quando o usuário fica sem vidas
struct NoLivesOverlay: View {
    let onWatchAd: () -> Void   // mock
    let onRefill: () -> Void    // custa moedas
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("💔")
                    .font(.system(size: 64))

                VStack(spacing: 8) {
                    Text("Sem vidas!")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(.primary)

                    Text("Suas vidas acabaram.\nRecarregue para continuar praticando.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    // Opção 1: Usar moedas
                    Button {
                        Haptics.medium()
                        onRefill()
                    } label: {
                        HStack(spacing: 8) {
                            Text("🪙")
                            Text("Recarregar por 50 moedas")
                                .font(.system(size: 16, weight: .heavy))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [AppColors.brandOrange, AppColors.brandPurple],
                                           startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    // Opção 2: Assistir anúncio (mock)
                    Button {
                        Haptics.light()
                        onWatchAd()
                    } label: {
                        Text("Ver anúncio para ganhar vida")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)

                    Button("Sair da sessão") {
                        onDismiss()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                }
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 28).fill(Color(.systemBackground)))
            .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 28)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.68)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
