import { DataManager } from '../model/DataManager';
import { Travel, TravelStatus } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import { PostalStampSeal, StampPerforation, WaveLine, AirmailStripe } from '../components/PostalComponents';

interface UserStats {
  cities: number;
  postcards: number;
  countries: number;
  joinedDays: number;
  travelCount: number;
  favoriteCount: number;
}

@Component
export struct ProfileView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];

  aboutToAppear() {
    this.refreshData();
    DataManager.addListener(this.onDataChanged.bind(this));
  }

  aboutToDisappear() {
    DataManager.removeListener(this.onDataChanged.bind(this));
  }

  onPageShow() {
    this.refreshData();
  }

  private refreshData() {
    this.travels = DataManager.sortedTravels;
    this.postcards = DataManager.sortedPostcards;
  }

  private onDataChanged() {
    this.refreshData();
  }

  private getStats(): UserStats {
    const cityCount = new Set(this.postcards.map(p => p.city).filter(c => c)).size;
    const countryCount = new Set(this.postcards.map(p => p.country).filter(c => c)).size;
    const firstDate = this.travels.map(t => t.createdAt).concat(this.postcards.map(p => p.createdAt)).sort((a, b) => a - b)[0];
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

  private getCurrentTravel(): Travel | undefined {
    const current = this.travels.find(t => t.isCurrent);
    return current || this.travels.find(t => t.status === TravelStatus.ONGOING);
  }

  private getProfileTitle(): string {
    const current = this.getCurrentTravel();
    if (current) {
      return `${current.destination}旅行者`;
    }
    return this.postcards.length === 0 ? '新旅行者' : '旅行者';
  }

  private getBookCount(): number {
    const years = new Set(this.postcards.map(p => new Date(p.recordedAt).getFullYear()));
    return this.postcards.length === 0 ? 0 : Math.max(1, years.size);
  }

  private getUserName(): string {
    if (this.postcards.length > 0) {
      const city = this.postcards[0].city || this.postcards[0].locationName;
      return `${city.substring(0, 2)}邮差`;
    }
    return '新邮差';
  }

  private getMailboxNo(): string {
    const days = this.getStats().joinedDays;
    return `No. ${((days * 7 + 13) % 999999).toString().padStart(6, '0')}`;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
          .padding({ top: 8 })
          .width('100%')
          .textAlign(TextAlign.Center)

        Stack({ alignContent: Alignment.TopCenter }) {
          Stack()
            .width('100%')
            .height(240)
            .backgroundColor('#2E7D58')
            .borderRadius(24)
            .border({ width: 8, color: '#2E6E49', radius: 24 })

          Column({ space: 10 }) {
            Column({ space: 2 }) {
              Text('远方邮政')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontFamily('serif')
                .fontColor(Color.White)
              Text('CHINA POST')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .padding({ top: 20 })

            Stack() {
              Text('👤')
                .fontSize(40)
            }
            .width(88)
            .height(88)
            .backgroundColor(Color.White)
            .borderRadius(44)

            Text(this.userName)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Row({ space: 4 }) {
              Text('🌏')
                .fontSize(14)
              Text(this.getProfileTitle())
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .padding({ left: 14, right: 14, top: 4, bottom: 4 })
            .border({ width: 1, color: 'rgba(216,191,125,0.75)', radius: 999 })

            Text(`已加入 ${this.getStats().joinedDays} 天`)
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.85)')

            Row() {
              Column({ space: 2 }) {
                Text('个人邮箱')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#8B6914')
                Text(this.getMailboxNo())
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#6B4423')
              }
              .padding({ left: 20, right: 20, top: 8, bottom: 8 })
              .backgroundColor('#DFC28B')
              .borderRadius(8)
              .border({ width: 1, color: '#B68F57', radius: 8 })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
        .padding({ left: 16, right: 16 })

        Column({ space: 0 }) {
          Row({ space: 0 }) {
            this.StatItem('🧳', '总旅程', `${this.getStats().travelCount}`, '次')
            Divider().vertical(true).height(60).color(Colors.lineSepia).margin({ top: 10 })
            this.StatItem('📮', '明信片', `${this.getStats().postcards}`, '枚')
            Divider().vertical(true).height(60).color(Colors.lineSepia).margin({ top: 10 })
            this.StatItem('🏷', '邮票', `${this.getStats().favoriteCount}`, '枚')
            Divider().vertical(true).height(60).color(Colors.lineSepia).margin({ top: 10 })
            this.StatItem('📍', '城市', `${this.getStats().cities}`, '座')
          }
          .padding({ top: 16, bottom: 16 })
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .border({ width: 1, color: Colors.paperBeige, radius: 16 })

          AirmailStripe()
            .height(6)
            .width('95%')
            .borderRadius(3)
            .margin({ top: -3 })
        }
        .padding({ left: 16, right: 16 })

        if (this.getCurrentTravel()) {
          Stack({ alignContent: Alignment.TopStart }) {
            Stack()
              .width('100%')
              .height(140)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .border({ width: 1, color: Colors.postalMint, radius: 16 })

            Column({ space: 10 }) {
              Row({ space: 12 }) {
                Text('🚀')
                  .fontSize(28)
                  .width(40)
                  .height(40)
                  .backgroundColor('#F0F9FF')
                  .borderRadius(12)
                  .textAlign(TextAlign.Center)

                Column({ space: 4 }) {
                  Text('当前旅程')
                    .fontSize(12)
                    .fontColor('#666666')
                  Text(`${this.getCurrentTravel()!.title}`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                  Text(`${this.getCurrentTravel()!.destination} · 第 ${this.getTravelDays()} 天`)
                    .fontSize(13)
                    .fontColor('#888888')
                }
              }

              Row({ space: 8 }) {
                Stack()
                  .width(6)
                  .height(6)
                  .backgroundColor(Colors.forestGreen)
                  .borderRadius(3)
                Text('进行中')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.forestGreen)
                Blank()
                Text(`预计 ${Math.max(0, 7 - this.getTravelDays())} 天后完成`)
                  .fontSize(12)
                  .fontColor('#999999')
              }
            }
            .padding({ left: 16, right: 16, top: 16 })
          }
          .padding({ left: 16, right: 16 })
        }

        Column({ space: 0 }) {
          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text('会员中心')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              Text('尊享专属权益')
                .fontSize(12)
                .fontColor('#999999')
            }
            .layoutWeight(1)

            Text('›')
              .fontSize(18)
              .fontColor('#CCCCCC')
          }
          .padding({ left: 16, right: 16, top: 16 })

          Divider().color(Colors.lineSepia)

          SettingRow({ icon: '📖', title: '我的邮册', subtitle: '珍藏旅途中的明信片', badge: `${this.getBookCount()}本` })
          Divider().color(Colors.lineSepia)
          SettingRow({ icon: '✈', title: '寄出记录', subtitle: '查看明信片寄送状态', badge: `${this.getStats().postcards}枚` })
          Divider().color(Colors.lineSepia)
          SettingRow({ icon: '📍', title: '地址簿', subtitle: '管理收信人地址', badge: `${this.getStats().cities}个` })
          Divider().color(Colors.lineSepia)
          SettingRow({ icon: '👑', title: '会员权益', subtitle: '专属权益与服务', badge: '' })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .border({ width: 1, color: Colors.paperBeige, radius: 16 })
        .padding({ left: 16, right: 16 })
      }
      .padding({ top: 16, bottom: 100 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }

  private getTravelDays(): number {
    if (!this.getCurrentTravel()) return 1;
    return Math.max(Math.floor((Date.now() - this.getCurrentTravel()!.startDate) / (1000 * 60 * 60 * 24)), 1);
  }

  @Builder
  StatItem(icon: string, title: string, value: string, unit: string) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(16)
      Text(title)
        .fontSize(12)
        .fontColor('#666666')
      Row({ space: 1 }) {
        Text(value)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
        Text(unit)
          .fontSize(12)
          .fontColor('#888888')
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
struct SettingRow {
  icon: string = '';
  title: string = '';
  subtitle: string = '';
  badge: string = '';

  build() {
    Button() {
      Row({ space: 12 }) {
        Text(this.icon)
          .fontSize(18)

        Column({ space: 2 }) {
          Text(this.title)
            .fontSize(16)
          Text(this.subtitle)
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.badge.length > 0) {
          Text(this.badge)
            .fontSize(12)
            .fontColor('#666666')
        }

        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
      .padding({ top: 14, bottom: 14 })
      .width('100%')
    }
    .type(ButtonType.Normal)
    .backgroundColor('transparent')
    .width('100%')
  }
}
