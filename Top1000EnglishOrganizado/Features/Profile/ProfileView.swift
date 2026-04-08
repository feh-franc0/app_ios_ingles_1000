import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var app: AppStore
    @EnvironmentObject private var premium: MockPremiumService
    @State private var showSettings = false
    @State private var showPremium = false

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    // Header do perfil
                    GlassCard {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [AppColors.brandPurple, AppColors.brandBlue],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 64, height: 64)
                                Text(String(app.user.name.prefix(1)).uppercased())
                                    .font(.system(size: 26, weight: .heavy))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.user.name)
                                    .font(.system(size: 20, weight: .bold))
                                Text("Nível \(app.user.level) • \(app.user.xpTotal) XP")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                Haptics.light()
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.secondary)
                                    .padding(10)
                                    .background(Color.black.opacity(0.06), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Stats rápidos
                    HStack(spacing: 10) {
                        statCard(title: "Streak", value: "\(app.user.streak)🔥")
                        statCard(title: "Moedas", value: "\(app.user.coins)🪙")
                        statCard(title: "Sessões", value: "\(max(1, app.user.xpTotal / 100))")
                    }

                    // Badges dinâmicos
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Conquistas")
                                    .font(.system(size: 18, weight: .heavy))
                                Spacer()
                                Text("\(app.user.unlockedBadgeIDs.count)/\(BadgeDefinition.all.count)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.secondary)
                            }

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                                ForEach(BadgeDefinition.all) { badge in
                                    let unlocked = app.user.unlockedBadgeIDs.contains(badge.id)
                                    BadgeTile(badge: badge, unlocked: unlocked)
                                }
                            }
                        }
                    }

                    // Premium card
                    if !premium.isPremium {
                        Button {
                            Haptics.medium()
                            showPremium = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [AppColors.brandOrange, AppColors.brandPurple],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 46, height: 46)
                                    Text("⭐️").font(.system(size: 22))
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Assinar Premium")
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundStyle(.primary)
                                    Text("Sessões ilimitadas, pronúncia e muito mais")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.92)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(
                                        colors: [AppColors.brandOrange.opacity(0.5), AppColors.brandPurple.opacity(0.5)],
                                        startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 8)
                        }
                        .buttonStyle(.plain)
                    } else {
                        GlassCard {
                            HStack(spacing: 12) {
                                Text("⭐️").font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Premium Ativo")
                                        .font(.system(size: 16, weight: .heavy))
                                    Text("Obrigado por apoiar o app!")
                                        .font(.system(size: 13)).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(app)
        }
        .sheet(isPresented: $showPremium) {
            PremiumView().environmentObject(premium)
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value).font(.system(size: 20, weight: .heavy))
            Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.90)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Badge Tile

private struct BadgeTile: View {
    let badge: BadgeDefinition
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(unlocked ? badge.color.opacity(0.15) : Color.black.opacity(0.05))
                    .frame(width: 52, height: 52)
                Image(systemName: badge.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(unlocked ? badge.color : Color.gray.opacity(0.25))
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.gray.opacity(0.45))
                        .offset(x: 16, y: 16)
                }
            }
            Text(badge.title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(unlocked ? .primary : Color.gray.opacity(0.45))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Badge Definitions

struct BadgeDefinition: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color

    static let all: [BadgeDefinition] = [
        .init(id: "streak_3",        title: "3 dias",     icon: "flame.fill",                   color: AppColors.brandOrange),
        .init(id: "streak_7",        title: "7 dias",     icon: "flame.fill",                   color: .red),
        .init(id: "streak_30",       title: "30 dias",    icon: "crown.fill",                   color: .yellow),
        .init(id: "level_5",         title: "Nível 5",    icon: "star.fill",                    color: AppColors.brandBlue),
        .init(id: "level_10",        title: "Nível 10",   icon: "star.circle.fill",             color: AppColors.brandPurple),
        .init(id: "level_20",        title: "Nível 20",   icon: "trophy.fill",                  color: .yellow),
        .init(id: "xp_1000",         title: "1K XP",      icon: "bolt.fill",                    color: AppColors.brandGreen),
        .init(id: "xp_5000",         title: "5K XP",      icon: "bolt.circle.fill",             color: AppColors.brandGreen),
        .init(id: "xp_10000",        title: "10K XP",     icon: "sparkles",                     color: .yellow),
        .init(id: "mission_complete",title: "Missão!",    icon: "checkmark.seal.fill",          color: AppColors.brandGreen),
        .init(id: "review_10",       title: "Revisor",    icon: "arrow.triangle.2.circlepath",  color: AppColors.brandPurple),
        .init(id: "perfect",         title: "Perfeito",   icon: "rosette",                      color: .yellow),
    ]
}
