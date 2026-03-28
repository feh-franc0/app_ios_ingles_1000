import SwiftUI

struct FeedbackBanner: View {
    let isCorrect: Bool
    let explanation: String

    var body: some View {
        GlassCard {
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isCorrect ? AppColors.brandGreen : AppColors.brandRed)

                VStack(alignment: .leading, spacing: 2) {
                    Text(isCorrect ? "Boa! +10 XP" : "Quase! Vai pra revisão.")
                        .font(.system(size: 14, weight: .bold))

                    Text(explanation)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }
}
