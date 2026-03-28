import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var app: AppStore

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    SectionTitle("Revisão", subtitle: "O que você erra mais aparece aqui")
                        .padding(.top, 12)

                    if app.reviewPool.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sem itens para revisar 🙌")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Quando você errar uma palavra/frase, ela entra aqui automaticamente.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            ForEach(app.reviewPool) { item in
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.prompt)
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Correto: \(item.correct)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(AppColors.brandGreen)
                                        Text(item.hint)
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Revisão")
        .navigationBarTitleDisplayMode(.inline)
    }
}
