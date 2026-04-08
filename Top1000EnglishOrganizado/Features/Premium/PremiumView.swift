import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var premium: MockPremiumService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PremiumPlan = .yearly
    @State private var isPurchasing = false
    @State private var showSuccess = false

    private let features: [(String, String)] = [
        ("infinity", "Sessões ilimitadas por dia"),
        ("waveform.badge.mic", "Prática de pronúncia com voz"),
        ("sparkles.rectangle.stack.fill", "Todos os cenários desbloqueados"),
        ("chart.line.uptrend.xyaxis", "Estatísticas avançadas de progresso"),
        ("bell.badge.fill", "Lembretes personalizados"),
        ("icloud.fill", "Backup na nuvem (em breve)"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1a0533"), Color(hex: "0d1b4b")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        // Header
                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: [AppColors.brandOrange, AppColors.brandPurple],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: AppColors.brandOrange.opacity(0.4), radius: 20, x: 0, y: 10)

                                Text("⭐️")
                                    .font(.system(size: 38))
                            }

                            Text("Top1000 Premium")
                                .font(.system(size: 30, weight: .heavy))
                                .foregroundStyle(.white)

                            Text("Desbloqueie tudo e aprenda\nem alta velocidade")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.70))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)

                        // Features
                        VStack(spacing: 0) {
                            ForEach(features, id: \.0) { icon, text in
                                HStack(spacing: 14) {
                                    Image(systemName: icon)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(AppColors.brandOrange)
                                        .frame(width: 28)

                                    Text(text)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(AppColors.brandGreen)
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 18)

                                if text != features.last?.1 {
                                    Divider().background(Color.white.opacity(0.08))
                                        .padding(.horizontal, 18)
                                }
                            }
                        }
                        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // Planos
                        VStack(spacing: 12) {
                            ForEach(PremiumPlan.allCases, id: \.self) { plan in
                                Button {
                                    Haptics.light()
                                    selectedPlan = plan
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Text(plan.rawValue)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundStyle(.white)

                                                if let savings = plan.savings {
                                                    Text(savings)
                                                        .font(.system(size: 11, weight: .heavy))
                                                        .foregroundStyle(AppColors.heroNavy)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 3)
                                                        .background(AppColors.brandOrange, in: Capsule())
                                                }
                                            }
                                            Text(plan.price)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(Color.white.opacity(0.65))
                                        }

                                        Spacer()

                                        ZStack {
                                            Circle()
                                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                                .frame(width: 24, height: 24)

                                            if selectedPlan == plan {
                                                Circle()
                                                    .fill(AppColors.brandOrange)
                                                    .frame(width: 14, height: 14)
                                            }
                                        }
                                    }
                                    .padding(18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedPlan == plan
                                                  ? Color.white.opacity(0.14)
                                                  : Color.white.opacity(0.06))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedPlan == plan
                                                    ? AppColors.brandOrange.opacity(0.6)
                                                    : Color.white.opacity(0.10), lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        // CTA
                        VStack(spacing: 12) {
                            Button {
                                Task { await purchase() }
                            } label: {
                                HStack(spacing: 10) {
                                    if isPurchasing {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Assinar \(selectedPlan.rawValue)")
                                            .font(.system(size: 18, weight: .heavy))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.brandOrange, AppColors.brandPurple],
                                        startPoint: .leading, endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 22)
                                )
                                .foregroundStyle(.white)
                                .shadow(color: AppColors.brandOrange.opacity(0.35), radius: 18, x: 0, y: 10)
                            }
                            .buttonStyle(.plain)
                            .disabled(isPurchasing)

                            Button("Restaurar compras") {
                                Task { await premium.restorePurchases() }
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.5))

                            Text("Renovação automática. Cancele quando quiser.")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.white.opacity(0.35))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.6))
                            .padding(8)
                            .background(Color.white.opacity(0.12), in: Circle())
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay {
                if showSuccess { successOverlay }
            }
        }
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("🎉").font(.system(size: 64))
                Text("Premium ativado!")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(.white)
                Text("Bem-vindo ao Top1000 Premium.\nAproveite tudo sem limites!")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                Button("Começar") {
                    Haptics.success()
                    dismiss()
                }
                .font(.system(size: 17, weight: .heavy))
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(Color(hex: "1a0533"))
            }
            .padding(32)
        }
    }

    private func purchase() async {
        isPurchasing = true
        let result = await premium.purchase(plan: selectedPlan)
        isPurchasing = false
        if case .success = result {
            Haptics.success()
            showSuccess = true
        }
    }
}

// MARK: - Hex Color helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
