import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var app: AppStore
    @EnvironmentObject private var premium: MockPremiumService
    @State private var showSettings    = false
    @State private var showPremium     = false
    @State private var showPortfolio   = false
    @State private var showTitlePicker = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileHero

                    VStack(spacing: 16) {
                        statsRow
                        titlesCard        // ← Títulos de prestígio
                        portfolioCard     // ← Portfólio de vocabulário
                        if !premium.isPremium { premiumCard }
                        badgesCard
                        leagueCard
                        if premium.isPremium { premiumActiveCard }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 110)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(app)
        }
        .sheet(isPresented: $showPremium) {
            PremiumView().environmentObject(premium)
        }
        .sheet(isPresented: $showPortfolio) {
            WordPortfolioView().environmentObject(app)
        }
        .sheet(isPresented: $showTitlePicker) {
            TitlePickerView().environmentObject(app)
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Hero
    // ────────────────────────────────────────────────────────────────

    private var profileHero: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: [AppColors.heroNavy, AppColors.heroSlate, Color(red: 0.18, green: 0.08, blue: 0.35)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Brilho roxo
            RadialGradient(
                colors: [AppColors.brandPurple.opacity(0.30), .clear],
                center: .bottomLeading, startRadius: 10, endRadius: 260
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 20) {
                // Top bar: configurações
                HStack {
                    Spacer()
                    Button {
                        Haptics.light()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.75))
                            .padding(10)
                            .background(Color.white.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                // Avatar + nome
                VStack(spacing: 12) {
                    // Avatar com ring de XP
                    ZStack {
                        // Ring externo
                        Circle()
                            .stroke(Color.white.opacity(0.10), lineWidth: 5)
                            .frame(width: 96, height: 96)
                        Circle()
                            .trim(from: 0, to: max(0.02, levelProgress))
                            .stroke(
                                AngularGradient(
                                    colors: [AppColors.brandPurple, AppColors.brandBlue, AppColors.brandGreen],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .frame(width: 96, height: 96)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: AppColors.brandPurple.opacity(0.40), radius: 10, x: 0, y: 0)

                        // Avatar inner
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.brandPurple, AppColors.brandBlue],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                            )

                        Text(String(app.user.name.prefix(1)).uppercased())
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundStyle(.white)
                    }

                    // Nome + nível
                    VStack(spacing: 5) {
                        Text(app.user.name.isEmpty ? "Estudante" : app.user.name)
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(.white)

                        HStack(spacing: 8) {
                            Text("Nível \(app.user.level)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.14), in: Capsule())

                            Text("\(app.user.xpTotal) XP")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.65))
                        }
                    }
                }
                .padding(.bottom, 28)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .shadow(color: .black.opacity(0.32), radius: 28, x: 0, y: 14)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Stats Row
    // ────────────────────────────────────────────────────────────────

    private var statsRow: some View {
        HStack(spacing: 10) {
            statPill(emoji: "🔥", value: "\(app.user.streak)", label: "Streak",
                     gradient: [AppColors.brandOrange, .red])
            statPill(emoji: "🪙", value: "\(app.user.coins)", label: "Moedas",
                     gradient: [AppColors.gold, AppColors.brandOrange])
            statPill(emoji: "⚡️", value: "\(max(1, app.user.xpTotal / 100))", label: "Sessões",
                     gradient: [AppColors.brandBlue, AppColors.brandPurple])
        }
    }

    private func statPill(emoji: String, value: String, label: String, gradient: [Color]) -> some View {
        VStack(spacing: 6) {
            Text(emoji).font(.system(size: 22))
            Text(value)
                .font(.system(size: 20, weight: .heavy))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(colors: gradient.map { $0.opacity(0.30) },
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Títulos de Prestígio
    // ────────────────────────────────────────────────────────────────

    private var titlesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.gold.opacity(0.14))
                            .frame(width: 32, height: 32)
                        Text("👑").font(.system(size: 15))
                    }
                    Text("Títulos")
                        .font(.system(size: 17, weight: .heavy))
                }
                Spacer()
                Button {
                    Haptics.light()
                    showTitlePicker = true
                } label: {
                    Text("Trocar")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.brandBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.brandBlue.opacity(0.10), in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 18)

            // Título equipado
            if let equipped = app.equippedTitle {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient(
                                colors: equipped.rarity.gradient,
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 52, height: 52)
                            .shadow(color: (equipped.rarity.gradient.first ?? .clear).opacity(0.35), radius: 10, x: 0, y: 4)
                        Text(equipped.emoji).font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(equipped.name)
                                .font(.system(size: 16, weight: .heavy))
                            rarityBadge(equipped.rarity)
                        }
                        Text(equipped.requirement)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }

            // Preview dos títulos desbloqueados
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AppTitle.all.filter { app.user.unlockedTitleIDs.contains($0.id) }) { title in
                        Button {
                            app.equipTitle(title.id)
                            Haptics.light()
                        } label: {
                            HStack(spacing: 6) {
                                Text(title.emoji).font(.system(size: 14))
                                Text(title.name)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(app.user.equippedTitleID == title.id ? .white : .primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(
                                    app.user.equippedTitleID == title.id
                                    ? AnyShapeStyle(LinearGradient(colors: title.rarity.gradient, startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color.black.opacity(0.05))
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    private func rarityBadge(_ rarity: BadgeRarity) -> some View {
        Text(rarity.label)
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(LinearGradient(
                    colors: rarity.gradient,
                    startPoint: .leading, endPoint: .trailing
                ))
            )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Portfólio Card
    // ────────────────────────────────────────────────────────────────

    private var portfolioCard: some View {
        Button {
            Haptics.light()
            showPortfolio = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(
                            colors: [AppColors.brandPurple, AppColors.brandBlue],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 52, height: 52)
                        .shadow(color: AppColors.brandPurple.opacity(0.35), radius: 10, x: 0, y: 4)
                    Text("📚").font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Meu Vocabulário")
                        .font(.system(size: 16, weight: .heavy))
                    HStack(spacing: 6) {
                        Text("\(app.user.totalWordsLearned) aprendidas")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("\(app.user.totalWordsMastered) ⭐️ dominadas")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.brandGreen)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.secondary.opacity(0.45))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(AppColors.brandPurple.opacity(0.18), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Badges
    // ────────────────────────────────────────────────────────────────

    private var badgesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.gold.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text("🏆").font(.system(size: 15))
                    }
                    Text("Conquistas")
                        .font(.system(size: 17, weight: .heavy))
                }
                Spacer()
                Text("\(app.user.unlockedBadgeIDs.count)/\(BadgeDefinition.all.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.05), in: Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 18)

            // Por raridade
            ForEach(BadgeRarity.allCases, id: \.self) { rarity in
                let badges = BadgeDefinition.all.filter { $0.rarity == rarity }
                let unlockedCount = badges.filter { app.user.unlockedBadgeIDs.contains($0.id) }.count

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Text(rarity.label.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(rarity.color)
                        Spacer()
                        Text("\(unlockedCount)/\(badges.count)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                        spacing: 14
                    ) {
                        ForEach(badges) { badge in
                            let unlocked = app.user.unlockedBadgeIDs.contains(badge.id)
                            BadgeTile(badge: badge, unlocked: unlocked)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
            }
            .padding(.bottom, 18)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - League (mock)
    // ────────────────────────────────────────────────────────────────

    private var leagueCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandBlue.opacity(0.12))
                            .frame(width: 32, height: 32)
                        Text("🥇").font(.system(size: 15))
                    }
                    Text("Liga Semanal")
                        .font(.system(size: 17, weight: .heavy))
                }
                Spacer()
                Text("Liga Prata")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.10), in: Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 18)

            VStack(spacing: 0) {
                ForEach(mockLeague.indices, id: \.self) { i in
                    leagueRow(rank: i + 1, data: mockLeague[i], isUser: i == 2)
                    if i < mockLeague.count - 1 {
                        Rectangle()
                            .fill(Color.black.opacity(0.03))
                            .frame(height: 1)
                            .padding(.horizontal, 18)
                    }
                }
            }
            .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    private func leagueRow(rank: Int, data: (String, Int, String), isUser: Bool) -> some View {
        HStack(spacing: 14) {
            // Rank
            ZStack {
                if rank <= 3 {
                    Text(["🥇","🥈","🥉"][rank - 1]).font(.system(size: 20))
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 30)

            // Avatar mock
            ZStack {
                Circle()
                    .fill(isUser
                          ? LinearGradient(colors: [AppColors.brandPurple, AppColors.brandBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 36, height: 36)
                Text(String(data.0.prefix(1)))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isUser ? "\(app.user.name.isEmpty ? "Você" : app.user.name) (você)" : data.0)
                    .font(.system(size: 14, weight: isUser ? .heavy : .semibold))
                    .foregroundStyle(isUser ? .primary : .primary)
                Text(data.2)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("⚡️").font(.system(size: 12))
                Text("\(isUser ? app.user.xpTotal : data.1) XP")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(rank == 1 ? AppColors.gold : .primary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            isUser
            ? RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AppColors.brandPurple.opacity(0.06))
            : nil
        )
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Premium Cards
    // ────────────────────────────────────────────────────────────────

    private var premiumCard: some View {
        Button {
            Haptics.medium()
            showPremium = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [AppColors.brandOrange, AppColors.brandPurple],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                        .shadow(color: AppColors.brandOrange.opacity(0.35), radius: 10, x: 0, y: 4)
                    Text("⭐️").font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade Premium")
                        .font(.system(size: 16, weight: .heavy))
                    Text("Sessões ilimitadas, sem anúncios e muito mais")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Ver")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(LinearGradient(
                                colors: [AppColors.brandOrange, AppColors.brandPurple],
                                startPoint: .leading, endPoint: .trailing
                            ))
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.brandOrange.opacity(0.45), AppColors.brandPurple.opacity(0.45)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: AppColors.brandOrange.opacity(0.14), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var premiumActiveCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [AppColors.gold, AppColors.brandOrange],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .shadow(color: AppColors.gold.opacity(0.40), radius: 10, x: 0, y: 4)
                Text("⭐️").font(.system(size: 24))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Premium Ativo")
                    .font(.system(size: 16, weight: .heavy))
                Text("Obrigado por apoiar o Top1000English!")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.gold.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: AppColors.gold.opacity(0.10), radius: 14, x: 0, y: 5)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: - Helpers
    // ────────────────────────────────────────────────────────────────

    private var levelProgress: Double {
        let mod = Double(app.user.xpTotal % 250)
        return max(0.0, min(1.0, mod / 250.0))
    }

    private let mockLeague: [(String, Int, String)] = [
        ("Ana S.",    4200, "🇧🇷 São Paulo"),
        ("Marcos T.", 3850, "🇧🇷 Rio de Janeiro"),
        ("Você",         0, "🇧🇷 Aprendendo"),
        ("Júlia M.",  2100, "🇧🇷 Curitiba"),
        ("Pedro L.",  1880, "🇧🇷 Belo Horizonte"),
    ]
}

// ────────────────────────────────────────────────────────────────────
// MARK: - BadgeTile
// ────────────────────────────────────────────────────────────────────

private struct BadgeTile: View {
    let badge: BadgeDefinition
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                // Rarity ring
                if unlocked {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: badge.rarity.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: badge.rarity == .legendary ? 2.5 : 1.5
                        )
                        .frame(width: 56, height: 56)
                }

                Circle()
                    .fill(
                        unlocked
                        ? AnyShapeStyle(badge.color.opacity(0.15))
                        : AnyShapeStyle(Color.black.opacity(0.04))
                    )
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: unlocked ? badge.rarity.color.opacity(badge.rarity == .legendary ? 0.50 : 0.20) : .clear,
                        radius: badge.rarity == .legendary ? 12 : 6, x: 0, y: 3
                    )

                Image(systemName: badge.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(unlocked ? badge.color : Color.gray.opacity(0.22))

                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(Color.gray.opacity(0.40))
                        .offset(x: 16, y: 16)
                }

                // Coroa para lendário
                if unlocked && badge.rarity == .legendary {
                    Text("👑")
                        .font(.system(size: 10))
                        .offset(x: 16, y: -18)
                }
            }
            .frame(width: 56, height: 56)

            Text(badge.title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(unlocked ? .primary : Color.secondary.opacity(0.50))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Badge Definitions
// ────────────────────────────────────────────────────────────────────

struct BadgeDefinition: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    var rarity: BadgeRarity = .common

    static let all: [BadgeDefinition] = [
        // Comuns
        .init(id: "streak_3",         title: "3 dias",      icon: "flame.fill",                  color: AppColors.brandOrange, rarity: .common),
        .init(id: "level_5",          title: "Nível 5",     icon: "star.fill",                   color: AppColors.brandBlue,   rarity: .common),
        .init(id: "xp_1000",          title: "1K XP",       icon: "bolt.fill",                   color: AppColors.brandGreen,  rarity: .common),
        .init(id: "mission_complete", title: "Missão!",     icon: "checkmark.seal.fill",         color: AppColors.brandGreen,  rarity: .common),
        // Raros
        .init(id: "streak_7",         title: "7 dias",      icon: "flame.fill",                  color: .red,                  rarity: .rare),
        .init(id: "level_10",         title: "Nível 10",    icon: "star.circle.fill",            color: AppColors.brandPurple, rarity: .rare),
        .init(id: "xp_5000",          title: "5K XP",       icon: "bolt.circle.fill",            color: AppColors.brandGreen,  rarity: .rare),
        .init(id: "review_10",        title: "Revisor",     icon: "arrow.triangle.2.circlepath", color: AppColors.brandPurple, rarity: .rare),
        // Épicos
        .init(id: "streak_30",        title: "30 dias",     icon: "crown.fill",                  color: .orange,               rarity: .epic),
        .init(id: "level_20",         title: "Nível 20",    icon: "trophy.fill",                 color: .orange,               rarity: .epic),
        .init(id: "perfect",          title: "Perfeito",    icon: "rosette",                     color: AppColors.brandPurple, rarity: .epic),
        // Lendário
        .init(id: "xp_10000",         title: "10K XP",      icon: "sparkles",                    color: .yellow,               rarity: .legendary),
    ]
}
