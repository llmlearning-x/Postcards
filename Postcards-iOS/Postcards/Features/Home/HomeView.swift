import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Travel.startDate, order: .reverse) private var travels: [Travel]
    @Query(sort: \Postcard.recordedAt, order: .reverse) private var postcards: [Postcard]
    @State private var showRecordSheet = false
    @State private var showCreateTravelSheet = false
    @State private var pendingDeletionTravel: Travel?
    @State private var selectedTravelForDetail: Travel?

    private var currentTravel: Travel? {
        travels.first { $0.isCurrent } ?? travels.first { $0.status == .ongoing }
    }

    private var otherTravels: [Travel] {
        travels.filter { $0.id != currentTravel?.id }
    }

    private var uniqueCityCount: Int {
        return Set(
            postcards
                .map(\.locationName)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        ).count
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                PostalTextureBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        PostalPageHeader(
                            title: "旅行邮局",
                            subtitle: "用明信片，记录世界",
                            leadingSymbol: "envelope.badge",
                            trailingLabel: "签到"
                        )

                        // Current Travel Card
                        if let travel = currentTravel {
                            CurrentTravelCard(
                                travel: travel,
                                onContinue: {
                                    showRecordSheet = true
                                },
                                onOpenDetails: {
                                    selectedTravelForDetail = travel
                                },
                                onEndTravel: {
                                    endTravel(travel)
                                }
                            )
                        } else {
                            EmptyTravelCard {
                                showCreateTravelSheet = true
                            }
                        }

                        if !otherTravels.isEmpty {
                            TravelSwitcherCard(
                                travels: otherTravels,
                                onSelectTravel: { travel in
                                    setCurrentTravel(travel)
                                },
                                onOpenDetails: { travel in
                                    selectedTravelForDetail = travel
                                },
                                onDeleteTravel: { travel in
                                    pendingDeletionTravel = travel
                                }
                            )
                        }
                        
                        MapPreviewCard(
                            cityCount: uniqueCityCount,
                            postcardCount: postcards.count,
                            stampCount: postcards.filter(\.isFavorite).count
                        )
                            .frame(height: 180)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                // FAB
                FABButton {
                    showRecordSheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
#if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
#endif
            .sheet(isPresented: $showRecordSheet) {
                RecordFlowView()
            }
            .sheet(isPresented: $showCreateTravelSheet) {
                CreateTravelView { title, destination, startDate in
                    let travel = Travel(title: title, destination: destination, startDate: startDate)
                    markAllTravelsAsNotCurrent()
                    modelContext.insert(travel)

                    do {
                        try modelContext.save()
                    } catch {
                        assertionFailure("Failed to save travel: \(error.localizedDescription)")
                    }
                }
            }
            .sheet(item: $selectedTravelForDetail) { travel in
                NavigationStack {
                    TravelDetailView(
                        travel: travel,
                        onSetCurrent: travel.status == .completed ? nil : {
                            setCurrentTravel(travel)
                        },
                        onStartRecording: travel.status == .completed ? nil : {
                            if !travel.isCurrent {
                                setCurrentTravel(travel)
                            }
                        },
                        onEndTravel: travel.status == .completed ? nil : {
                            endTravel(travel)
                        },
                        onDeleteTravel: {
                            selectedTravelForDetail = nil
                            deleteTravel(travel)
                        }
                    )
                }
            }
            .alert("删除这个旅程？", isPresented: pendingDeletionTravelAlertBinding, presenting: pendingDeletionTravel) { travel in
                Button("删除", role: .destructive) {
                    deleteTravel(travel)
                }
                Button("取消", role: .cancel) {
                    pendingDeletionTravel = nil
                }
            } message: { travel in
                Text("“\(travel.title)” 及其关联明信片会一并删除。")
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
        }
    }

    private func markAllTravelsAsNotCurrent() {
        for travel in travels {
            travel.isCurrent = false
            if travel.status == .ongoing {
                travel.status = .planned
            }
            travel.updatedAt = Date()
        }
    }

    private func setCurrentTravel(_ selectedTravel: Travel) {
        markAllTravelsAsNotCurrent()
        selectedTravel.isCurrent = true
        if selectedTravel.status != .completed {
            selectedTravel.status = .ongoing
        }
        selectedTravel.updatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to switch current travel: \(error.localizedDescription)")
        }
    }

    private func endTravel(_ travel: Travel) {
        travel.status = .completed
        travel.isCurrent = false
        travel.endDate = Date()
        travel.updatedAt = Date()

        if let fallbackTravel = travels.first(where: { $0.id != travel.id && $0.status != .completed }) {
            fallbackTravel.isCurrent = true
            fallbackTravel.status = .ongoing
            fallbackTravel.updatedAt = Date()
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to end travel: \(error.localizedDescription)")
        }
    }

    private func deleteTravel(_ travel: Travel) {
        let shouldPromoteFallback = travel.isCurrent
        modelContext.delete(travel)

        if shouldPromoteFallback, let fallbackTravel = travels.first(where: { $0.id != travel.id && $0.status != .completed }) {
            fallbackTravel.isCurrent = true
            fallbackTravel.status = .ongoing
            fallbackTravel.updatedAt = Date()
        }

        do {
            try modelContext.save()
            pendingDeletionTravel = nil
        } catch {
            assertionFailure("Failed to delete travel: \(error.localizedDescription)")
        }
    }

    private var pendingDeletionTravelAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletionTravel != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDeletionTravel = nil
                }
            }
        )
    }
}

// MARK: - Current Travel Card
struct CurrentTravelCard: View {
    private let travel: Travel
    let onContinue: () -> Void
    let onOpenDetails: () -> Void
    let onEndTravel: () -> Void

    init(travel: Travel, onContinue: @escaping () -> Void, onOpenDetails: @escaping () -> Void, onEndTravel: @escaping () -> Void) {
        self.travel = travel
        self.onContinue = onContinue
        self.onOpenDetails = onOpenDetails
        self.onEndTravel = onEndTravel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [PostcardColors.travelBlue, Color(hex: "#0B3E32")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        StampSealBadge(title: "旅行邮箱", subtitle: "TRAVEL MAIL")
                        Spacer()
                        Text("TRAVEL\nPOST\nOFFICE")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .foregroundColor(PostcardColors.dawnYellow)
                        Spacer()
                        Text("旅行邮箱\n出品")
                            .font(.caption2)
                            .foregroundColor(PostcardColors.dawnYellow.opacity(0.85))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(PostcardColors.dawnYellow.opacity(0.7), lineWidth: 1))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 98)

                ZStack(alignment: .bottomLeading) {
                    TravelCoverImage(imagePath: travel.coverImageURL, cornerRadius: 0)
                        .aspectRatio(1.34, contentMode: .fit)

                    LinearGradient(
                        colors: [Color.white.opacity(0.48), Color.white.opacity(0.08), .black.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(travel.title)
                            .font(.system(size: 38, weight: .heavy, design: .serif))
                            .foregroundColor(PostcardColors.travelBlue)
                            .shadow(color: .white.opacity(0.7), radius: 2)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("第")
                            Text("\(travelDays)")
                                .foregroundColor(PostcardColors.stampRed)
                                .font(.system(size: 30, weight: .heavy, design: .serif))
                            Text("天")
                        }
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundColor(PostcardColors.travelBlue)

                        Label("进行中", systemImage: "wave.3.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(PostcardColors.travelBlue)
                    }
                    .padding(22)

                    VStack {
                        HStack {
                            Spacer()
                            PostalStampSeal(title: "旅行邮局", date: dateStampText)
                        }
                        Spacer()
                    }
                    .padding(14)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 10) {
                Label(dateRangeText, systemImage: "calendar")
                Text("·")
                    .foregroundColor(PostcardColors.stampRed)
                Text(routeText)
                    .lineLimit(1)
                Spacer()
                Text("共\(totalDays)天")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(PostcardColors.travelBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .font(.caption.weight(.medium))
            .foregroundColor(PostcardColors.pencilGray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            HStack {
                Button("查看旅程详情", action: onOpenDetails)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(PostcardColors.travelBlue)
                Spacer()
                Button("结束", action: onEndTravel)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(PostcardColors.stampRed)
                Button(action: onContinue) {
                    Label("继续记录", systemImage: "pencil.and.scribble")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(PostcardColors.travelBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(PostcardColors.overlayBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(StampPerforationOverlay(cornerRadius: 12, color: PostcardColors.pageBackground))
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 6)
    }
    
    private var travelDays: Int {
        return max(Calendar.current.dateComponents([.day], from: travel.startDate, to: Date()).day ?? 1, 1)
    }
    
    private var totalDays: Int {
        guard let end = travel.endDate else { return travelDays }
        return Calendar.current.dateComponents([.day], from: travel.startDate, to: end).day ?? travelDays
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        let endDate = travel.endDate ?? Calendar.current.date(byAdding: .day, value: max(totalDays - 1, 0), to: travel.startDate) ?? travel.startDate
        return "\(formatter.string(from: travel.startDate)) - \(formatter.string(from: endDate))"
    }

    private var dateStampText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: travel.startDate)
    }

    private var routeText: String {
        return "\(travel.destination) → 阳朔 → 龙脊 → 北海"
    }
}

struct TravelSwitcherCard: View {
    let travels: [Travel]
    let onSelectTravel: (Travel) -> Void
    let onOpenDetails: (Travel) -> Void
    let onDeleteTravel: (Travel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PostalSectionHeader(title: "切换旅程", trailing: "查看全部")

            ForEach(travels) { travel in
                switcherRow(
                    title: travel.title,
                    dateText: summaryText(for: travel),
                    routeText: routeText(for: travel),
                    status: statusLabel(for: travel),
                    serialNo: serialNo(for: travel),
                    stampDate: shortDate(for: travel.endDate ?? travel.startDate),
                    theme: travel.status == .completed ? .mountain : .oldTown,
                    stampColor: travel.status == .completed ? PostcardColors.stampRed : PostcardColors.travelBlue,
                    selectAction: { onSelectTravel(travel) },
                    openAction: { onOpenDetails(travel) },
                    deleteAction: { onDeleteTravel(travel) }
                )
            }
        }
        .padding(.vertical, 4)
    }

    private func switcherRow(
        title: String,
        dateText: String,
        routeText: String,
        status: String,
        serialNo: String,
        stampDate: String,
        theme: PostalImageTheme,
        stampColor: Color,
        selectAction: @escaping () -> Void,
        openAction: (() -> Void)? = nil,
        deleteAction: (() -> Void)? = nil
    ) -> some View {
        PostalTicket(cornerRadius: 8) {
            HStack(spacing: 12) {
                VStack(spacing: 5) {
                    Text("挂号信")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(PostcardColors.pencilGray)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 42, height: 24)
                    Rectangle()
                        .fill(PostcardColors.inkBlack.opacity(0.65))
                        .frame(width: 30, height: 1)
                    ForEach(0..<5, id: \.self) { _ in
                        Rectangle()
                            .fill(PostcardColors.inkBlack.opacity(0.38))
                            .frame(width: 30, height: 1)
                    }
                }
                .frame(width: 44)

                PostalSampleImage(theme: theme, cornerRadius: 6)
                    .frame(width: 72, height: 62)

                Button(action: selectAction) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 21, weight: .heavy, design: .serif))
                            .foregroundColor(PostcardColors.inkBlack)
                        Text(dateText)
                            .font(.caption)
                            .foregroundColor(PostcardColors.inkBlack)
                        Text(routeText)
                            .font(.caption)
                            .foregroundColor(PostcardColors.pencilGray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)

                VStack(spacing: 8) {
                    PostalStampSeal(title: title.replacingOccurrences(of: "之旅", with: "局"), date: stampDate, color: stampColor.opacity(0.78))
                        .scaleEffect(0.64)
                        .frame(width: 54, height: 54)
                    Text(status)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(stampColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(stampColor, lineWidth: 1))
                    Text(serialNo)
                        .font(.caption)
                        .foregroundColor(PostcardColors.pencilGray)
                }

                VStack(spacing: 8) {
                    Button(role: .destructive, action: { deleteAction?() }) {
                        Image(systemName: "trash")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(PostcardColors.stampRed)
                            .frame(width: 28, height: 28)
                            .background(PostcardColors.paperBeige)
                            .clipShape(Circle())
                    }

                    Button(action: { openAction?() }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(PostcardColors.travelBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    private func statusLabel(for travel: Travel) -> String {
        switch travel.status {
        case .ongoing: return "进行中"
        case .completed: return "已结束"
        case .planned: return "待出发"
        }
    }

    private func summaryText(for travel: Travel) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let start = formatter.string(from: travel.startDate)
        let end = formatter.string(from: travel.endDate ?? travel.startDate)
        return "\(start) - \(end)"
    }

    private func routeText(for travel: Travel) -> String {
        switch travel.destination {
        case "云南":
            return "昆明 → 大理 → 丽江 → 香格里拉"
        case "上海":
            return "外滩 → 南京路 → 迪士尼"
        case "川西":
            return "成都 → 四姑娘山 → 稻城亚丁"
        default:
            return "\(travel.destination) → 邮局 → 旅途"
        }
    }

    private func serialNo(for travel: Travel) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return "NO. \(formatter.string(from: travel.startDate))\(abs(travel.title.hashValue) % 90 + 10)"
    }

    private func shortDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

// MARK: - Empty Travel Card
struct EmptyTravelCard: View {
    let onCreateTravel: () -> Void

    var body: some View {
        PostalEmptyState(
            title: "还没有旅行邮票",
            message: "创建第一段旅程后，这里会生成专属旅行邮局封面和明信片记录。",
            icon: "postcard",
            actionTitle: "创建新旅行",
            action: onCreateTravel
        )
        .accessibilityIdentifier("CreateTravelButton")
    }
}

// MARK: - Map Preview
struct MapPreviewCard: View {
    let cityCount: Int
    let postcardCount: Int
    var stampCount: Int? = nil

    var body: some View {
        PostalStatsTicket(
            items: [
                PostalStatItem(icon: "postcard", title: "寄出明信片", value: "\(postcardCount)", suffix: "张"),
                PostalStatItem(icon: "seal", title: "收集邮票", value: "\(stampCount ?? max(postcardCount / 2, 0))", suffix: "枚"),
                PostalStatItem(icon: "signpost.right", title: "到访城市", value: "\(cityCount)", suffix: "座")
            ],
            compact: false
        )
        .overlay(alignment: .topLeading) {
            Text("邮局小结")
                .font(.system(size: 21, weight: .heavy, design: .serif))
                .foregroundColor(PostcardColors.travelBlue)
                .padding(.leading, 18)
                .padding(.top, -32)
        }
    }

    private func summaryColumn(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(PostcardColors.travelBlue)
            Text(title)
                .font(.caption)
                .foregroundColor(PostcardColors.pencilGray)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(PostcardColors.travelBlue)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CreateTravelView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var destination = ""
    @State private var startDate = Date()

    let onSave: (String, String, Date) -> Void

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("旅行标题", text: $title)
                    .accessibilityIdentifier("TravelTitleField")
                TextField("目的地", text: $destination)
                    .accessibilityIdentifier("TravelDestinationField")
                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
            }
            .navigationTitle("创建新旅行")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(
                            title.trimmingCharacters(in: .whitespacesAndNewlines),
                            destination.trimmingCharacters(in: .whitespacesAndNewlines),
                            startDate
                        )
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                    .accessibilityIdentifier("SaveTravelButton")
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
