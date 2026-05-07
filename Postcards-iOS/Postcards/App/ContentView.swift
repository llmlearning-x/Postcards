import SwiftUI

struct ContentView: View {
    @State private var selectedTab = Tab.home
    
    enum Tab: Hashable, CaseIterable {
        case home, timeline, map, collection, profile

        var title: String {
            switch self {
            case .home: return "首页"
            case .timeline: return "时间轴"
            case .map: return "地图"
            case .collection: return "收藏"
            case .profile: return "我的"
            }
        }

        var icon: String {
            switch self {
            case .home: return "menucard"
            case .timeline: return "list.bullet.rectangle"
            case .map: return "map"
            case .collection: return "circle.grid.2x2"
            case .profile: return "doc.text"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "menucard.fill"
            case .timeline: return "list.bullet.rectangle.fill"
            case .map: return "map.fill"
            case .collection: return "circle.grid.2x2.fill"
            case .profile: return "doc.text.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PostalTextureBackground()

            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .timeline:
                    TimelineView()
                case .map:
                    MapView()
                case .collection:
                    CollectionView()
                case .profile:
                    ProfileView()
                }
            }
            .safeAreaPadding(.bottom, 96)

            PostalTabBar(selectedTab: $selectedTab)
        }
        .tint(PostcardColors.travelBlue)
        .background(PostcardColors.pageBackground)
    }
}

private struct PostalTabBar: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 25, weight: .semibold))
                            .frame(width: 34, height: 30)
                            .foregroundColor(selectedTab == tab ? .white : Color(hex: "#555A56"))
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(selectedTab == tab ? PostcardColors.travelBlue : Color.clear)
                            )
                        Text(tab.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? PostcardColors.travelBlue : Color(hex: "#4D4D4D"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityIdentifier("Tab-\(tab.title)")
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .background(PostcardColors.overlayBackground.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(PostcardColors.lineSepia.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
