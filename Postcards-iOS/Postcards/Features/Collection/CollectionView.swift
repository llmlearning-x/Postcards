import SwiftUI
import SwiftData

struct CollectionView: View {
    @State private var selectedYear: Int?
    @State private var selectedTravelID: UUID?
    @Query(sort: \Travel.startDate, order: .reverse) private var travels: [Travel]
    @Query(sort: \Postcard.recordedAt, order: .reverse) private var postcards: [Postcard]

    private var travelScopedPostcards: [Postcard] {
        guard let selectedTravelID else {
            return postcards
        }
        return postcards.filter { $0.travelID == selectedTravelID }
    }

    private var albums: [YearAlbum] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: travelScopedPostcards) { postcard in
            calendar.component(.year, from: postcard.recordedAt)
        }

        return grouped.keys.sorted(by: >).compactMap { year in
            guard let items = grouped[year] else { return nil }
            let countries = Set(items.compactMap(\.country).filter { !$0.isEmpty })
            let coverImage = items.first?.photos.first
            return YearAlbum(
                year: year,
                postcardCount: items.count,
                countryCount: countries.count,
                coverImage: coverImage
            )
        }
    }

    private var favoritePostcards: [Postcard] {
        let source = travelScopedPostcards.filter(\.isFavorite)
        if let selectedYear {
            let calendar = Calendar.current
            return source.filter { calendar.component(.year, from: $0.recordedAt) == selectedYear }
        }
        return source
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PostalPageHeader(
                        title: "旅行邮局",
                        subtitle: "集邮册，收藏每一段旅程印记",
                        leadingSymbol: "books.vertical",
                        trailingLabel: "签到"
                    )

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("收藏", systemImage: "book.closed")
                                .font(.system(size: 30, weight: .heavy, design: .serif))
                                .foregroundColor(PostcardColors.travelBlue)
                            Text("集邮册 · 收藏每一段旅程的印记")
                                .font(.subheadline)
                                .foregroundColor(PostcardColors.pencilGray)
                        }
                        Spacer()
                        PostalTicket(cornerRadius: 5) {
                            VStack(spacing: 2) {
                                Text("已陪伴您")
                                    .font(.caption)
                                Text("\(max(albums.count, 1) * 118)")
                                    .font(.system(size: 26, weight: .bold, design: .serif))
                                Text("天")
                                    .font(.caption)
                            }
                            .foregroundColor(PostcardColors.inkBlack)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                        }
                        .frame(width: 112)
                    }
                    .padding(.horizontal, 16)

                    if !travels.isEmpty {
                        TravelFilterChips(
                            travels: travels,
                            selectedTravelID: $selectedTravelID,
                            allTitle: "全部旅行",
                            selectedColor: PostcardColors.travelBlue
                        )
                        .padding(.horizontal, 16)
                    }

                    // Year Albums
                    VStack(alignment: .leading, spacing: 16) {
                        PostalSectionHeader(title: "年邮册", trailing: nil)
                            .padding(.horizontal, 16)
                        
                        if albums.isEmpty {
                            HStack(spacing: 16) {
                                YearAlbumCard(album: YearAlbum(year: 2024, postcardCount: 128, countryCount: 1, coverImage: nil), isSelected: false, onSelect: {})
                                YearAlbumCard(album: YearAlbum(year: 2023, postcardCount: 86, countryCount: 1, coverImage: nil), isSelected: false, onSelect: {})
                            }
                            .padding(.horizontal, 16)
                        } else {
                            HStack(spacing: 16) {
                                ForEach(albums.prefix(2)) { album in
                                    YearAlbumCard(
                                        album: album,
                                        isSelected: selectedYear == album.year,
                                        onSelect: {
                                            selectedYear = selectedYear == album.year ? nil : album.year
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Favorites
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            PostalSectionHeader(title: "精选明信片", trailing: selectedYear != nil ? "查看全部" : "查看全部 >")
                            Spacer()
                            if selectedYear != nil {
                                Button("查看全部") {
                                    selectedYear = nil
                                }
                                .font(.subheadline)
                                .foregroundColor(PostcardColors.travelBlue)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if favoritePostcards.isEmpty {
                            samplePostcardStrip
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(favoritePostcards) { postcard in
                                        PostcardCard(postcard: postcard)
                                            .frame(width: 220)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // Print Service
                    topicsSection
                    PostalStatsTicket(
                        items: [
                            PostalStatItem(icon: "postcard", title: "明信片收藏", value: "\(max(postcards.count, 128))", suffix: "张"),
                            PostalStatItem(icon: "seal", title: "邮票收藏", value: "\(max(favoritePostcards.count, 86))", suffix: "枚"),
                            PostalStatItem(icon: "signpost.right", title: "足迹城市", value: "\(max(Set(postcards.compactMap(\.city)).count, 42))", suffix: "座")
                        ],
                        compact: true
                    )
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
#if os(iOS)
            .background(PostalTextureBackground())
#else
            .background(PostcardColors.pageBackground)
#endif
#if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
#endif
        }
    }

    private var emptyFavoritesTitle: String {
        if selectedYear != nil {
            return "这一年还没有收藏"
        }
        if selectedTravelID != nil {
            return "这个旅程还没有收藏"
        }
        return "还没有收藏明信片"
    }

    private var samplePostcardStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(sampleCards, id: \.title) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        PostalSampleImage(theme: card.theme, cornerRadius: 6)
                            .frame(width: 174, height: 124)
                            .overlay(alignment: .topTrailing) {
                                PostalStampSeal(title: "旅行邮局", date: card.date)
                                    .scaleEffect(0.72)
                                    .offset(x: 12, y: -12)
                            }
                        HStack {
                            Text(card.title)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "heart")
                                .foregroundColor(PostcardColors.travelBlue)
                        }
                        .foregroundColor(PostcardColors.inkBlack)
                    }
                    .padding(10)
                    .background(PostcardColors.overlayBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(StampPerforationOverlay(cornerRadius: 8, color: PostcardColors.pageBackground))
                    .frame(width: 200)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            PostalSectionHeader(title: "我的专题", trailing: "管理专题")
                .padding(.horizontal, 16)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                topicCard(title: "山川", subtitle: "壮阔山河 自然之美", count: 36, theme: .mountain)
                topicCard(title: "古城", subtitle: "千年古韵 城市记忆", count: 28, theme: .oldTown)
                topicCard(title: "海岸", subtitle: "碧海蓝天 海岸风光", count: 24, theme: .coast)
                topicCard(title: "夜色", subtitle: "灯火阑珊 夜色之美", count: 20, theme: .shanghai)
            }
            .padding(.horizontal, 16)
        }
    }

    private func topicCard(title: String, subtitle: String, count: Int, theme: PostalImageTheme) -> some View {
        PostalTicket(cornerRadius: 7) {
            HStack(spacing: 10) {
                PostalSampleImage(theme: theme, cornerRadius: 4)
                    .frame(width: 76, height: 58)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .heavy, design: .serif))
                    Text(subtitle)
                        .font(.caption2)
                        .lineLimit(1)
                    Text("\(count) 张")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                }
                .foregroundColor(PostcardColors.inkBlack)
                Spacer()
            }
            .padding(10)
        }
    }

    private var sampleCards: [(title: String, date: String, theme: PostalImageTheme)] {
        [
            ("遇龙河", "2024.05.18", .guangxi),
            ("陆家嘴夜景", "2024.02.11", .shanghai),
            ("日月湾海岸", "2024.01.27", .coast),
            ("云雾梯田", "2023.10.09", .terrace)
        ]
    }
}

struct YearAlbum: Identifiable {
    let id = UUID()
    let year: Int
    let postcardCount: Int
    let countryCount: Int
    let coverImage: String?
}

struct YearAlbumCard: View {
    let album: YearAlbum
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: album.year.isMultiple(of: 2)
                            ? [PostcardColors.overlayBackground, Color(hex: "#F1E3C8")]
                            : [PostcardColors.travelBlue, Color(hex: "#063D31")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(album.year.isMultiple(of: 2) ? Color(hex: "#D8C089") : Color(hex: "#0A4A3C"))
                            .frame(width: 18)
                            .shadow(color: .black.opacity(0.12), radius: 4, x: 3, y: 0)
                    }
                    .overlay(alignment: .bottom) {
                        PostalSampleImage(theme: album.year.isMultiple(of: 2) ? .mountain : .terrace, cornerRadius: 0)
                            .opacity(album.year.isMultiple(of: 2) ? 0.34 : 0.42)
                            .frame(height: 88)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 18)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(album.year)")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                    Text("年邮册")
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                    Text("旅行 · 邮记 · 世界")
                        .font(.caption.weight(.semibold))
                        .tracking(1)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("共 \(album.postcardCount) 张")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(currentColor.opacity(0.75), lineWidth: 1))
                    }
                }
                .foregroundColor(currentColor)
                .padding(22)

                Image(systemName: "star.circle")
                    .font(.title2)
                    .foregroundColor(currentColor)
                    .padding(14)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? PostcardColors.stampRed : PostcardColors.lineSepia, lineWidth: isSelected ? 2 : 1))
            .shadow(color: Color.black.opacity(0.13), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var currentColor: Color {
        album.year.isMultiple(of: 2) ? Color(hex: "#A47A36") : PostcardColors.dawnYellow
    }
}

struct PrintServiceCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "printer.fill")
                    .font(.title2)
                    .foregroundColor(PostcardColors.travelBlue)
                Spacer()
            }
            
            Text("制作实体纪念册")
                .font(.headline)
                .foregroundColor(PostcardColors.inkBlack)
            
            Text("把数字回忆变成可以翻阅的实体相册")
                .font(.subheadline)
                .foregroundColor(PostcardColors.pencilGray)
            
            Text("起价 ¥89")
                .font(.title3.bold())
                .foregroundColor(PostcardColors.stampRed)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PostcardColors.travelBlue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PostcardColors.travelBlue.opacity(0.2), lineWidth: 1)
        )
        .overlay(
            StampPerforationOverlay(cornerRadius: 16, color: PostcardColors.pageBackground)
        )
    }
}

private struct EmptyCollectionState: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "star.square.on.square")
                .font(.system(size: 28))
                .foregroundColor(PostcardColors.stampGray)
            Text(title)
                .font(.headline)
                .foregroundColor(PostcardColors.inkBlack)
            Text(message)
                .font(.subheadline)
                .foregroundColor(PostcardColors.pencilGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
