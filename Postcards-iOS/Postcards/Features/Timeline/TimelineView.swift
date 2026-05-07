import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: \Travel.startDate, order: .reverse) private var travels: [Travel]
    @Query(sort: \Postcard.recordedAt, order: .reverse) private var postcards: [Postcard]
    @State private var searchText = ""
    @State private var selectedTravelID: UUID?
    
    private var filteredPostcards: [Postcard] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let travelScopedPostcards = postcards.filter { postcard in
            guard let selectedTravelID else { return true }
            return postcard.travelID == selectedTravelID
        }
        guard !trimmedQuery.isEmpty else { return travelScopedPostcards }

        return travelScopedPostcards.filter { postcard in
            postcard.locationName.localizedCaseInsensitiveContains(trimmedQuery) ||
            (postcard.note?.localizedCaseInsensitiveContains(trimmedQuery) ?? false) ||
            postcard.tags.contains { $0.localizedCaseInsensitiveContains(trimmedQuery) }
        }
    }

    private var groupedPostcards: [(date: Date, items: [Postcard])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredPostcards) { postcard in
            calendar.startOfDay(for: postcard.recordedAt)
        }
        return grouped.sorted { $0.key > $1.key }.map { (date: $0.key, items: $0.value) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if groupedPostcards.isEmpty {
                    ScrollView {
                        VStack(spacing: 24) {
                            PostalPageHeader(
                                title: "时间轴",
                                subtitle: "邮件分拣中心 / 旅行邮件档案",
                                leadingSymbol: "shippingbox",
                                trailingLabel: "筛选"
                            )
                            .padding(.horizontal, 16)

                            PostalEmptyState(
                                title: searchText.isEmpty ? "还没有投递记录" : "没有搜索结果",
                                message: searchText.isEmpty ? "保存第一张明信片后，时间轴会按日期分拣成一枚枚旅行邮票。" : "试试搜索别的地点、文字或标签。",
                                icon: searchText.isEmpty ? "tray" : "magnifyingglass"
                            )
                            .padding(.horizontal, 16)

                            sampleTimelinePreview
                                .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 16)
                    }
                    .background(PostalTextureBackground())
                } else {
                    ScrollView {
                        PostalPageHeader(
                            title: "时间轴",
                            subtitle: "邮件分拣中心 / 旅行邮件档案",
                            leadingSymbol: "shippingbox",
                            trailingLabel: "筛选"
                        )
                        .padding(.horizontal, 16)

                        TravelFilterChips(
                            travels: travels,
                            selectedTravelID: $selectedTravelID,
                            allTitle: "全部",
                            selectedColor: PostcardColors.stampRed,
                            font: .caption.weight(.semibold)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                            ForEach(groupedPostcards, id: \.date) { group in
                                Section {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                        ForEach(group.items) { postcard in
                                            PostcardCard(postcard: postcard, compact: true)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                } header: {
                                    DateHeader(date: group.date, location: group.items.first?.locationName ?? "")
                                        .background(.ultraThinMaterial)
                                }
                            }
                        }
                        .padding(.top, 16)
                    }
                    .background(PostalTextureBackground())
                }
            }
#if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
#endif
            .searchable(text: $searchText, prompt: "搜索地点、标签...")
        }
    }

    private var sampleTimelinePreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            DateHeader(date: Date(), location: "南宁")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                sampleStamp(title: "南宁", caption: "抵达绿城，开启旅程", theme: .oldTown)
                sampleStamp(title: "青秀山", caption: "城市绿肺，登高望远", theme: .guangxi)
            }
            .opacity(0.72)
        }
        .allowsHitTesting(false)
    }

    private func sampleStamp(title: String, caption: String, theme: PostalImageTheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PostalSampleImage(theme: theme, cornerRadius: 5)
                .frame(height: 104)
            Text(title)
                .font(.system(size: 19, weight: .heavy, design: .serif))
                .foregroundColor(PostcardColors.travelBlue)
            Text(caption)
                .font(.caption)
                .foregroundColor(PostcardColors.pencilGray)
        }
        .padding(10)
        .background(PostcardColors.overlayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(StampPerforationOverlay(cornerRadius: 8, color: PostcardColors.pageBackground))
    }
}

struct DateHeader: View {
    let date: Date
    let location: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                Text(stampMonth)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                Divider()
                    .background(PostcardColors.stampRed)
                Text(stampDay)
                    .font(.system(size: 20, weight: .bold, design: .serif))
            }
            .foregroundColor(PostcardColors.stampRed)
            .frame(width: 58, height: 58)
            .overlay(Circle().stroke(PostcardColors.stampRed.opacity(0.8), lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(date, format: .dateTime.month(.twoDigits).day(.twoDigits))
                        .font(.system(size: 25, weight: .bold, design: .serif))
                        .foregroundColor(PostcardColors.travelBlue)
                    Text(location)
                        .font(.system(size: 24, weight: .heavy, design: .serif))
                        .foregroundColor(PostcardColors.travelBlue)
                    PostalWaveLine()
                        .frame(width: 58, height: 18)
                }

                HStack(spacing: 6) {
                    Image(systemName: "mappin")
                        .font(.caption.weight(.semibold))
                    Text(location.isEmpty ? "旅行邮件档案" : location)
                        .font(.caption)
                }
                .foregroundColor(PostcardColors.pencilGray)
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundColor(PostcardColors.travelBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PostcardColors.pageBackground.opacity(0.96))
    }

    private var stampMonth: String {
        date.formatted(.dateTime.month(.abbreviated))
            .uppercased()
    }

    private var stampDay: String {
        date.formatted(.dateTime.day())
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
