import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Query(sort: \Travel.startDate, order: .reverse) private var travels: [Travel]
    @Query(sort: \Postcard.recordedAt, order: .reverse) private var postcards: [Postcard]
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapStyle: MapStyle = .standard
    @State private var selectedTravelID: UUID?

    private var travelScopedPostcards: [Postcard] {
        guard let selectedTravelID else {
            return postcards
        }
        return postcards.filter { $0.travelID == selectedTravelID }
    }

    private var cities: [CityAnnotation] {
        let locationPostcards = travelScopedPostcards.compactMap { postcard -> (String, CLLocationCoordinate2D, String?)? in
            guard
                let latitude = postcard.locationLat,
                let longitude = postcard.locationLng
            else {
                return nil
            }

            let title = postcard.city ?? postcard.locationName
            let country = postcard.country
            return (title, CLLocationCoordinate2D(latitude: latitude, longitude: longitude), country)
        }

        let grouped = Dictionary(grouping: locationPostcards, by: \.0)

        return grouped.keys.sorted().compactMap { key in
            guard let items = grouped[key], let first = items.first else { return nil }
            return CityAnnotation(
                name: key,
                coordinate: first.1,
                count: items.count,
                country: first.2
            )
        }
    }

    private var countryCount: Int {
        Set(cities.compactMap(\.country).filter { !$0.isEmpty }).count
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if cities.isEmpty {
                    ScrollView {
                        VStack(spacing: 18) {
                            PostalPageHeader(
                                title: "旅行邮局",
                                subtitle: "邮路网络 / 本次旅程投递图",
                                leadingSymbol: "point.topleft.down.curvedto.point.bottomright.up",
                                trailingLabel: "图层"
                            )
                            .padding(.horizontal)

                            PostalEmptyState(
                                title: selectedTravelID == nil ? "还没有地图足迹" : "这个旅程还没有地图足迹",
                                message: selectedTravelID == nil ? "保存带地点信息的明信片后，邮路会在地图上自动连成投递路线。" : "换一个旅程，或者继续为这次旅行记录带地点信息的明信片。",
                                icon: "map"
                            )
                            .padding(.horizontal)

                            emptyRoutePreview
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 16)
                    }
                    .background(PostalTextureBackground())
                } else {
                    Map(position: $cameraPosition) {
                        if cities.count > 1 {
                            MapPolyline(coordinates: cities.map(\.coordinate))
                                .stroke(PostcardColors.travelBlue, style: StrokeStyle(lineWidth: 3, dash: [8, 8]))
                        }
                        ForEach(cities) { city in
                            Annotation(city.name, coordinate: city.coordinate) {
                                MapStampMarker(count: city.count)
                            }
                        }
                    }
                    .mapStyle(mapStyle)
                    .mapControls {
                        MapCompass()
                        MapScaleView()
                        MapUserLocationButton()
                    }

                    VStack(spacing: 12) {
                        PostalPageHeader(
                            title: "旅行邮局",
                            subtitle: "邮路网络 / 本次旅程投递图",
                            leadingSymbol: "point.topleft.down.curvedto.point.bottomright.up",
                            trailingLabel: "图层"
                        )
                        .padding(.horizontal)

                        TravelFilterChips(
                            travels: travels,
                            selectedTravelID: $selectedTravelID,
                            allTitle: "全部足迹",
                            selectedColor: PostcardColors.travelBlue,
                            unselectedBackground: Color.white.opacity(0.88)
                        )
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.top, 8)

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                mapToolButton(icon: "square.3.layers.3d", title: "图层")
                                mapToolButton(icon: "location", title: "定位")
                            }
                            .padding(.trailing, 18)
                            Spacer().frame(height: 250)
                        }
                        Spacer()
                    }
                    
                    // Bottom Stats Bar
                    VStack(spacing: 0) {
                        Spacer()

                        VStack(spacing: 12) {
                            PostalStatsTicket(
                                items: [
                                    PostalStatItem(icon: "building.columns", title: "点亮城市", value: "\(cities.count)", suffix: "座"),
                                    PostalStatItem(icon: "globe.asia.australia", title: "跨越国家", value: "\(countryCount)", suffix: "个"),
                                    PostalStatItem(icon: "signpost.right", title: "旅程里程", value: "\(max(cities.count, 1) * 680)", suffix: "km")
                                ],
                                compact: true
                            )

                            PostalTicket(cornerRadius: 8) {
                                HStack(spacing: 12) {
                                    Text("当前邮路")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(PostcardColors.pencilGray)
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 42)
                                    PostalSampleImage(theme: .oldTown, cornerRadius: 4)
                                        .frame(width: 72, height: 58)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(routeTitle)
                                            .font(.system(size: 20, weight: .heavy, design: .serif))
                                            .foregroundColor(PostcardColors.travelBlue)
                                            .lineLimit(1)
                                        Text("预计剩余 4 天")
                                            .font(.caption)
                                            .foregroundColor(PostcardColors.pencilGray)
                                    }
                                    Spacer()
                                    Text("进行中")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(PostcardColors.travelBlue)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(PostcardColors.travelBlue, lineWidth: 1))
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(PostcardColors.travelBlue)
                                }
                                .padding(14)
                            }
                        }
                        .padding()
                    }
                }
            }
#if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: mapToolbarPlacement) {
                    Menu {
                        Button("标准地图") { mapStyle = .standard }
                        Button("卫星地图") { mapStyle = .imagery }
                        Button("混合地图") { mapStyle = .hybrid }
                    } label: {
                        Image(systemName: "map")
                            .foregroundColor(PostcardColors.travelBlue)
                    }
                }
            }
        }
    }

    private var emptyRoutePreview: some View {
        PostalTicket(cornerRadius: 8) {
            VStack(spacing: 14) {
                ZStack {
                    PostalSampleImage(theme: .coast, cornerRadius: 6)
                        .frame(height: 240)
                        .opacity(0.78)
                    routePreviewOverlay
                        .padding(28)
                    PostalStampSeal(title: "投递中", date: "ON THE WAY")
                        .scaleEffect(0.82)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(18)
                }

                PostalStatsTicket(
                    items: [
                        PostalStatItem(icon: "building.columns", title: "点亮城市", value: "42", suffix: "座"),
                        PostalStatItem(icon: "globe.asia.australia", title: "跨越国家", value: "3", suffix: "个"),
                        PostalStatItem(icon: "signpost.right", title: "旅程里程", value: "8,460", suffix: "km")
                    ],
                    compact: true
                )
            }
            .padding(12)
        }
        .allowsHitTesting(false)
    }

    private var routePreviewOverlay: some View {
        GeometryReader { geometry in
            let points = [
                CGPoint(x: geometry.size.width * 0.16, y: geometry.size.height * 0.68),
                CGPoint(x: geometry.size.width * 0.50, y: geometry.size.height * 0.45),
                CGPoint(x: geometry.size.width * 0.72, y: geometry.size.height * 0.28),
                CGPoint(x: geometry.size.width * 0.40, y: geometry.size.height * 0.78)
            ]

            ZStack {
                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(PostcardColors.travelBlue, style: StrokeStyle(lineWidth: 2.5, dash: [7, 6]))

                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    VStack(spacing: 4) {
                        MapStampMarker(count: 1)
                            .scaleEffect(0.72)
                        Text(["南宁", "阳朔", "龙脊", "北海"][index])
                            .font(.system(size: 18, weight: .heavy, design: .serif))
                            .foregroundColor(PostcardColors.travelBlue)
                    }
                    .position(point)
                }
            }
        }
    }

    private var routeTitle: String {
        let names = cities.prefix(4).map(\.name)
        if names.isEmpty {
            return "南宁 → 阳朔 → 龙脊 → 北海"
        }
        return names.joined(separator: " → ")
    }

    private func mapToolButton(icon: String, title: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(PostcardColors.travelBlue)
            .frame(width: 58, height: 58)
            .background(PostcardColors.overlayBackground.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var mapToolbarPlacement: ToolbarItemPlacement {
#if os(iOS)
        .topBarTrailing
#else
        .primaryAction
#endif
    }
}

// MARK: - Map Stamp Marker
struct MapStampMarker: View {
    let count: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Pulse effect
            Circle()
                .fill(PostcardColors.stampRed.opacity(0.3))
                .frame(width: isAnimating ? 50 : 20, height: isAnimating ? 50 : 20)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            
            Circle()
                .fill(PostcardColors.stampRed)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "mappin")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: PostcardColors.stampRed.opacity(0.4), radius: 6, x: 0, y: 2)
            
            if count > 1 {
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(PostcardColors.travelBlue))
                    .offset(x: 12, y: -12)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct CityAnnotation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let count: Int
    let country: String?
}

#Preview {
    MapView()
        .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
