import SwiftUI

struct PostalPageHeader: View {
    let title: String
    let subtitle: String
    var leadingSymbol: String = "envelope.badge"
    var trailingLabel: String = "签到"

    var body: some View {
        PostalBrandHeader(
            title: title,
            subtitle: subtitle,
            trailingLabel: trailingLabel,
            leadingSystemImage: leadingSymbol
        )
        .padding(.horizontal, -20)
    }
}

struct PostalSectionHeader: View {
    let title: String
    let trailing: String?

    var body: some View {
        PostalSectionTitle(title: title, trailing: trailing)
    }
}

struct AirmailStripe: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<20, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? PostcardColors.stampRed.opacity(0.7) : PostcardColors.travelBlue.opacity(0.7))
                    .frame(width: 10, height: 3)
                    .rotationEffect(.degrees(-24))
            }
        }
    }
}
