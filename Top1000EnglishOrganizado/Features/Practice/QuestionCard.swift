import SwiftUI

struct QuestionCard: View {
    let title: String
    let prompt: String
    /// Texto em inglês para pronunciar (nil = sem botão de áudio)
    var audioText: String? = nil

    @State private var isPlaying = false
    private let audio = MockAudioService()

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Botão de áudio — só aparece quando há texto em inglês
                    if let text = audioText {
                        Button {
                            Haptics.light()
                            isPlaying = true
                            audio.speak(text, language: "en-US")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isPlaying = false
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(AppColors.brandBlue.opacity(0.12))
                                    .frame(width: 36, height: 36)

                                Image(systemName: isPlaying ? "waveform" : "speaker.wave.2.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.brandBlue)
                                    .symbolEffect(.variableColor.iterative, isActive: isPlaying)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(prompt)
                    .font(.system(size: 20, weight: .bold))
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, 16)
    }
}
