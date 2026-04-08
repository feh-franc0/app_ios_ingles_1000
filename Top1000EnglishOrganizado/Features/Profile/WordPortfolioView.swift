import SwiftUI

// ─────────────────────────────────────────────────────────────────────
// MARK: - WordPortfolioView
// Portfólio visual de todas as palavras aprendidas com nível de mastery.
// ─────────────────────────────────────────────────────────────────────

struct WordPortfolioView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var filterLevel: MasteryLevel? = nil
    @State private var searchText = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header de estatísticas
                    portfolioHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    // Filtro por nível
                    levelFilter
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // Grid de palavras
                    if filteredMasteries.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(filteredMasteries) { mastery in
                                    MasteryWordCard(mastery: mastery)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationTitle("Meu Vocabulário")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .searchable(text: $searchText, prompt: "Buscar palavra...")
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Header
    // ─────────────────────────────────────────────────────────────────

    private var portfolioHeader: some View {
        HStack(spacing: 10) {
            ForEach(MasteryLevel.allCases, id: \.rawValue) { lvl in
                let count = app.user.wordMasteries.values.filter { $0.level == lvl }.count
                VStack(spacing: 4) {
                    Text(lvl.emoji)
                        .font(.system(size: 18))
                    Text("\(count)")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(.primary)
                    Text(lvl.label)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(lvl.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(lvl.color.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Level Filter
    // ─────────────────────────────────────────────────────────────────

    private var levelFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(label: "Todos", isActive: filterLevel == nil) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        filterLevel = nil
                    }
                }
                ForEach(MasteryLevel.allCases, id: \.rawValue) { lvl in
                    FilterPill(label: "\(lvl.emoji) \(lvl.label)",
                               isActive: filterLevel == lvl,
                               color: lvl.color) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            filterLevel = lvl
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Empty State
    // ─────────────────────────────────────────────────────────────────

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("📚")
                .font(.system(size: 64))
            Text("Comece a praticar!")
                .font(.system(size: 20, weight: .heavy))
            Text("Suas palavras aparecerão aqui conforme você pratica.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: - Filtered Data
    // ─────────────────────────────────────────────────────────────────

    private var filteredMasteries: [WordMastery] {
        var results = Array(app.user.wordMasteries.values)

        if let level = filterLevel {
            results = results.filter { $0.level == level }
        }

        if !searchText.isEmpty {
            results = results.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
        }

        return results.sorted { $0.level.rawValue > $1.level.rawValue }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - MasteryWordCard
// ─────────────────────────────────────────────────────────────────────

private struct MasteryWordCard: View {
    let mastery: WordMastery

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Nível badge
                Text(mastery.level.emoji)
                    .font(.system(size: 16))
                    .padding(6)
                    .background(mastery.level.color.opacity(0.15), in: Circle())

                Spacer()

                // Accuracy
                Text("\(Int(mastery.accuracy * 100))%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(mastery.level.color)
            }

            Text(mastery.id)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.primary)
                .lineLimit(2)

            // Barra de mastery (progresso dentro do nível)
            VStack(spacing: 4) {
                HStack(spacing: 3) {
                    ForEach(0..<WordMastery.correctsToLevelUp, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < mastery.correctStreak
                                  ? mastery.level.color
                                  : mastery.level.color.opacity(0.15))
                            .frame(height: 4)
                    }
                }
                Text(mastery.level.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(mastery.level.color.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: - FilterPill
// ─────────────────────────────────────────────────────────────────────

private struct FilterPill: View {
    let label: String
    let isActive: Bool
    var color: Color = AppColors.brandBlue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isActive ? .heavy : .semibold))
                .foregroundStyle(isActive ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isActive {
                        Capsule().fill(color)
                    } else {
                        Capsule().fill(Color(.systemFill))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
