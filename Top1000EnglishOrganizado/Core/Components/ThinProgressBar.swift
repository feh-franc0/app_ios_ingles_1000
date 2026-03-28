import SwiftUI

struct ThinProgressBar: View {
    var value: Double          // 0...1
    var height: CGFloat = 6
    var trackOpacity: Double = 0.18
    var fill: Color = AppColors.brandBlue

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(trackOpacity))

                Capsule()
                    .fill(fill)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}
