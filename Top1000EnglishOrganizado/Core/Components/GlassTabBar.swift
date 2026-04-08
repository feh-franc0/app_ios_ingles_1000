import SwiftUI
import UIKit

enum AppTab: String, CaseIterable, Identifiable {
    case home, path, profile
    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:    return "Início"
        case .path:    return "Trilha"
        case .profile: return "Perfil"
        }
    }

    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .path:    return "map.fill"
        case .profile: return "person.fill"
        }
    }

    var activeGradient: [Color] {
        switch self {
        case .home:    return [AppColors.brandGreen, AppColors.brandBlue]
        case .path:    return [AppColors.brandBlue, AppColors.brandPurple]
        case .profile: return [AppColors.brandPurple, AppColors.brandOrange]
        }
    }
}

struct GlassTabBar: View {
    @Binding var selected: AppTab

    private var safeBottom: CGFloat { UIApplication.safeAreaBottom }
    private let barHeight: CGFloat = 68

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: barHeight)
        .background(barBackground)
        .padding(.horizontal, 20)
        .padding(.bottom, max(10, safeBottom == 0 ? 14 : safeBottom - 4))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selected == tab

        return Button {
            Haptics.light()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Background pill ativo
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: tab.activeGradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 34)
                            .shadow(
                                color: (tab.activeGradient.first ?? AppColors.brandGreen).opacity(0.42),
                                radius: 10, x: 0, y: 4
                            )
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 17 : 20, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : Color.primary.opacity(0.40))
                        .scaleEffect(isSelected ? 1.0 : 0.95)
                        .frame(width: 52, height: 34)
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(
                        isSelected
                        ? (tab.activeGradient.first ?? AppColors.brandGreen)
                        : Color.primary.opacity(0.38)
                    )
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: isSelected)
    }

    private var barBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 12)
    }
}

// MARK: - SafeArea helper
extension UIApplication {
    static var safeAreaBottom: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let window = windowScene?.windows.first(where: { $0.isKeyWindow })
        return window?.safeAreaInsets.bottom ?? 0
    }
}
