import SwiftUI

struct ModePill: View {
    let mode: PracticeMode
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mode.icon)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 16)

            Text(mode.rawValue)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)                     // 🔥 nunca quebra linha
                .minimumScaleFactor(0.75)         // 🔥 reduz fonte se apertar
                .allowsTightening(true)           // 🔥 compacta caracteres
                .truncationMode(.tail)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)              // 🔥 divide espaço igualmente ...
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
                    : AnyShapeStyle(AppColors.card.opacity(0.70))
                )
        }
        .foregroundStyle(isSelected ? .white : .primary)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected
                    ? Color.white.opacity(0.18)
                    : Color.white.opacity(0.10),
                    lineWidth: 1
                )
        )
        .shadow(
            color: isSelected
            ? mode.gradient.first!.opacity(0.28)
            : .clear,
            radius: 14,
            x: 0,
            y: 10
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
    }
}
