import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    let mode: PracticeMode
    let correctCount: Int
    let total: Int
    let xpGained: Int
    let wrongItems: [ReviewItem]
    let onFinish: () -> Void

    private var correctRate: Double {
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total)
    }

    private var accuracy: Int {
        Int((correctRate * 100.0).rounded())
    }

    private var coinsPreview: Int {
        let baseCoins = max(1, Int(Double(xpGained) * 0.20))
        var bonus = 0
        if correctRate >= 0.80 { bonus += 10 }
        if correctRate >= 1.00 { bonus += 20 }
        return baseCoins + bonus
    }

    var body: some View {
        NavigationStack {
            ZStack {
                resultBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerCard
                        statsCard

                        if !wrongItems.isEmpty {
                            reviewSection
                        }

                        actionCard

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Background

    private var resultBackground: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.brandBlue, AppColors.brandPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 74, height: 74)
                    .shadow(color: AppColors.brandPurple.opacity(0.22), radius: 16, x: 0, y: 10)

                Image(systemName: accuracy >= 80 ? "checkmark.seal.fill" : "star.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("Desafio concluído")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.primary)

                Text(subtitleText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }

    // MARK: - Stats

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resultado")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                metricCard(
                    title: "Precisão",
                    value: "\(accuracy)%",
                    tint: AppColors.brandBlue
                )

                metricCard(
                    title: "XP",
                    value: "+\(xpGained)",
                    tint: AppColors.brandGreen
                )

                metricCard(
                    title: "Moedas",
                    value: "+\(coinsPreview)",
                    tint: AppColors.brandOrange
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }

    private func metricCard(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(tint.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tint.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Review

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Entrou para revisão")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.primary)

            Text("Você vai rever esses pontos para fixar melhor.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(wrongItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.prompt)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("Correto: \(item.correct)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.brandGreen)

                        Text(item.hint)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.92))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }

    // MARK: - Action

    private var actionCard: some View {
        VStack(spacing: 14) {
            Button {
                Haptics.success()
                dismiss()
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
                        colors: [AppColors.brandGreen, AppColors.brandBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
                .foregroundStyle(.white)
                .shadow(color: AppColors.brandBlue.opacity(0.22), radius: 16, x: 0, y: 10)
            }
            .buttonStyle(.plain)

            Text("Seu progresso foi salvo com sucesso.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }

    // MARK: - Copy

    private var subtitleText: String {
        if accuracy == 100 {
            return "Perfeito. Você acertou tudo e fechou essa rodada com excelência."
        } else if accuracy >= 80 {
            return "Ótimo resultado. Você está evoluindo muito bem."
        } else if accuracy >= 60 {
            return "Bom progresso. Mais algumas rodadas e isso fixa."
        } else {
            return "Tudo certo. O importante é continuar praticando."
        }
    }
}
