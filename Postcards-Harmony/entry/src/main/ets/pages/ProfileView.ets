import { DataManager } from '../model/DataManager';
import { Travel, TravelStatus } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import { PostalStampSeal, StampPerforation, WaveLine, AirmailStripe } from '../components/PostalComponents';

@Component
export struct ProfileView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];

  aboutToAppear() {
    this.refreshData();
  }

  onPageShow() {
    this.refreshData();
  }

  private refreshData() {
    this.travels = DataManager.sortedTravels;
    this.postcards = DataManager.sortedPostcards;
  }

  private get stats(): { cities: number; postcards: number; countries: number; joinedDays: number; travelCount: number; favoriteCount: number } {
    const cityCount = new Set(this.postcards.map(p => p.city).filter(c => c)).size;
    const countryCount = new Set(this.postcards.map(p => p.country).filter(c => c)).size;
    const firstDate = [...this.travels.map(t => t.createdAt), ...this.postcards.map(p => p.createdAt)].sort((a, b) => a - b)[0];
    const joinedDays = firstDate ? Math.max(1, Math.floor((Date.now() - firstDate) / (1000 * 60 * 60 * 24))) : 1;
    return {
      cities: cityCount,
      postcards: this.postcards.length,
      countries: countryCount,
      joinedDays,
      travelCount: this.travels.length,
      favoriteCount: this.postcards.filter(p => p.isFavorite).length
    };
  }

  private get currentTravel(): Travel | undefined {
    return this.travels.find(t => t.isCurrent) ?? this.travels.find(t => t.status === TravelStatus.ONGOING);
  }

  private get profileTitle(): string {
    if (this.currentTravel) {
      return `${this.currentTravel.destination}旅行者`;
    }
    return this.postcards.length === 0 ? '新旅行者' : '旅行者';
  }

  private get bookCount(): number {
    const years = new Set(this.postcards.map(p => new Date(p.recordedAt).getFullYear()));
    return this.postcards.length === 0 ? 0 : Math.max(1, years.size);
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
          .fontColor(Colors.travelBlue)
          .padding({ top: 6 })

        MailboxHeroCard({
          profileTitle: this.profileTitle,
          joinedDays: this.stats.joinedDays
        })
        .padding({ left: 16, right: 16 })

        MailStatsTicket({ stats: this.stats })
          .padding({ left: 16, right: 16 })

        if (this.currentTravel) {
          MailCurrentTravelCard({ travel: this.currentTravel })
            .padding({ left: 16, right: 16 })
        }

        MemberCenterCard({ stats: this.stats, bookCount: this.bookCount })
          .padding({ left: 16, right: 16 })
      }
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }
}

@Component
struct MailboxHeroCard {
  profileTitle: string = '';
  joinedDays: number = 0;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      LinearGradient({ angle: 135, colors: [Colors.travelBlue, '#1F5A3A'] })
        .width('100%')
        .height(226)
        .borderRadius(24)
        .border({ width: 10, color: '#2E6E49', radius: 24 })
        .border({ width: 1, color: 'rgba(255,255,255,0.16)', radius: 24 })

      // Top CHINA POST
      Column({ space: 0 }) {
        Text('中国邮政')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
        Text('CHINA POST')
          .fontSize(12)
          .fontWeight(FontWeight.SemiBold)
      }
      .fontColor(Colors.dawnYellow)
      .padding({ top: 18 })
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // Top dark bar
      Row()
        .width('100%')
        .height(20)
        .backgroundColor('rgba(0,0,0,0.6)')
        .borderRadius(6)
        .margin({ left: 34, right: 34, top: 54 })
        .position({ y: 0 })

      // Bottom left decoration
      Text('◎')
        .fontSize(32)
        .fontColor('rgba(255,255,255,0.08)')
        .padding(18)
        .position({ x: 0, y: '100%' })
        .translate({ y: -60 })

      // Content
      Column({ space: 14 }) {
        Row() {
          Blank()
          WaveLine()
            .width(82)
            .height(22)
            .fontColor(Colors.dawnYellow)
            .padding({ right: 28, top: 76 })
        }
        .width('100%')

        Row({ space: 14 }) {
          Circle()
            .width(72)
            .height(72)
            .fill(Color.White)
            .overlay(
              Text('👤')
                .fontSize(40)
                .fontColor(Colors.travelBlue)
            )

          Column({ space: 6 }) {
            Text('吴旺旺')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Row({ space: 4 }) {
              Text('🌏')
                .fontSize(12)
              Text('旅行收藏家')
                .fontSize(12)
                .fontWeight(FontWeight.SemiBold)
                .fontColor('#E7DFC0')
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .border({ width: 1, color: 'rgba(216,191,125,0.75)', radius: 999 })

            Text(`已加入 ${this.joinedDays} 天`)
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.82)')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 22 })

        Row() {
          Blank()
          Column({ space: 2 }) {
            Text('个人邮箱')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#6D5121')
            Text('No. 000428')
              .fontSize(12)
              .fontColor('#8A6E3D')
          }
          .padding({ left: 18, right: 18, top: 12, bottom: 12 })
          .backgroundColor('#DFC28B')
          .borderRadius(10)
          .border({ width: 1, color: '#B68F57', radius: 10 })
          .padding({ right: 28 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
  }
}

@Component
struct MailStatsTicket {
  stats: { cities: number; postcards: number; countries: number; joinedDays: number; travelCount: number; favoriteCount: number } = {
    cities: 0, postcards: 0, countries: 0, joinedDays: 0, travelCount: 0, favoriteCount: 0
  };

  build() {
    Column() {
      Row({ space: 0 }) {
        this.TicketItem('🧳', '总旅程', `${this.stats.travelCount}`, '次')
        this.TicketDivider()
        this.TicketItem('📮', '寄出明信片', `${this.stats.postcards}`, '枚')
        this.TicketDivider()
        this.TicketItem('🏷', '收集邮票', `${this.stats.favoriteCount}`, '枚')
        this.TicketDivider()
        this.TicketItem('📍', '到访城市', `${this.stats.cities}`, '座')
      }
      .padding({ top: 18, bottom: 18 })
      .width('100%')
      .backgroundColor('rgba(255,255,255,0.95)')
      .borderRadius(18)
      .border({ width: 1, color: Colors.paperBeige, radius: 18 })

      AirmailStripe()
        .height(8)
        .clip(true)
        .padding({ left: 10, right: 10, bottom: 6 })
        .position({ y: '100%' })
        .translate({ y: -14 })
    }
  }

  @Builder
  TicketItem(icon: string, title: string, value: string, suffix: string) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.travelBlue)
      Text(title)
        .fontSize(12)
        .fontColor(Colors.pencilGray)
      Row({ space: 2 }) {
        Text(value)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
          .fontColor(Colors.travelBlue)
        Text(suffix)
          .fontSize(12)
          .fontColor(Colors.pencilGray)
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  TicketDivider() {
    Divider()
      .vertical(true)
      .height(52)
      .color(Colors.postalMint)
      .margin({ top: 4 })
  }
}

@Component
struct MailCurrentTravelCard {
  @Prop travel: Travel;

  private get travelDays(): number {
    return Math.max(Math.floor((Date.now() - this.travel.startDate) / (1000 * 60 * 60 * 24)), 1);
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('当前旅程')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
          .fontColor(Colors.travelBlue)
        Blank()
        Text(`预计 ${Math.max(6 - Math.min(this.travelDays, 6), 0)} 天后送达`)
          .fontSize(12)
          .fontColor(Colors.pencilGray)
      }
      .width('100%')

      Row({ space: 14 }) {
        Stack() {
          LinearGradient({ angle: 45, colors: ['#B8DAEA', '#2E7D58'] })
            .width(108)
            .height(88)
            .borderRadius(14)
          Text('✈')
            .fontSize(28)
            .fontColor(Color.White)
            .opacity(0.5)
          StampPerforation({ cornerRadius: 14, color: Colors.pageBackground })
        }

        Column({ space: 8 }) {
          Row() {
            Row({ space: 4 }) {
              Circle()
                .width(8)
                .height(8)
                .fill(Colors.forestGreen)
              Text('进行中')
                .fontSize(12)
                .fontWeight(FontWeight.SemiBold)
                .fontColor(Colors.forestGreen)
            }
            Blank()
          }
          .width('100%')

          Text(`${this.travel.title} · 第 ${this.travelDays} 天`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.travelBlue)
          Text(`${this.travel.destination} → 邮局 → 旅途`)
            .fontSize(14)
            .fontColor(Colors.pencilGray)
          Row({ space: 6 }) {
            Text('🚚')
              .fontColor(Colors.travelBlue)
            Text('明信片寄送中，请期待收信')
              .fontSize(12)
              .fontColor(Colors.pencilGray)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
    }
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.96)')
    .borderRadius(18)
    .border({ width: 1, color: Colors.postalMint, radius: 18 })
  }
}

@Component
struct MemberCenterCard {
  stats: { cities: number; postcards: number; countries: number; joinedDays: number; travelCount: number; favoriteCount: number } = {
    cities: 0, postcards: 0, countries: 0, joinedDays: 0, travelCount: 0, favoriteCount: 0
  };
  bookCount: number = 0;

  build() {
    Row({ space: 0 }) {
      Column({ space: 14 }) {
        Text('会员\n中心')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#7F6C4B')
          .textAlign(TextAlign.Center)
      }
      .width(56)
      .height('100%')
      .backgroundColor('#F0E7D4')
      .justifyContent(FlexAlign.Center)

      Column({ space: 0 }) {
        SettingRow({ icon: '📖', title: '我的邮册', subtitle: '珍藏旅途中的每一张明信片', color: Colors.travelBlue, trailingText: `共 ${this.bookCount} 本` })
        Divider().color(Colors.lineSepia)
        SettingRow({ icon: '✈', title: '寄出记录', subtitle: '查看所有寄出的明信片状态', color: Colors.travelBlue, trailingText: `${this.stats.postcards} 枚` })
        Divider().color(Colors.lineSepia)
        SettingRow({ icon: '📍', title: '地址簿', subtitle: '管理收信人地址，寄送更便捷', color: Colors.forestGreen, trailingText: `${this.stats.cities} 个地址` })
        Divider().color(Colors.lineSepia)
        SettingRow({ icon: '👑', title: '会员权益', subtitle: '专属权益与邮政会员服务', color: Colors.dawnYellow, trailingText: '查看权益' })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .backgroundColor('rgba(255,255,255,0.96)')
    .borderRadius(18)
    .border({ width: 1, color: Colors.paperBeige, radius: 18 })
  }
}

@Component
struct SettingRow {
  icon: string = '';
  title: string = '';
  subtitle: string = '';
  color: ResourceColor = Colors.travelBlue;
  trailingText: string = '';

  build() {
    Button() {
      Row({ space: 12 }) {
        Text(this.icon)
          .fontSize(18)
          .fontColor(this.color)
          .width(28)
          .height(28)
          .textAlign(TextAlign.Center)

        Column({ space: 2 }) {
          Text(this.title)
            .fontSize(16)
            .fontColor(Colors.inkBlack)
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(Colors.pencilGray)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 4 }) {
          if (this.trailingText.length > 0) {
            Text(this.trailingText)
              .fontSize(12)
              .fontColor(Colors.pencilGray)
          }
          Text('›')
            .fontSize(12)
            .fontColor(Colors.stampGray)
        }
        .alignItems(HorizontalAlign.End)
      }
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .width('100%')
    }
    .type(ButtonType.Normal)
    .backgroundColor('transparent')
    .width('100%')
  }
}
