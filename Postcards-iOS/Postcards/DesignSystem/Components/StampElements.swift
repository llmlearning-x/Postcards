import SwiftUI

struct StampPerforationOverlay: View {
    var cornerRadius: CGFloat = 16
    var color: Color = PostcardColors.postalMint
    var body: some View {
        GeometryReader { geometry in
            let horizontalCount = max(Int(geometry.size.width / 18), 6)
            let verticalCount = max(Int(geometry.size.height / 18), 6)

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color.opacity(0.9), lineWidth: 1)

                VStack {
                    perforationRow(count: horizontalCount)
                    Spacer()
                    perforationRow(count: horizontalCount)
                }
                .padding(.horizontal, 10)

                HStack {
                    perforationColumn(count: verticalCount)
                    Spacer()
                    perforationColumn(count: verticalCount)
                }
                .padding(.vertical, 10)
            }
        }
        .allowsHitTesting(false)
    }

    private func perforationRow(count: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { _ in
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
        }
    }

    private func perforationColumn(count: Int) -> some View {
        VStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { _ in
                Circle()
                    .fill(color)
                    .frame(width: 5, height: 5)
            }
        }
    }
}

struct StampSealBadge: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 7, weight: .medium, design: .rounded))
            }
        }
        .foregroundColor(PostcardColors.stampRed)
        .padding(10)
        .background(
            Circle()
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            Circle()
                .stroke(PostcardColors.stampRed.opacity(0.8), lineWidth: 1.5)
        )
        .rotationEffect(.degrees(-9))
        .shadow(color: PostcardColors.stampRed.opacity(0.12), radius: 4, x: 0, y: 2)
    }
}

struct PostalCanvasBackground: View {
    var body: some View {
        PostalTextureBackground()
    }
}
