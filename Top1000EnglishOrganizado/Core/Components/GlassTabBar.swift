import SwiftUI
import UIKit

enum AppTab: String, CaseIterable, Identifiable {
    case home, path, profile
    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Início"
        case .path: return "Trilha"
        case .profile: return "Perfil"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .path: return "map.fill"
        case .profile: return "person.fill"
        }
    }
}   

struct GlassTabBar: View {
    @Binding var selected: AppTab

    private var safeBottom: CGFloat { UIApplication.safeAreaBottom }
    private let barHeight: CGFloat = 66
    private let sidePadding: CGFloat = 18

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: barHeight)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.20), radius: 22, x: 0, y: 16)
        )
        .padding(.horizontal, sidePadding)
        // ✅ cola no fundo com o safeArea correto
        .padding(.bottom, max(12, safeBottom == 0 ? 16 : safeBottom - 6))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            Haptics.light()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))

                Text(tab.title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(selected == tab ? AppColors.brandGreen : Color.black.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if selected == tab {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.22))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
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
