import SwiftUI

struct MockTabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.10)

            HStack {
                tabItem(.home)
                Spacer()
                tabItem(.path)
                Spacer()
                tabItem(.profile)
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.96))
                    .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: -6)
            )
        }
    }

    private func tabItem(_ tab: AppTab) -> some View {
        Button {
            selected = tab
            Haptics.light()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(selected == tab ? AppColors.brandGreen : Color.black.opacity(0.55))

                Text(tab.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(selected == tab ? AppColors.brandGreen : Color.black.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
