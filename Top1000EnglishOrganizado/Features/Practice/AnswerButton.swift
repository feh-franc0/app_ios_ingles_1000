import SwiftUI

enum AnswerVisualState { case neutral, selected, correct, wrong }

struct AnswerButton: View {
    let text: String
    let state: AnswerVisualState
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            .padding(14)
            .background(bg, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var bg: Color {
        switch state {
        case .neutral: return Color(.secondarySystemBackground).opacity(0.55)
        case .selected: return AppColors.brandBlue.opacity(0.18)
        case .correct: return AppColors.brandGreen.opacity(0.18)
        case .wrong: return AppColors.brandRed.opacity(0.18)
        }
    }

    private var border: Color {
        switch state {
        case .neutral: return Color.primary.opacity(0.08)
        case .selected: return AppColors.brandBlue.opacity(0.35)
        case .correct: return AppColors.brandGreen.opacity(0.35)
        case .wrong: return AppColors.brandRed.opacity(0.35)
        }
    }

    private var icon: String {
        switch state {
        case .neutral: return "circle"
        case .selected: return "circle.inset.filled"
        case .correct: return "checkmark.circle.fill"
        case .wrong: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch state {
        case .neutral: return .secondary
        case .selected: return AppColors.brandBlue
        case .correct: return AppColors.brandGreen
        case .wrong: return AppColors.brandRed
        }
    }
}
