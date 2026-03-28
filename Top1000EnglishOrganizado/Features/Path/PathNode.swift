import SwiftUI

struct PathNode: View {
    let index: Int
    let isLocked: Bool
    let onTap: () -> Void

    @State private var hover = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                if index % 2 == 0 { Spacer() }

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                isLocked
                                ? AnyShapeStyle(Color.gray.opacity(0.18))
                                : AnyShapeStyle(
                                    LinearGradient(
                                        colors: [AppColors.brandGreen, AppColors.brandBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                            .shadow(
                                color: isLocked ? .clear : AppColors.brandGreen.opacity(0.30),
                                radius: hover ? 22 : 12,
                                x: 0,
                                y: 12
                            )
                            .scaleEffect(hover ? 1.03 : 1.0)
                            .animation(.spring(response: 0.35, dampingFraction: 0.70), value: hover)

                        Image(systemName: isLocked ? "lock.fill" : "star.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isLocked ? .secondary : .white)
                    }

                    Text(isLocked ? "Bloqueado" : "Lição \(index)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                if index % 2 != 0 { Spacer() }
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            hover = pressing
        }, perform: {})
    }
}
