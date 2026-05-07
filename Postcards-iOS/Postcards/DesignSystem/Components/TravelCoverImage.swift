import SwiftUI

struct TravelCoverImage: View {
    let imagePath: String?
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if
                let imagePath,
                let image = LocalMediaStore.loadImage(from: imagePath)
            {
#if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
#elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
#endif
            } else {
                PostalSampleImage(theme: .guangxi, cornerRadius: cornerRadius)
            }
        }
        .scaledToFill()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
