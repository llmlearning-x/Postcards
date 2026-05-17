import SwiftUI
import SwiftData

struct TravelDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let travel: Travel
    let onSetCurrent: (() -> Void)?
    let onStartRecording: (() -> Void)?
    let onEndTravel: (() -> Void)?
    let onDeleteTravel: (() -> Void)?

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showRecordSheet = false

    private var postcards: [Postcard] {
        (travel.postcards ?? []).sorted { $0.recordedAt > $1.recordedAt }
    }

    private var cityCount: Int {
        Set(postcards.compactMap(\.city).filter { !$0.isEmpty }).count
    }

    private var countryCount: Int {
        Set(postcards.compactMap(\.country).filter { !$0.isEmpty }).count
    }

    private var favoriteCount: Int {
        postcards.filter(\.isFavorite).count
    }

    private var visitedLocations: [String] {
        var seen = Set<String>()
        return postcards.compactMap { postcard in
            let name = postcard.city ?? postcard.locationName
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, seen.insert(trimmedName).inserted else {
                return nil
            }
            return trimmedName
        }
    }

    private var postcardTimeline: [TravelTimelineEntry] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: postcards) { postcard in
            calendar.startOfDay(for: postcard.recordedAt)
        }

        return grouped.keys.sorted(by: >).compactMap { day in
            guard let items = grouped[day] else { return nil }
            let locations = Array(
                Set(
                    items.map { ($0.city ?? $0.locationName).trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                )
            )
            .sorted()

            return TravelTimelineEntry(
                date: day,
                postcardCount: items.count,
                locations: locations
            )
        }
    }

    private var coverCandidates: [String] {
        Array(
            Set(
                postcards
                    .flatMap(\.photos)
                    .filter { !$0.isEmpty }
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                highlightsSection
                coverPickerSection
                postcardsSection
                bottomActions
            }
            .padding(16)
        }
        .background(PostalTextureBackground())
        .navigationTitle("旅程详情")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: detailToolbarPlacement) {
                Menu {
                    Button("编辑") {
                        showEditSheet = true
                    }

                    if let onEndTravel, travel.status != .completed {
                        Button("结束旅程", role: .destructive, action: onEndTravel)
                    }

                    if onDeleteTravel != nil {
                        Button("删除旅程", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditTravelView(travel: travel)
        }
        .sheet(isPresented: $showRecordSheet) {
            RecordFlowView()
        }
        .alert("删除这个旅程？", isPresented: $showDeleteConfirmation) {
            Button("删除", role: .destructive) {
                onDeleteTravel?()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("“\(travel.title)” 及其关联明信片会一并删除。")
        }
    }

    private var heroCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                LinearGradient(colors: [PostcardColors.travelBlue, Color(hex: "#0A3A30")], startPoint: .top, endPoint: .bottom)
                    .frame(width: 92)
                    .overlay(
                        VStack(alignment: .leading, spacing: 18) {
                            StampSealBadge(title: "旅行邮箱", subtitle: "TRAVEL MAIL")
                            Spacer()
                            Text("TRAVEL\nPOST\nOFFICE")
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(PostcardColors.dawnYellow)
                            Spacer()
                            Text("航空明信片\n档案")
                                .font(.caption2.weight(.medium))
                                .foregroundColor(PostcardColors.dawnYellow)
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(PostcardColors.dawnYellow, lineWidth: 1))
                        }
                        .padding(14),
                        alignment: .leading
                    )

                ZStack(alignment: .topTrailing) {
                    TravelCoverImage(imagePath: travel.coverImageURL, cornerRadius: 0)
                        .aspectRatio(1.35, contentMode: .fit)
                    LinearGradient(colors: [Color.white.opacity(0.42), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(travel.title)
                            .font(.system(size: 40, weight: .heavy, design: .serif))
                            .foregroundColor(PostcardColors.travelBlue)
                        Text(shortDateRangeText)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(PostcardColors.inkBlack)
                        Text("山水桂林 · 南宁风情 · 龙脊梯田")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(PostcardColors.travelBlue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(28)
                    PostalStampSeal(title: "航空明信片", date: dateStampText, color: PostcardColors.travelBlue)
                        .padding(18)
                }
            }

            HStack(spacing: 0) {
                detailStat(icon: "calendar", value: "\(travelDays)", title: "旅程天数")
                detailDivider
                detailStat(icon: "postcard", value: "\(postcards.count)", title: "明信片")
                detailDivider
                detailStat(icon: "mappin.and.ellipse", value: "\(cityCount)", title: "到访城市")
                detailDivider
                detailStat(icon: "seal", value: "\(favoriteCount)", title: "收集邮戳")
            }
            .padding(.vertical, 12)
            .background(PostcardColors.overlayBackground.opacity(0.95))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(StampPerforationOverlay(cornerRadius: 8, color: PostcardColors.pageBackground))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 5)
    }

    private var summaryGrid: some View {
        HStack(spacing: 12) {
            summaryItem(title: "明信片", value: "\(postcards.count)")
            summaryItem(title: "城市", value: "\(cityCount)")
            summaryItem(title: "收藏", value: "\(favoriteCount)")
            summaryItem(title: "国家", value: "\(countryCount)")
        }
    }

    private var postcardsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("旅程明信片")
                .font(.headline)
                .foregroundColor(PostcardColors.inkBlack)

            if postcards.isEmpty {
                PostalEmptyState(
                    title: "还没有旅程记录",
                    message: "继续记录后，这次旅行的明信片会出现在这里，并自动装订成旅程档案。",
                    icon: "photo.on.rectangle"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(postcards) { postcard in
                        PostcardCard(postcard: postcard, compact: true)
                    }
                }
            }
        }
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            PostalSectionHeader(title: "旅程摘要", trailing: nil)

            PostalTicket(cornerRadius: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("从桂林山水到龙脊梯田，从南宁老街到阳朔西街，用镜头和明信片记录一段关于自然与人文的美好旅程。")
                            .font(.subheadline)
                            .foregroundColor(PostcardColors.inkBlack)
                            .lineSpacing(4)
                    }
                    Spacer()
                    PostalStampSeal(title: travel.destination, date: dateStampText, color: PostcardColors.travelBlue.opacity(0.55))
                        .scaleEffect(0.86)
                }
                .padding(16)
            }

            PostalSectionHeader(title: "旅程轨迹", trailing: nil)

            PostalTicket(cornerRadius: 8) {
                VStack(alignment: .leading, spacing: 14) {
                if visitedLocations.isEmpty {
                    routeStrip(locations: ["南宁", "桂林", "阳朔", "龙脊", "北海"])
                } else {
                    routeStrip(locations: visitedLocations)
                }

                if !postcardTimeline.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("按天记录")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(PostcardColors.pencilGray)

                        ForEach(postcardTimeline.prefix(4)) { entry in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.date, format: .dateTime.month(.abbreviated).day())
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(PostcardColors.inkBlack)
                                    Text(entry.locations.joined(separator: " · "))
                                        .font(.caption)
                                        .foregroundColor(PostcardColors.pencilGray)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Text("\(entry.postcardCount) 张")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(PostcardColors.stampRed)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(PostcardColors.paperBeige)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                }
                .padding(16)
            }
        }
    }

    private var coverPickerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                PostalSectionHeader(title: "旅程封面挑选", trailing: nil)
                Spacer()
                if travel.coverImageURL != nil {
                    Button("恢复自动封面") {
                        travel.coverImageURL = coverCandidates.first
                        persistTravelChanges()
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(PostcardColors.travelBlue)
                }
            }

            if coverCandidates.isEmpty {
                HStack(spacing: 10) {
                    ForEach(PostalImageTheme.allCases.prefix(4), id: \.self) { theme in
                        PostalSampleImage(theme: theme, cornerRadius: 7)
                            .frame(width: 116, height: 78)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(coverCandidates, id: \.self) { imagePath in
                            Button {
                                travel.coverImageURL = imagePath
                                travel.updatedAt = Date()
                                persistTravelChanges()
                            } label: {
                                TravelCoverImage(imagePath: imagePath, cornerRadius: 14)
                                    .frame(width: 120, height: 88)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                travel.coverImageURL == imagePath ? PostcardColors.stampRed : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(PostcardColors.stampRed)
            Text(title)
                .font(.caption)
                .foregroundColor(PostcardColors.pencilGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var bottomActions: some View {
        HStack(spacing: 14) {
            if travel.status != .completed {
                PostalCTAButton(title: "生成航空明信片", subtitle: "将旅程记忆，寄给未来的自己", icon: "airplane", color: PostcardColors.travelBlue) {
                    onStartRecording?()
                    showRecordSheet = true
                }
                .accessibilityIdentifier("RecordButton")
            }

            Button {
                onStartRecording?()
                showRecordSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "leaf")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("继续记录")
                            .font(.system(size: 18, weight: .heavy, design: .serif))
                        Text("添加新的明信片")
                            .font(.caption)
                    }
                }
                .foregroundColor(PostcardColors.travelBlue)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(PostcardColors.travelBlue, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
    }

    private func detailStat(icon: String, value: String, title: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                Text(value)
                    .font(.system(size: 19, weight: .bold, design: .serif))
            }
            .foregroundColor(PostcardColors.travelBlue)
            Text(title)
                .font(.caption2)
                .foregroundColor(PostcardColors.pencilGray)
        }
        .frame(maxWidth: .infinity)
    }

    private var detailDivider: some View {
        Rectangle()
            .fill(PostcardColors.lineSepia)
            .frame(width: 1, height: 34)
    }

    private func routeStrip(locations: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(locations.enumerated()), id: \.offset) { index, location in
                VStack(spacing: 8) {
                    Circle()
                        .fill(index == 0 || index == locations.count - 1 ? PostcardColors.travelBlue : PostcardColors.postalMint)
                        .frame(width: 24, height: 24)
                        .overlay(Text(index == 0 ? "起" : (index == locations.count - 1 ? "终" : "")).font(.caption2.bold()).foregroundColor(.white))
                    Text(location)
                        .font(.system(size: 16, weight: .heavy, design: .serif))
                        .foregroundColor(PostcardColors.travelBlue)
                    Text(index == 0 ? "05.14" : "05.\(14 + index * 2)")
                        .font(.caption2)
                        .foregroundColor(PostcardColors.pencilGray)
                }
                if index < locations.count - 1 {
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                        .foregroundColor(PostcardColors.travelBlue.opacity(0.65))
                        .frame(height: 1)
                        .padding(.bottom, 42)
                }
            }
        }
    }

    private var statusBadge: some View {
        Text(statusLabel)
            .font(.caption.weight(.semibold))
            .foregroundColor(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var statusLabel: String {
        if travel.isCurrent {
            return "当前旅程"
        }

        switch travel.status {
        case .ongoing:
            return "进行中"
        case .completed:
            return "已结束"
        case .planned:
            return "待出发"
        }
    }

    private var statusColor: Color {
        switch travel.status {
        case .ongoing:
            return PostcardColors.travelBlue
        case .completed:
            return PostcardColors.pencilGray
        case .planned:
            return PostcardColors.stampRed
        }
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if let endDate = travel.endDate {
            return "\(formatter.string(from: travel.startDate)) - \(formatter.string(from: endDate))"
        }
        return "开始于 \(formatter.string(from: travel.startDate))"
    }

    private var shortDateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        if let endDate = travel.endDate {
            return "\(formatter.string(from: travel.startDate)) - \(formatter.string(from: endDate))"
        }
        return "\(formatter.string(from: travel.startDate)) - \(formatter.string(from: Date()))"
    }

    private var dateStampText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: travel.startDate)
    }

    private var travelDays: Int {
        max(Calendar.current.dateComponents([.day], from: travel.startDate, to: travel.endDate ?? Date()).day ?? 0, 1)
    }

    private var travelSummaryText: String {
        let duration = max(Calendar.current.dateComponents([.day], from: travel.startDate, to: travel.endDate ?? Date()).day ?? 0, 1)
        return "已记录 \(duration) 天旅程，累计 \(postcards.count) 张明信片。"
    }

    private var detailToolbarPlacement: ToolbarItemPlacement {
#if os(iOS)
        .topBarTrailing
#else
        .primaryAction
#endif
    }

    private func persistTravelChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to update travel cover: \(error.localizedDescription)")
        }
    }
}

private struct TravelTimelineEntry: Identifiable {
    let id = UUID()
    let date: Date
    let postcardCount: Int
    let locations: [String]
}

private struct EditTravelView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let travel: Travel

    @State private var title: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date?

    init(travel: Travel) {
        self.travel = travel
        _title = State(initialValue: travel.title)
        _destination = State(initialValue: travel.destination)
        _startDate = State(initialValue: travel.startDate)
        _endDate = State(initialValue: travel.endDate)
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("旅行标题", text: $title)
                TextField("目的地", text: $destination)
                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                DatePicker(
                    "结束日期",
                    selection: Binding(
                        get: { endDate ?? startDate },
                        set: { endDate = $0 }
                    ),
                    in: startDate...,
                    displayedComponents: .date
                )
                Toggle("未结束旅程", isOn: Binding(
                    get: { endDate == nil },
                    set: { isOpenEnded in
                        endDate = isOpenEnded ? nil : max(startDate, Date())
                    }
                ))
            }
            .navigationTitle("编辑旅程")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTravel()
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
    }

    private func saveTravel() {
        travel.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        travel.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        travel.startDate = startDate
        travel.endDate = endDate
        travel.updatedAt = Date()

        if let endDate {
            travel.status = endDate < Date() ? .completed : travel.status
        } else if travel.status == .completed {
            travel.status = travel.isCurrent ? .ongoing : .planned
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            assertionFailure("Failed to save travel changes: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        TravelDetailView(
            travel: Travel(title: "江南记事", destination: "苏州", startDate: .now),
            onSetCurrent: nil,
            onStartRecording: nil,
            onEndTravel: nil,
            onDeleteTravel: nil
        )
    }
    .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
