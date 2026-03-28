import SwiftUI

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
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
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
