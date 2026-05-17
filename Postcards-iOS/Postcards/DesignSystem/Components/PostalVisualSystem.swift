import SwiftUI

struct PostalTextureBackground: View {
    var body: some View {
        ZStack {
            PostcardColors.pageBackground

            LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    PostcardColors.paperBeige.opacity(0.55),
                    PostcardColors.postalMint.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                for index in 0..<180 {
                    let x = Double((index * 47) % max(Int(size.width), 1))
                    let y = Double((index * 83) % max(Int(size.height), 1))
                    let rect = CGRect(x: x, y: y, width: 1.1, height: 1.1)
                    context.fill(Path(ellipseIn: rect), with: .color(PostcardColors.lineSepia.opacity(0.18)))
                }
            }

            VStack {
                HStack {
                    Spacer()
                    PostalWatermarkSeal(text: "TRAVEL MAIL")
                        .frame(width: 190, height: 190)
                        .opacity(0.26)
                        .offset(x: 34, y: -40)
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct PostalBrandHeader: View {
    let title: String
    let subtitle: String
    var centerTitle: String? = nil
    var trailingLabel: String? = "签到"
    var leadingSystemImage: String = "envelope"

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(PostcardColors.travelBlue, lineWidth: 2)
                    Image(systemName: leadingSystemImage)
                        .font(.system(size: 20, weight: .semibold))
                    PostalWaveLine()
                        .frame(width: 46, height: 16)
                        .offset(x: 25, y: 13)
                }
                .foregroundColor(PostcardColors.travelBlue)
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 29, weight: .heavy, design: .serif))
                        .foregroundColor(PostcardColors.travelBlue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(PostcardColors.travelBlue.opacity(0.78))
                        .tracking(2)
                }
            }

            Spacer(minLength: 8)

            if let centerTitle {
                Text(centerTitle)
                    .font(.system(size: 27, weight: .heavy, design: .serif))
                    .foregroundColor(PostcardColors.travelBlue)
            }

            if let trailingLabel {
                HStack(spacing: 6) {
                    Image(systemName: trailingLabel == "筛选" ? "line.3.horizontal.decrease" : "calendar.badge.checkmark")
                        .font(.caption.weight(.bold))
                    Text(trailingLabel)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(PostcardColors.travelBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(PostcardColors.overlayBackground.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PostcardColors.lineSepia, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

struct PostalSectionTitle: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .heavy, design: .serif))
                .foregroundColor(PostcardColors.travelBlue)
            PostalWaveLine()
                .frame(width: 62, height: 18)
                .foregroundColor(PostcardColors.stampGray.opacity(0.75))
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(PostcardColors.pencilGray)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(PostcardColors.pencilGray)
            }
        }
    }
}

struct PostalTicket<Content: View>: View {
    var cornerRadius: CGFloat = 10
    var fill: Color = PostcardColors.overlayBackground
    var perforationColor: Color = PostcardColors.pageBackground
    var borderColor: Color = PostcardColors.lineSepia
    var content: Content

    init(
        cornerRadius: CGFloat = 10,
        fill: Color = PostcardColors.overlayBackground,
        perforationColor: Color = PostcardColors.pageBackground,
        borderColor: Color = PostcardColors.lineSepia,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.perforationColor = perforationColor
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(0.82), lineWidth: 1)
            )
            .overlay(StampPerforationOverlay(cornerRadius: cornerRadius, color: perforationColor))
            .shadow(color: Color.black.opacity(0.09), radius: 10, x: 0, y: 4)
    }
}

struct PostalWaveLine: View {
    var body: some View {
        Canvas { context, size in
            for row in 0..<3 {
                var path = Path()
                let y = size.height * (0.24 + Double(row) * 0.25)
                path.move(to: CGPoint(x: 0, y: y))
                var x: CGFloat = 0
                while x <= size.width {
                    path.addCurve(
                        to: CGPoint(x: x + 16, y: y),
                        control1: CGPoint(x: x + 4, y: y - 5),
                        control2: CGPoint(x: x + 12, y: y + 5)
                    )
                    x += 16
                }
                context.stroke(path, with: .color(PostcardColors.travelBlue.opacity(0.55)), lineWidth: 1.1)
            }
        }
    }
}

struct PostalWatermarkSeal: View {
    let text: String

    var body: some View {
        ZStack {
            Circle().stroke(PostcardColors.stampGray.opacity(0.45), lineWidth: 2)
            Circle().stroke(PostcardColors.stampGray.opacity(0.3), lineWidth: 12).padding(16)
            Text(text)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(PostcardColors.stampGray.opacity(0.5))
                .rotationEffect(.degrees(-18))
        }
    }
}

struct PostalStampSeal: View {
    let title: String
    var date: String? = nil
    var color: Color = PostcardColors.stampRed

    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .serif))
                .tracking(1)
            if let date {
                Text(date)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
        }
        .foregroundColor(color)
        .frame(width: 74, height: 74)
        .overlay(Circle().stroke(color.opacity(0.78), lineWidth: 1.5))
        .overlay(Circle().stroke(color.opacity(0.55), lineWidth: 0.8).padding(8))
        .rotationEffect(.degrees(-10))
    }
}

struct PostalStatsTicket: View {
    let items: [PostalStatItem]
    var compact: Bool = false

    var body: some View {
        PostalTicket(cornerRadius: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        statCell(item)
                        if index < items.count - 1 {
                            Rectangle()
                                .fill(PostcardColors.lineSepia)
                                .frame(width: 1, height: compact ? 42 : 58)
                        }
                    }
                }
                AirmailStripe()
                    .frame(height: 8)
                    .clipped()
            }
            .padding(.top, compact ? 12 : 16)
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
    }

    private func statCell(_ item: PostalStatItem) -> some View {
        VStack(spacing: compact ? 4 : 7) {
            Image(systemName: item.icon)
                .font(.system(size: compact ? 18 : 22, weight: .medium))
                .foregroundColor(PostcardColors.travelBlue)
            Text(item.title)
                .font(.system(size: compact ? 11 : 13, weight: .medium))
                .foregroundColor(PostcardColors.pencilGray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(item.value)
                    .font(.system(size: compact ? 22 : 30, weight: .bold, design: .serif))
                    .foregroundColor(PostcardColors.travelBlue)
                Text(item.suffix)
                    .font(.caption)
                    .foregroundColor(PostcardColors.pencilGray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PostalStatItem {
    let icon: String
    let title: String
    let value: String
    let suffix: String
}

struct PostalCTAButton: View {
    let title: String
    let subtitle: String?
    let icon: String
    var color: Color = PostcardColors.travelBlue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .heavy, design: .serif))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption.weight(.semibold))
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(PostcardColors.dawnYellow.opacity(0.8), lineWidth: 1)
                    .padding(4)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PostalEmptyState: View {
    let title: String
    let message: String
    var icon: String = "envelope.open"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        PostalTicket(cornerRadius: 10) {
            VStack(spacing: 16) {
                ZStack {
                    PostalWatermarkSeal(text: "POST")
                        .frame(width: 118, height: 118)
                        .opacity(0.42)
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(PostcardColors.travelBlue)
                }

                VStack(spacing: 7) {
                    Text(title)
                        .font(.system(size: 24, weight: .heavy, design: .serif))
                        .foregroundColor(PostcardColors.travelBlue)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(PostcardColors.pencilGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                if let actionTitle, let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 11)
                            .background(PostcardColors.travelBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }

                AirmailStripe()
                    .frame(height: 8)
                    .clipped()
                    .padding(.horizontal, 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
    }
}

struct PostalSampleImage: View {
    let theme: PostalImageTheme
    var cornerRadius: CGFloat = 8

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            theme.landscape
                .stroke(theme.lineColor.opacity(0.95), lineWidth: 2)
                .padding(12)
            PostalWaveLine()
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 84, height: 22)
                .offset(x: 40, y: -34)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

enum PostalImageTheme: CaseIterable, Hashable {
    case guangxi, shanghai, coast, terrace, mountain, oldTown

    var colors: [Color] {
        switch self {
        case .guangxi: return [Color(hex: "#B8DAEA"), Color(hex: "#2E7D58"), Color(hex: "#F5EBD9")]
        case .shanghai: return [Color(hex: "#243C63"), Color(hex: "#C78D5A"), Color(hex: "#E9E0CE")]
        case .coast: return [Color(hex: "#89C5D5"), Color(hex: "#ECE2C8"), Color(hex: "#2E8B75")]
        case .terrace: return [Color(hex: "#E6B06A"), Color(hex: "#557E48"), Color(hex: "#F3E7D5")]
        case .mountain: return [Color(hex: "#DDE9DE"), Color(hex: "#87A18A"), Color(hex: "#EFE7D7")]
        case .oldTown: return [Color(hex: "#27394B"), Color(hex: "#A65E3D"), Color(hex: "#F0D4A2")]
        }
    }

    var lineColor: Color {
        switch self {
        case .guangxi, .coast, .terrace, .mountain: return PostcardColors.travelBlue
        case .shanghai, .oldTown: return Color.white.opacity(0.8)
        }
    }

    var landscape: Path {
        var path = Path()
        switch self {
        case .guangxi:
            path.move(to: CGPoint(x: 0, y: 95))
            path.addCurve(to: CGPoint(x: 80, y: 32), control1: CGPoint(x: 30, y: 82), control2: CGPoint(x: 48, y: 28))
            path.addCurve(to: CGPoint(x: 155, y: 96), control1: CGPoint(x: 114, y: 38), control2: CGPoint(x: 116, y: 88))
            path.move(to: CGPoint(x: 10, y: 118))
            path.addCurve(to: CGPoint(x: 160, y: 118), control1: CGPoint(x: 54, y: 132), control2: CGPoint(x: 116, y: 100))
        case .shanghai:
            for x in stride(from: 10, through: 140, by: 22) {
                path.addRect(CGRect(x: CGFloat(x), y: CGFloat(48 + (x % 3) * 8), width: 12, height: 58))
            }
            path.move(to: CGPoint(x: 0, y: 112))
            path.addLine(to: CGPoint(x: 170, y: 112))
        case .coast:
            path.move(to: CGPoint(x: 0, y: 80))
            path.addCurve(to: CGPoint(x: 170, y: 68), control1: CGPoint(x: 50, y: 44), control2: CGPoint(x: 105, y: 100))
            path.move(to: CGPoint(x: 10, y: 105))
            path.addCurve(to: CGPoint(x: 150, y: 103), control1: CGPoint(x: 48, y: 92), control2: CGPoint(x: 96, y: 120))
        case .terrace:
            for y in stride(from: 48, through: 122, by: 16) {
                path.move(to: CGPoint(x: 0, y: CGFloat(y)))
                path.addCurve(to: CGPoint(x: 170, y: CGFloat(y - 8)), control1: CGPoint(x: 48, y: CGFloat(y - 24)), control2: CGPoint(x: 110, y: CGFloat(y + 10)))
            }
        case .mountain:
            path.move(to: CGPoint(x: 0, y: 120))
            path.addLine(to: CGPoint(x: 40, y: 50))
            path.addLine(to: CGPoint(x: 72, y: 94))
            path.addLine(to: CGPoint(x: 110, y: 38))
            path.addLine(to: CGPoint(x: 170, y: 120))
        case .oldTown:
            path.addRect(CGRect(x: 18, y: 62, width: 38, height: 44))
            path.addRect(CGRect(x: 88, y: 52, width: 48, height: 54))
            path.move(to: CGPoint(x: 10, y: 62))
            path.addLine(to: CGPoint(x: 38, y: 34))
            path.addLine(to: CGPoint(x: 64, y: 62))
            path.move(to: CGPoint(x: 78, y: 52))
            path.addLine(to: CGPoint(x: 112, y: 24))
            path.addLine(to: CGPoint(x: 146, y: 52))
        }
        return path
    }
}
