import SwiftUI

// ─────────────────────────────────────────────────────────────────────
// MARK: - TitlePickerView
// Galeria de todos os títulos. Desbloqueados podem ser equipados.
// ─────────────────────────────────────────────────────────────────────

struct TitlePickerView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(BadgeRarity.allCases, id: \.self) { rarity in
                            let titles = AppTitle.all.filter { $0.rarity == rarity }
                            if !titles.isEmpty {
                                raritySection(rarity: rarity, titles: titles)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Títulos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
        }
    }

    private func raritySection(rarity: BadgeRarity, titles: [AppTitle]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(rarity.label.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(rarity.color)
                Rectangle()
                    .fill(rarity.color.opacity(0.25))
                    .frame(height: 1)
            }

            ForEach(titles) { title in
                titleRow(title)
            }
        }
    }

    private func titleRow(_ title: AppTitle) -> some View {
        let unlocked  = app.user.unlockedTitleIDs.contains(title.id)
        let equipped  = app.user.equippedTitleID == title.id

        return Button {
            guard unlocked else { return }
            Haptics.light()
            app.equipTitle(title.id)
        } label: {
            HStack(spacing: 14) {
                // Ícone com gradiente de raridade
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            unlocked
                            ? AnyShapeStyle(LinearGradient(colors: title.rarity.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.black.opacity(0.06))
                        )
                        .frame(width: 46, height: 46)
                    Text(title.emoji)
                        .font(.system(size: 22))
                        .grayscale(unlocked ? 0 : 1)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title.name)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(unlocked ? .primary : .secondary)

                        if equipped {
                            Text("Equipado")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(AppColors.brandGreen, in: Capsule())
                        }
                    }
                    Text(title.requirement)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.secondary.opacity(0.40))
                } else if equipped {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppColors.brandGreen)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.secondary.opacity(0.30))
                }
            }
            .padding(14)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        equipped
                        ? AnyShapeStyle(LinearGradient(colors: title.rarity.gradient, startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color.black.opacity(0.04)),
                        lineWidth: equipped ? 1.5 : 1
                    )
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
            .opacity(unlocked ? 1.0 : 0.60)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: equipped)
    }
}
