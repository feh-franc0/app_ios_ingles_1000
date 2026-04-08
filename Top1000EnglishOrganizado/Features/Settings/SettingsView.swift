import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppStore
    @Environment(\.dismiss) private var dismiss

    private let notifications = MockNotificationService()

    @State private var name: String = ""
    @State private var dailyGoal: Int = 50
    @State private var notifEnabled: Bool = false
    @State private var notifHour: Int = 20
    @State private var saved = false

    private let goals = [20, 50, 100, 150]

    var body: some View {
        NavigationStack {
            ZStack {
                StrongBackground().ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Perfil
                        settingsSection(title: "Perfil") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Seu nome")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                TextField("Nome", text: $name)
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(14)
                                    .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(16)
                        }

                        // Meta diária
                        settingsSection(title: "Meta diária de XP") {
                            VStack(spacing: 10) {
                                ForEach(goals, id: \.self) { goal in
                                    Button {
                                        Haptics.light()
                                        dailyGoal = goal
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("\(goal) XP")
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundStyle(.primary)
                                                Text(goalDescription(goal))
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            if dailyGoal == goal {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(AppColors.brandGreen)
                                            }
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(dailyGoal == goal ? AppColors.brandGreen.opacity(0.08) : Color.clear)
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    if goal != goals.last {
                                        Divider().padding(.horizontal, 14)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }

                        // Notificações
                        settingsSection(title: "Lembrete diário") {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ativar lembrete")
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Receba um aviso para não perder o dia")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $notifEnabled)
                                        .tint(AppColors.brandGreen)
                                        .onChange(of: notifEnabled) { _, enabled in
                                            Task {
                                                if enabled {
                                                    let granted = await notifications.requestPermission()
                                                    if !granted { notifEnabled = false }
                                                } else {
                                                    notifications.cancelAll()
                                                }
                                            }
                                        }
                                }

                                if notifEnabled {
                                    Divider()
                                    HStack {
                                        Text("Horário do lembrete")
                                            .font(.system(size: 15, weight: .bold))
                                        Spacer()
                                        DatePicker("",
                                            selection: notifBinding,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .labelsHidden()
                                    }
                                }
                            }
                            .padding(16)
                        }

                        // Versão
                        settingsSection(title: "Sobre") {
                            HStack {
                                Text("Versão")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("1.0.0 (Beta)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") { saveSettings() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.brandGreen)
                }
            }
            .onAppear {
                name = app.user.name
                dailyGoal = app.user.dailyGoalXP
                notifEnabled = app.user.notificationEnabled
                notifHour = app.user.notificationHour
            }
        }
    }

    // MARK: - Helpers

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            content()
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    private var notifBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: notifHour, minute: 0, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                notifHour = comps.hour ?? 20
            }
        )
    }

    private func saveSettings() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        app.user.name = trimmed.isEmpty ? app.user.name : trimmed
        app.user.dailyGoalXP = dailyGoal
        app.user.notificationEnabled = notifEnabled
        app.user.notificationHour = notifHour

        if notifEnabled {
            notifications.scheduleDaily(hour: notifHour, minute: 0)
        } else {
            notifications.cancelAll()
        }

        Haptics.success()
        dismiss()
    }

    private func goalDescription(_ xp: Int) -> String {
        switch xp {
        case 20:  return "Leve — ~5 min por dia"
        case 50:  return "Moderado — ~10 min por dia"
        case 100: return "Intenso — ~20 min por dia"
        default:  return "Máximo — ~30 min por dia"
        }
    }
}
