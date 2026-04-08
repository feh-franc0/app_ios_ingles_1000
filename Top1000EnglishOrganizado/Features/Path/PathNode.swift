import SwiftUI

struct PathNodeData: Identifiable {
    let id: Int
    let lessonNumber: Int
    let chapter: String
    let chapterColor: [Color]
    let emoji: String
    let isCompleted: Bool
    let isActive: Bool     // próxima a ser feita
    let isLocked: Bool
}

struct PathNodeView: View {
    let node: PathNodeData
    let onTap: () -> Void

    @State private var bouncing = false
    @State private var glowing  = false

    private let nodeSize: CGFloat = 76

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow externo quando ativo
                if node.isActive {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [(node.chapterColor.first ?? AppColors.brandGreen).opacity(glowing ? 0.35 : 0.18), .clear],
                                center: .center,
                                startRadius: nodeSize * 0.4,
                                endRadius: nodeSize * 0.9
                            )
                        )
                        .frame(width: nodeSize * 1.8, height: nodeSize * 1.8)
                }

                // Anel externo
                Circle()
                    .stroke(
                        node.isLocked
                        ? AnyShapeStyle(Color.gray.opacity(0.20))
                        : AnyShapeStyle(LinearGradient(
                            colors: node.isCompleted
                                ? [AppColors.brandGreen, Color(red: 0.00, green: 0.72, blue: 0.72)]
                                : node.chapterColor,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )),
                        lineWidth: node.isActive ? 4 : 2
                    )
                    .frame(width: nodeSize + 8, height: nodeSize + 8)
                    .opacity(node.isLocked ? 0.3 : 1.0)

                // Círculo principal
                Circle()
                    .fill(
                        node.isLocked
                        ? AnyShapeStyle(Color(.systemFill))
                        : node.isCompleted
                            ? AnyShapeStyle(LinearGradient(
                                colors: [AppColors.brandGreen, Color(red: 0.00, green: 0.72, blue: 0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                            : AnyShapeStyle(LinearGradient(
                                colors: node.chapterColor,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                    )
                    .frame(width: nodeSize, height: nodeSize)
                    .shadow(
                        color: node.isLocked ? .clear : (node.chapterColor.first ?? AppColors.brandGreen).opacity(0.40),
                        radius: node.isActive ? (glowing ? 20 : 12) : 10,
                        x: 0, y: 8
                    )

                // Ícone
                if node.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.secondary.opacity(0.45))
                } else if node.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(.white)
                } else {
                    Text(node.emoji)
                        .font(.system(size: 28))
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(bouncing ? 1.04 : 1.0)
        .onAppear {
            if node.isActive {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    bouncing = true
                    glowing  = true
                }
            }
        }
    }
}
