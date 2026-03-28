import SwiftUI

struct StrongBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {

            // 🔥 Fundo azul escuro total
            LinearGradient(
                colors: [
                    AppColors.heroNavy,
                    AppColors.heroNavy2
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 🔥 Glow superior sutil
            RadialGradient(
                colors: [
                    AppColors.brandPurple.opacity(animate ? 0.35 : 0.20),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 600
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true),
                       value: animate)

            // 🔥 Glow inferior sutil
            RadialGradient(
                colors: [
                    AppColors.brandBlue.opacity(animate ? 0.25 : 0.12),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 50,
                endRadius: 700
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                       value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}
