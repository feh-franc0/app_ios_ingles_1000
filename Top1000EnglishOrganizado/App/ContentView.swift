import SwiftUI

struct ContentView: View {
    @StateObject private var app = AppStore()
    @State private var tab: AppTab = .home

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $tab) {
                HomeView()
                    .environmentObject(app)
                    .tag(AppTab.home)

                PathView()
                    .environmentObject(app)
                    .tag(AppTab.path)

                ReviewView()
                    .environmentObject(app)
                    .tag(AppTab.review)

                ProfileView()
                    .environmentObject(app)
                    .tag(AppTab.profile)
            }
            // ✅ fixa 100% no rodapé
            .overlay(alignment: .bottom) {
                GlassTabBar(selected: $tab)
            }
        }
    }
}

#Preview {
    ContentView()
}

enum Tab: String, CaseIterable {
    case home, path, review, profile

    var title: String {
        switch self {
        case .home: return "Início"
        case .path: return "Trilha"
        case .review: return "Revisão"
        case .profile: return "Perfil"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .path: return "map.fill"
        case .review: return "arrow.triangle.2.circlepath"
        case .profile: return "person.fill"
        }
    }
}
