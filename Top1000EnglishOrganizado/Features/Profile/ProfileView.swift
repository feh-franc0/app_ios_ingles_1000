import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var app: AppStore

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    GlassCard {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.brandPurple, AppColors.brandBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 62, height: 62)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.user.name)
                                    .font(.system(size: 20, weight: .bold))
                                Text("Nível \(app.user.level) • \(app.user.xpTotal) XP")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Badges")
                                .font(.system(size: 16, weight: .bold))

                            HStack(spacing: 10) {
                                Badge(icon: "cup.and.saucer.fill", title: "Café")
                                Badge(icon: "airplane.departure", title: "Aeroporto")
                                Badge(icon: "briefcase.fill", title: "Trabalho")
                            }
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Assinatura")
                                .font(.system(size: 16, weight: .bold))
                            Text("Bloqueie distrações, libere speaking ilimitado e cenários avançados.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)

                            Button {
                                Haptics.light()
                            } label: {
                                Text("Ver Premium")
                                    .font(.system(size: 15, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.brandOrange, AppColors.brandPurple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 18)
                                    )
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }
}
