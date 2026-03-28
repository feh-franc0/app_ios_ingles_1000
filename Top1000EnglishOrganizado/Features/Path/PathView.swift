import SwiftUI

struct PathView: View {
    @EnvironmentObject private var app: AppStore
    @State private var showSession = false

    var body: some View {
        ZStack {
            StrongBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    SectionTitle("Trilha", subtitle: "Desbloqueie nós e ganhe moedas")
                        .padding(.top, 12)

                    VStack(spacing: 18) {
                        ForEach(1...10, id: \.self) { idx in
                            PathNode(index: idx, isLocked: idx > 3) {
                                if idx <= 3 {
                                    Haptics.medium()
                                    showSession = true
                                } else {
                                    Haptics.error()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Trilha")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSession) {
            PracticeSessionView(
                mode: .words,
                startIndex: app.progress(for: .words)
            )
            .environmentObject(app)
        }
    }
}
