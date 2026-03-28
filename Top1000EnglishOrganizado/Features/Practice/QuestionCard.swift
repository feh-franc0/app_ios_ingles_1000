import SwiftUI

struct QuestionCard: View {
    let title: String
    let prompt: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)

                Text(prompt)
                    .font(.system(size: 20, weight: .bold))
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, 16)
    }
}
