import SwiftUI

struct RewardCardView: View {
    let title: String
    let subtitle: String
    let progress: Double // 0...1

    var body: some View {
        HStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.88))

                ThinProgressBar(
                    value: progress,
                    height: 6,
                    trackOpacity: 0.10,
                    fill: AppColors.gold
                )

                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.55))
            }

            Spacer()

            Image("gift_3d")
                .resizable()
                .scaledToFit()
                .frame(width: 78, height: 78)
                .shadow(color: AppColors.gold.opacity(0.25), radius: 16, x: 0, y: 10)
        }
        .padding(16)
        .background(rewardBackground)
        .overlay(rewardBorder)
        .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 12)
    }

    private var rewardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.96))
            .overlay(
                // glow forte no canto do presente (mock)
                RadialGradient(
                    colors: [
                        AppColors.gold.opacity(0.22),
                        AppColors.brandOrange.opacity(0.10),
                        .clear
                    ],
                    center: .trailing,
                    startRadius: 20,
                    endRadius: 220
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            )
    }

    private var rewardBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }
}
