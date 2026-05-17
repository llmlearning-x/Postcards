import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \Travel.startDate, order: .reverse) private var travels: [Travel]
    @Query(sort: \Postcard.recordedAt, order: .reverse) private var postcards: [Postcard]

    private var stats: UserStatsSummary {
        let cityCount = Set(postcards.compactMap(\.city).filter { !$0.isEmpty }).count
        let countryCount = Set(postcards.compactMap(\.country).filter { !$0.isEmpty }).count
        let firstJoinDate = travels.map(\.createdAt).min() ?? postcards.map(\.createdAt).min() ?? Date()
        let joinedDays = max(Calendar.current.dateComponents([.day], from: firstJoinDate, to: Date()).day ?? 0, 1)

        return UserStatsSummary(
            cities: cityCount,
            postcards: postcards.count,
            countries: countryCount,
            joinedDays: joinedDays,
            travelCount: travels.count,
            favoriteCount: postcards.filter(\.isFavorite).count
        )
    }

    private var currentTravel: Travel? {
        travels.first { $0.isCurrent } ?? travels.first { $0.status == .ongoing }
    }

    private var bookCount: Int {
        max(Set(postcards.map { Calendar.current.component(.year, from: $0.recordedAt) }).count, postcards.isEmpty ? 0 : 1)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PostalTextureBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        Text("我的")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(PostcardColors.travelBlue)
                            .padding(.top, 6)

                        MailboxHeroCard(
                            profileTitle: profileTitle,
                            joinedDays: stats.joinedDays
                        )
                        .padding(.horizontal, 16)

                        MailStatsTicket(
                            stats: stats,
                            bookCount: bookCount
                        )
                        .padding(.horizontal, 16)

                        if let currentTravel {
                            MailCurrentTravelCard(travel: currentTravel)
                                .padding(.horizontal, 16)
                        }

                        MemberCenterCard(
                            stats: stats,
                            bookCount: bookCount
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }
            }
#if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
#endif
        }
    }

    private var profileTitle: String {
        if let currentTravel {
            return "\(currentTravel.destination)旅行者"
        }
        return stats.postcards == 0 ? "新旅行者" : "旅行者"
    }
}

struct UserStatsSummary {
    let cities: Int
    let postcards: Int
    let countries: Int
    let joinedDays: Int
    let travelCount: Int
    let favoriteCount: Int
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let trailingText: String?
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(PostcardColors.inkBlack)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(PostcardColors.pencilGray)
                }
                
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let trailingText {
                        Text(trailingText)
                            .font(.caption)
                            .foregroundColor(PostcardColors.pencilGray)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PostcardColors.stampGray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

struct MailboxHeroCard: View {
    let profileTitle: String
    let joinedDays: Int

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [PostcardColors.travelBlue, Color(hex: "#1F5A3A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 226)
                .overlay(alignment: .top) {
                    VStack(spacing: 0) {
                        Text("旅行邮箱")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                        Text("TRAVEL MAIL")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(PostcardColors.dawnYellow)
                    .padding(.top, 18)
                }
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.6))
                        .frame(height: 20)
                        .padding(.horizontal, 34)
                        .padding(.top, 54)
                }
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "circlebadge")
                        .font(.largeTitle)
                        .foregroundColor(Color.white.opacity(0.08))
                        .padding(18)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "#2E6E49"), lineWidth: 10)
                        .padding(2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Spacer()
                    PostalWaveLine()
                        .frame(width: 82, height: 22)
                        .foregroundColor(PostcardColors.dawnYellow)
                        .padding(.trailing, 28)
                        .padding(.top, 76)
                }

                HStack(spacing: 14) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 62, height: 62)
                                .foregroundColor(PostcardColors.travelBlue)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("吴旺旺")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Label("旅行收藏家", systemImage: "globe.asia.australia")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color(hex: "#E7DFC0"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .overlay(Capsule().stroke(PostcardColors.dawnYellow.opacity(0.75), lineWidth: 1))
                        Text("已加入 \(joinedDays) 天")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.82))
                    }
                }
                .padding(.leading, 22)

                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("个人邮箱")
                            .font(.subheadline.bold())
                            .foregroundColor(Color(hex: "#6D5121"))
                        Text("No. 000428")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#8A6E3D"))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#DFC28B"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#B68F57"), lineWidth: 1)
                    )
                    .padding(.trailing, 28)
                }
            }
        }
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
    }
}

struct MailStatsTicket: View {
    let stats: UserStatsSummary
    let bookCount: Int

    var body: some View {
        HStack(spacing: 0) {
            ticketItem(icon: "suitcase", title: "总旅程", value: "\(stats.travelCount)", suffix: "次")
            ticketDivider
            ticketItem(icon: "postcard", title: "寄出明信片", value: "\(stats.postcards)", suffix: "枚")
            ticketDivider
            ticketItem(icon: "seal", title: "收集邮票", value: "\(stats.favoriteCount)", suffix: "枚")
            ticketDivider
            ticketItem(icon: "signpost.right", title: "到访城市", value: "\(stats.cities)", suffix: "座")
        }
        .padding(.vertical, 18)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(PostcardColors.paperBeige, lineWidth: 1)
        )
        .overlay(
            VStack {
                Spacer()
                AirmailStripe()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
            }
        )
    }

    private var ticketDivider: some View {
        Rectangle()
            .fill(PostcardColors.postalMint)
            .frame(width: 1, height: 52)
            .padding(.top, 4)
    }

    private func ticketItem(icon: String, title: String, value: String, suffix: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline.bold())
                .foregroundColor(PostcardColors.travelBlue)
            Text(title)
                .font(.caption)
                .foregroundColor(PostcardColors.pencilGray)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(PostcardColors.travelBlue)
                Text(suffix)
                    .font(.caption)
                    .foregroundColor(PostcardColors.pencilGray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MailCurrentTravelCard: View {
    let travel: Travel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PostalSectionHeader(title: "当前旅程", trailing: "预计 \(max(6 - min(travelDays, 6), 0)) 天后送达")
            }

            HStack(spacing: 14) {
                TravelCoverImage(imagePath: travel.coverImageURL, cornerRadius: 14)
                    .frame(width: 108, height: 88)
                    .overlay(
                        StampPerforationOverlay(
                            cornerRadius: 14,
                            color: PostcardColors.pageBackground
                        )
                    )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("进行中", systemImage: "circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(PostcardColors.forestGreen)
                        Spacer()
                    }
                    Text("\(travel.title) · 第 \(travelDays) 天")
                        .font(.title3.bold())
                        .foregroundColor(PostcardColors.travelBlue)
                    Text(travelRouteText)
                        .font(.subheadline)
                        .foregroundColor(PostcardColors.pencilGray)
                    HStack {
                        Image(systemName: "truck.box")
                            .foregroundColor(PostcardColors.travelBlue)
                        Text("明信片寄送中，请期待收信")
                            .font(.caption)
                            .foregroundColor(PostcardColors.pencilGray)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(PostcardColors.postalMint, lineWidth: 1)
        )
    }

    private var travelDays: Int {
        max(Calendar.current.dateComponents([.day], from: travel.startDate, to: Date()).day ?? 0, 1)
    }

    private var travelRouteText: String {
        let route = [travel.destination, "邮局", "旅途"]
        return route.joined(separator: " → ")
    }
}

struct MemberCenterCard: View {
    let stats: UserStatsSummary
    let bookCount: Int

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 14) {
                Text("会员\n中心")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#7F6C4B"))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 56)
            .frame(maxHeight: .infinity)
            .background(Color(hex: "#F0E7D4"))

            VStack(spacing: 0) {
                SettingRow(
                    icon: "book.closed.fill",
                    title: "我的邮册",
                    subtitle: "珍藏旅途中的每一张明信片",
                    color: PostcardColors.travelBlue,
                    trailingText: "共 \(bookCount) 本"
                )
                Divider()
                SettingRow(
                    icon: "paperplane.fill",
                    title: "寄出记录",
                    subtitle: "查看所有寄出的明信片状态",
                    color: PostcardColors.travelBlue,
                    trailingText: "\(stats.postcards) 枚"
                )
                Divider()
                SettingRow(
                    icon: "map.fill",
                    title: "地址簿",
                    subtitle: "管理收信人地址，寄送更便捷",
                    color: PostcardColors.forestGreen,
                    trailingText: "\(stats.cities) 个地址"
                )
                Divider()
                SettingRow(
                    icon: "crown.fill",
                    title: "会员权益",
                    subtitle: "专属权益与邮政会员服务",
                    color: PostcardColors.dawnYellow,
                    trailingText: "查看权益"
                )
            }
        }
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(PostcardColors.paperBeige, lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Travel.self, Postcard.self], inMemory: true)
}
