import SwiftUI

/// Popup flutuante de "+XP" estilo Duolingo — aparece acima do card de pergunta ao acertar
struct XPPopupView: View {
    let amount: Int

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.7

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.yellow)

            Text("+\(amount) XP")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [AppColors.brandGreen, AppColors.brandBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: AppColors.brandGreen.opacity(0.45), radius: 10, x: 0, y: 4)
        )
        .scaleEffect(scale)
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            // Entrada rápida
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                scale = 1.0
                opacity = 1.0
                offsetY = -8
            }

            // Sobe e some
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.55)) {
                    offsetY = -55
                    opacity = 0
                }
            }
        }
    }
}

/// Modificador que gerencia o ciclo de vida do popup
struct XPPopupModifier: ViewModifier {
    @Binding var trigger: Int      // incrementa para disparar novo popup
    let amount: Int

    @State private var showPopup: Bool = false
    @State private var popupKey: Int = 0

    func body(content: Content) -> some View {
        ZStack {
            content

            if showPopup {
                XPPopupView(amount: amount)
                    .id(popupKey)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: trigger) { _, _ in
            popupKey += 1
            showPopup = true
            // Remove depois da animação
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                showPopup = false
            }
        }
    }
}

extension View {
    /// Adiciona popup flutuante de XP. Incremente `trigger` para disparar.
    func xpPopup(trigger: Binding<Int>, amount: Int = 10) -> some View {
        modifier(XPPopupModifier(trigger: trigger, amount: amount))
    }
}
