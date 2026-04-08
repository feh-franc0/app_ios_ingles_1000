import SwiftUI

struct ContentView: View {
    @StateObject private var app = AppStore()
    @StateObject private var premium = MockPremiumService()
    @State private var tab: AppTab = .home

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        Group {
            if !app.user.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(app)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                mainApp
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: app.user.hasCompletedOnboarding)
    }

    private var mainApp: some View {
        NavigationStack {
            TabView(selection: $tab) {
                HomeView()
                    .environmentObject(app)
                    .environmentObject(premium)
                    .tag(AppTab.home)

                PathView()
                    .environmentObject(app)
                    .tag(AppTab.path)

                ProfileView()
                    .environmentObject(app)
                    .environmentObject(premium)
                    .tag(AppTab.profile)
            }
            .overlay(alignment: .bottom) {
                GlassTabBar(selected: $tab)
            }
        }
    }
}

#Preview {
    ContentView()
}
