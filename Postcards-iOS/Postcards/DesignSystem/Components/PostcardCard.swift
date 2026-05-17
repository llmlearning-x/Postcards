import SwiftUI
import SwiftData

struct PostcardCard: View {
    @Environment(\.modelContext) private var modelContext
    let postcard: Postcard
    var compact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 12) {
            // Photo Area
            ZStack(alignment: .topTrailing) {
                Group {
                    if
                        let firstPhotoPath = postcard.photos.first,
                        let image = LocalMediaStore.loadImage(from: firstPhotoPath)
                    {
#if canImport(UIKit)
                        Image(uiImage: image)
                            .resizable()
#elseif canImport(AppKit)
                        Image(nsImage: image)
                            .resizable()
#endif
                    } else {
                        PostalSampleImage(theme: sampleTheme, cornerRadius: compact ? 4 : 8)
                    }
                }
                .aspectRatio(4/3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: compact ? 4 : 8))

                VStack {
                    HStack {
                        Text("TRAVEL MAIL")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(PostcardColors.travelBlue.opacity(0.86))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)

                PostalStampSeal(title: "旅行邮局", date: dateStampText)
                    .scaleEffect(compact ? 0.72 : 0.86)
                    .offset(x: compact ? 16 : 10, y: compact ? -10 : -8)
                
                Button(action: toggleFavorite) {
                    Image(systemName: postcard.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: compact ? 16 : 18, weight: .medium))
                        .foregroundColor(postcard.isFavorite ? PostcardColors.stampRed : PostcardColors.travelBlue)
                        .padding(8)
                        .background(Circle().fill(PostcardColors.overlayBackground.opacity(0.95)))
                }
                .buttonStyle(.plain)
                .padding(6)
                .frame(maxHeight: .infinity, alignment: .bottomTrailing)
            }

            // Location Stamp
            Text(postcard.locationName)
                .font(.system(size: compact ? 13 : 15, weight: .semibold, design: .serif))
                .foregroundColor(PostcardColors.inkBlack)
                .lineLimit(1)

            // Date & Weather
            HStack(spacing: 8) {
                Text(postcard.recordedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(PostcardColors.pencilGray)

                if let weather = postcard.weatherCondition {
                    Text("·")
                        .foregroundColor(PostcardColors.stampGray)
                    Text(weather)
                        .font(.caption)
                        .foregroundColor(PostcardColors.pencilGray)
                }
            }

            if !compact {
                // Note
                if let note = postcard.note, !note.isEmpty {
                    Text("\"\(note)\"")
                        .font(.body)
                        .foregroundColor(PostcardColors.inkBlack)
                        .lineLimit(2)
                }

                // Tags
                if !postcard.tags.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(postcard.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(PostcardColors.travelBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(PostcardColors.travelBlue.opacity(0.08))
                                )
                        }
                    }
                }
            }
        }
        .padding(compact ? 10 : 14)
        .background(PostcardColors.overlayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(PostcardColors.lineSepia, lineWidth: 1))
        .overlay(StampPerforationOverlay(cornerRadius: 8, color: PostcardColors.pageBackground))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
    }

    private var dateStampText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: postcard.recordedAt)
    }

    private var sampleTheme: PostalImageTheme {
        let themes = PostalImageTheme.allCases
        let index = abs(postcard.locationName.hashValue) % themes.count
        return themes[index]
    }

    private func toggleFavorite() {
        postcard.isFavorite.toggle()

        do {
            try modelContext.save()
        } catch {
            postcard.isFavorite.toggle()
            assertionFailure("Failed to update favorite state: \(error.localizedDescription)")
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
