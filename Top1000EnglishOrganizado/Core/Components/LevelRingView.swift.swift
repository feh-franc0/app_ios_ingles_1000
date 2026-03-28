import SwiftUI

struct LevelRingView: View {
    let level: Int
    let progress: Double // 0...1
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 8)

            Circle()
                .trim(from: 0, to: max(0.02, min(1.0, progress)))
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 0.00, green: 0.80, blue: 1.00),
                            Color(red: 0.10, green: 0.60, blue: 1.00),
                            Color(red: 0.00, green: 0.85, blue: 0.70)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AppColors.brandBlue.opacity(0.35), radius: 14, x: 0, y: 10)

            VStack(spacing: 2) {
                Text("Nível \(level)")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.85))
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
    }
}
