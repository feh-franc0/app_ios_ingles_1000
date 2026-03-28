import SwiftUI

struct StreakRowView: View {
    let title: String
    let streak: Int
    let activeCount: Int

    private let days = ["S", "T", "Q", "Q", "S", "S", "D"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AppColors.brandOrange)

                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black.opacity(0.9))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.brandOrange.opacity(0.8))
            }

            // Days
            HStack(spacing: 14) {
                ForEach(days.indices, id: \.self) { i in
                    let isOn = i < activeCount

                    ZStack {
                        Circle()
                            .fill(isOn ? AppColors.gold : Color.black.opacity(0.06))
                            .frame(width: 36, height: 36)
                            .shadow(
                                color: isOn
                                    ? AppColors.gold.opacity(0.45)
                                    : .clear,
                                radius: isOn ? 14 : 0,
                                x: 0,
                                y: 8
                            )

                        Text(days[i])
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(isOn ? .white : .secondary)
                    }
                }
            }

            Text("Sequência atual: \(streak) dias")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black.opacity(0.55))
        }
        .padding(18)
        .background(cardBackground)
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.10), radius: 22, x: 0, y: 14)
    }

    // MARK: - Background correto (100% mock vibe)

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.95),
                        Color.white.opacity(0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Glow quente no canto esquerdo
                RadialGradient(
                    colors: [
                        AppColors.gold.opacity(0.35),
                        AppColors.brandOrange.opacity(0.18),
                        .clear
                    ],
                    center: .leading,
                    startRadius: 20,
                    endRadius: 260
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .stroke(Color.white.opacity(0.35), lineWidth: 1)
    }
}
