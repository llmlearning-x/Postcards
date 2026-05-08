import router from '@ohos.router';
import { DataManager } from '../model/DataManager';
import { Travel, TravelStatus } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import {
  PostalPageHeader,
  PostalSectionHeader,
  PostalStatsTicket,
  PostalStatItem,
  PostalEmptyState,
  PostalStampSeal,
  StampPerforation,
  WaveLine
} from '../components/PostalComponents';
import { PostcardCard } from '../components/PostcardCard';

@Component
export struct HomeView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];
  @State showCreateDialog: boolean = false;
  @State showDetailTravel: Travel | null = null;
  @State newTitle: string = '';
  @State newDestination: string = '';

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

  private get currentTravel(): Travel | undefined {
    return this.travels.find(t => t.isCurrent) ?? this.travels.find(t => t.status === TravelStatus.ONGOING);
  }

  private get otherTravels(): Travel[] {
    const current = this.currentTravel;
    return this.travels.filter(t => t.id !== current?.id);
  }

  private get uniqueCityCount(): number {
    return DataManager.uniqueCityCount;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 22 }) {
          PostalPageHeader({
            title: '旅行邮局',
            subtitle: '用明信片，记录世界',
            leadingSymbol: '✉',
            trailingLabel: '签到'
          })

          // Current Travel Card
          if (this.currentTravel) {
            CurrentTravelCard({
              travel: this.currentTravel,
              onContinue: () => this.gotoRecord(),
              onOpenDetails: (t) => { this.showDetailTravel = t; },
              onEndTravel: (t) => {
                DataManager.endTravel(t);
                this.refreshData();
              }
            })
          } else {
            EmptyTravelCard({
              onCreateTravel: () => { this.showCreateDialog = true; }
            })
          }

          // Other Travels
          if (this.otherTravels.length > 0) {
            TravelSwitcherCard({
              travels: this.otherTravels,
              onSelectTravel: (t) => {
                DataManager.setCurrentTravel(t);
                this.refreshData();
              },
              onOpenDetails: (t) => { this.showDetailTravel = t; },
              onDeleteTravel: (t) => {
                DataManager.deleteTravel(t);
                this.refreshData();
              }
            })
          }

          // Stats
          MapPreviewCard({
            cityCount: this.uniqueCityCount,
            postcardCount: this.postcards.length,
            stampCount: this.postcards.filter(p => p.isFavorite).length
          })
            .height(180)

          Blank().height(100)
        }
        .padding({ left: 16, right: 16, top: 16 })
        .width('100%')
      }
      .width('100%')
      .height('100%')

      // FAB
      Button() {
        Column({ space: 3 }) {
          Text('✉')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text('寄出')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('rgba(255,255,255,0.9)')
        }
      }
      .type(ButtonType.Normal)
      .width(66)
      .height(66)
      .borderRadius(18)
      .backgroundColor(Colors.stampRed)
      .shadow({ radius: 14, color: 'rgba(184,74,56,0.32)', offsetY: 6 })
      .margin({ right: 20, bottom: 10 })
      .onClick(() => this.gotoRecord())
    }
    .width('100%')
    .height('100%')

    // Create Travel Dialog
    if (this.showCreateDialog) {
      CreateTravelDialog({
        isShow: $showCreateDialog,
        onSave: (title, destination) => {
          DataManager.markAllTravelsAsNotCurrent();
          const travel = new Travel(title, destination, Date.now(), true);
          DataManager.addTravel(travel);
          this.refreshData();
        }
      })
    }

    // Travel Detail Overlay
    if (this.showDetailTravel) {
      TravelDetailOverlay({
        travel: this.showDetailTravel,
        onClose: () => { this.showDetailTravel = null; },
        onSetCurrent: (t) => {
          DataManager.setCurrentTravel(t);
          this.refreshData();
        },
        onEndTravel: (t) => {
          DataManager.endTravel(t);
          this.refreshData();
        },
        onDeleteTravel: (t) => {
          DataManager.deleteTravel(t);
          this.showDetailTravel = null;
          this.refreshData();
        }
      })
    }
  }

  private gotoRecord() {
    router.pushUrl({ url: 'pages/RecordPage' });
  }
}

@Component
struct CurrentTravelCard {
  @Prop travel: Travel;
  onContinue?: () => void;
  onOpenDetails?: (t: Travel) => void;
  onEndTravel?: (t: Travel) => void;

  private get travelDays(): number {
    const days = Math.floor((Date.now() - this.travel.startDate) / (1000 * 60 * 60 * 24));
    return Math.max(days, 1);
  }

  private get totalDays(): number {
    if (this.travel.endDate) {
      return Math.max(Math.floor((this.travel.endDate - this.travel.startDate) / (1000 * 60 * 60 * 24)), this.travelDays);
    }
    return this.travelDays;
  }

  private get dateRangeText(): string {
    const fmt = (ts: number) => {
      const d = new Date(ts);
      return `${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
    };
    const end = this.travel.endDate ?? (this.travel.startDate + Math.max(this.totalDays - 1, 0) * 24 * 60 * 60 * 1000);
    return `${fmt(this.travel.startDate)} - ${fmt(end)}`;
  }

  private get dateStampText(): string {
    const d = new Date(this.travel.startDate);
    return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 0 }) {
        // Left postal stripe
        Stack({ alignContent: Alignment.TopStart }) {
          LinearGradient({ angle: 135, colors: [Colors.travelBlue, '#0B3E32'] })
            .width(98)
            .height('100%')

          Column({ space: 14 }) {
            Column({ space: 1 }) {
              Text('中国邮政')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontFamily('serif')
              Text('CHINA POST')
                .fontSize(7)
                .fontWeight(FontWeight.Medium)
            }
            .width(74)
            .height(74)
            .rotate({ angle: -9 })
            .border({ width: 1.5, color: Colors.stampRed, radius: 37 })
            .fontColor(Colors.stampRed)
            .backgroundColor('rgba(255,255,255,0.94)')

            Blank()

            Text('TRAVEL\nPOST\nOFFICE')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontFamily('serif')
              .fontColor(Colors.dawnYellow)

            Blank()

            Text('中国邮政\n出品')
              .fontSize(12)
              .fontColor('rgba(216,191,125,0.85)')
              .padding(8)
              .border({ width: 1, color: 'rgba(216,191,125,0.7)', radius: 3 })
          }
          .padding(14)
          .width(98)
          .alignItems(HorizontalAlign.Start)
        }

        // Right content
        Stack({ alignContent: Alignment.BottomStart }) {
          LinearGradient({ angle: 180, colors: ['rgba(255,255,255,0.48)', 'rgba(255,255,255,0.08)', 'rgba(0,0,0,0.18)'] })
            .width('100%')
            .height('100%')

          Column({ space: 8 }) {
            Text(this.travel.title)
              .fontSize(38)
              .fontWeight(FontWeight.Heavy)
              .fontFamily('serif')
              .fontColor(Colors.travelBlue)
              .shadow({ radius: 2, color: 'rgba(255,255,255,0.7)' })

            Row({ space: 8 }) {
              Text('第')
                .fontSize(22)
                .fontWeight(FontWeight.SemiBold)
                .fontFamily('serif')
                .fontColor(Colors.travelBlue)
              Text(`${this.travelDays}`)
                .fontSize(30)
                .fontWeight(FontWeight.Heavy)
                .fontFamily('serif')
                .fontColor(Colors.stampRed)
              Text('天')
                .fontSize(22)
                .fontWeight(FontWeight.SemiBold)
                .fontFamily('serif')
                .fontColor(Colors.travelBlue)
            }
            .alignItems(VerticalAlign.Bottom)

            Row({ space: 4 }) {
              Text('进行中')
                .fontSize(14)
                .fontWeight(FontWeight.SemiBold)
                .fontColor(Colors.travelBlue)
            }
          }
          .padding(22)
          .alignItems(HorizontalAlign.Start)

          PostalStampSeal({ title: '旅行邮局', date: this.dateStampText })
            .translate({ x: 120, y: -20 })
        }
        .layoutWeight(1)
      }
      .height(200)
      .clip(true)
      .borderRadius({ topLeft: 8, topRight: 8 })

      // Bottom info bar
      Row({ space: 10 }) {
        Text(this.dateRangeText)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.pencilGray)
        Text('·')
          .fontColor(Colors.stampRed)
        Text(this.routeText)
          .fontSize(12)
          .fontColor(Colors.pencilGray)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Text(`共${this.totalDays}天`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(Colors.travelBlue)
          .borderRadius(4)
      }
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .width('100%')

      // Actions
      Row() {
        Button('查看旅程详情')
          .fontSize(14)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(Colors.travelBlue)
          .backgroundColor('transparent')
          .onClick(() => {
            if (this.onOpenDetails) this.onOpenDetails(this.travel);
          })

        Blank()

        Button('结束')
          .fontSize(12)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(Colors.stampRed)
          .backgroundColor('transparent')
          .onClick(() => {
            if (this.onEndTravel) this.onEndTravel(this.travel);
          })

        Button() {
          Row({ space: 4 }) {
            Text('✎')
            Text('继续记录')
          }
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .type(ButtonType.Normal)
        .borderRadius(6)
        .backgroundColor(Colors.travelBlue)
        .onClick(() => {
          if (this.onContinue) this.onContinue();
        })
      }
      .padding({ left: 16, right: 16, bottom: 14 })
      .width('100%')
    }
    .backgroundColor(Colors.overlayBackground)
    .borderRadius(12)
    .shadow({ radius: 14, color: 'rgba(0,0,0,0.12)', offsetY: 6 })
    .overlay(StampPerforation({ cornerRadius: 12, color: Colors.pageBackground }))
  }

  private get routeText(): string {
    switch (this.travel.destination) {
      case '云南': return '昆明 → 大理 → 丽江 → 香格里拉';
      case '上海': return '外滩 → 南京路 → 迪士尼';
      case '川西': return '成都 → 四姑娘山 → 稻城亚丁';
      default: return `${this.travel.destination} → 邮局 → 旅途`;
    }
  }
}

@Component
struct EmptyTravelCard {
  onCreateTravel?: () => void;

  build() {
    PostalEmptyState({
      title: '还没有旅行邮票',
      message: '创建第一段旅程后，这里会生成专属旅行邮局封面和明信片记录。',
      icon: '📮',
      actionTitle: '创建新旅行',
      action: this.onCreateTravel
    })
  }
}

@Component
struct TravelSwitcherCard {
  travels: Travel[] = [];
  onSelectTravel?: (t: Travel) => void;
  onOpenDetails?: (t: Travel) => void;
  onDeleteTravel?: (t: Travel) => void;

  build() {
    Column({ space: 14 }) {
      PostalSectionHeader({ title: '切换旅程', trailing: '查看全部' })

      ForEach(this.travels, (travel: Travel) => {
        SwitcherRow({
          travel: travel,
          onSelect: () => { if (this.onSelectTravel) this.onSelectTravel(travel); },
          onOpenDetails: () => { if (this.onOpenDetails) this.onOpenDetails(travel); },
          onDelete: () => { if (this.onDeleteTravel) this.onDeleteTravel(travel); }
        })
      })
    }
    .padding({ top: 4, bottom: 4 })
  }
}

@Component
struct SwitcherRow {
  @Prop travel: Travel;
  onSelect?: () => void;
  onOpenDetails?: () => void;
  onDelete?: () => void;

  private get statusLabel(): string {
    switch (this.travel.status) {
      case TravelStatus.ONGOING: return '进行中';
      case TravelStatus.COMPLETED: return '已结束';
      case TravelStatus.PLANNED: return '待出发';
      default: return '';
    }
  }

  private get summaryText(): string {
    const fmt = (ts: number) => {
      const d = new Date(ts);
      return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
    };
    return `${fmt(this.travel.startDate)} - ${fmt(this.travel.endDate ?? this.travel.startDate)}`;
  }

  private get routeText(): string {
    switch (this.travel.destination) {
      case '云南': return '昆明 → 大理 → 丽江 → 香格里拉';
      case '上海': return '外滩 → 南京路 → 迪士尼';
      case '川西': return '成都 → 四姑娘山 → 稻城亚丁';
      default: return `${this.travel.destination} → 邮局 → 旅途`;
    }
  }

  private get serialNo(): string {
    const d = new Date(this.travel.startDate);
    const yy = d.getFullYear().toString().slice(-2);
    const mm = (d.getMonth() + 1).toString().padStart(2, '0');
    const dd = d.getDate().toString().padStart(2, '0');
    return `NO. ${yy}${mm}${dd}${(Math.abs(this.hash(this.travel.title)) % 90 + 10)}`;
  }

  build() {
    Row({ space: 12 }) {
      // Left barcode-like stripe
      Column({ space: 5 }) {
        Text('挂号信')
          .fontSize(12)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(Colors.pencilGray)
          .rotate({ angle: -90 })
          .width(42)
          .height(24)
        Divider().width(30).color('rgba(29,42,37,0.65)')
        ForEach([1, 2, 3, 4, 5], () => {
          Divider().width(30).color('rgba(29,42,37,0.38)')
        })
      }
      .width(44)

      // Sample image
      Stack() {
        LinearGradient({ angle: 45, colors: ['#B8DAEA', '#2E7D58'] })
          .width(72)
          .height(62)
          .borderRadius(6)
        Text('✈')
          .fontSize(20)
          .fontColor(Color.White)
          .opacity(0.5)
      }

      // Info
      Button() {
        Column({ space: 5 }) {
          Text(this.travel.title)
            .fontSize(21)
            .fontWeight(FontWeight.Heavy)
            .fontFamily('serif')
            .fontColor(Colors.inkBlack)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.summaryText)
            .fontSize(12)
            .fontColor(Colors.inkBlack)
          Text(this.routeText)
            .fontSize(12)
            .fontColor(Colors.pencilGray)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 6, bottom: 6 })
      }
      .type(ButtonType.Normal)
      .backgroundColor('transparent')
      .layoutWeight(1)
      .align(Alignment.Start)
      .onClick(() => { if (this.onSelect) this.onSelect(); })

      // Right stamp & status
      Column({ space: 8 }) {
        PostalStampSeal({
          title: this.travel.title.replace('之旅', '局'),
          date: this.summaryText.split(' - ')[0] ?? ''
        })
          .scale({ x: 0.64, y: 0.64 })
          .width(54)
          .height(54)

        Text(this.statusLabel)
          .fontSize(12)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(this.travel.status === TravelStatus.COMPLETED ? Colors.stampRed : Colors.travelBlue)
          .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          .border({ width: 1, color: this.travel.status === TravelStatus.COMPLETED ? Colors.stampRed : Colors.travelBlue, radius: 2 })

        Text(this.serialNo)
          .fontSize(12)
          .fontColor(Colors.pencilGray)
      }

      // Actions
      Column({ space: 8 }) {
        Button() {
          Text('🗑')
            .fontSize(12)
            .fontWeight(FontWeight.SemiBold)
            .fontColor(Colors.stampRed)
        }
        .type(ButtonType.Circle)
        .backgroundColor(Colors.paperBeige)
        .width(28)
        .height(28)
        .onClick(() => { if (this.onDelete) this.onDelete(); })

        Button() {
          Text('›')
            .fontSize(22)
            .fontColor(Colors.travelBlue)
        }
        .type(ButtonType.Circle)
        .backgroundColor('transparent')
        .width(28)
        .height(28)
        .onClick(() => { if (this.onOpenDetails) this.onOpenDetails(); })
      }
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .width('100%')
    .backgroundColor(Colors.cardBackground)
    .borderRadius(8)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
    .overlay(StampPerforation({ cornerRadius: 8, color: Colors.pageBackground }))
  }

  private hash(str: string): number {
    let h = 0;
    for (let i = 0; i < str.length; i++) {
      h = ((h << 5) - h) + str.charCodeAt(i);
      h |= 0;
    }
    return h;
  }
}

@Component
struct MapPreviewCard {
  cityCount: number = 0;
  postcardCount: number = 0;
  stampCount: number = 0;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      PostalStatsTicket({
        items: [
          new PostalStatItem('📮', '寄出明信片', `${this.postcardCount}`, '张'),
          new PostalStatItem('🏷', '收集邮票', `${this.stampCount}`, '枚'),
          new PostalStatItem('📍', '到访城市', `${this.cityCount}`, '座')
        ],
        compact: false
      })

      Text('邮局小结')
        .fontSize(21)
        .fontWeight(FontWeight.Heavy)
        .fontFamily('serif')
        .fontColor(Colors.travelBlue)
        .padding({ left: 18, top: -32 })
        .position({ x: 0, y: 0 })
    }
    .padding({ top: 32 })
  }
}

@Component
struct CreateTravelDialog {
  @Link isShow: boolean;
  onSave?: (title: string, destination: string) => void;
  @State title: string = '';
  @State destination: string = '';

  build() {
    Stack() {
      Column() {
        Column({ space: 16 }) {
          Text('创建新旅行')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.inkBlack)

          TextInput({ placeholder: '旅行标题', text: $$title })
            .placeholderColor(Colors.stampGray)
            .border({ width: 1, color: Colors.lineSepia, radius: 8 })
            .padding(12)
            .width('100%')

          TextInput({ placeholder: '目的地', text: $$destination })
            .placeholderColor(Colors.stampGray)
            .border({ width: 1, color: Colors.lineSepia, radius: 8 })
            .padding(12)
            .width('100%')

          Row({ space: 12 }) {
            Button('取消')
              .fontColor(Colors.pencilGray)
              .backgroundColor('transparent')
              .onClick(() => { this.isShow = false; })

            Blank()

            Button('保存')
              .fontColor(Color.White)
              .backgroundColor(Colors.travelBlue)
              .borderRadius(8)
              .enabled(this.title.trim().length > 0 && this.destination.trim().length > 0)
              .onClick(() => {
                if (this.onSave) {
                  this.onSave(this.title.trim(), this.destination.trim());
                }
                this.isShow = false;
                this.title = '';
                this.destination = '';
              })
          }
          .width('100%')
        }
        .padding(24)
        .backgroundColor(Colors.cardBackground)
        .borderRadius(16)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetY: 8 })
        .margin({ left: 32, right: 32 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0,0,0,0.4)')
      .onClick(() => { this.isShow = false; })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}

@Component
struct TravelDetailOverlay {
  @Prop travel: Travel;
  onClose?: () => void;
  onSetCurrent?: (t: Travel) => void;
  onEndTravel?: (t: Travel) => void;
  onDeleteTravel?: (t: Travel) => void;

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column({ space: 20 }) {
            Row() {
              Button('‹ 返回')
                .fontSize(16)
                .fontColor(Colors.travelBlue)
                .backgroundColor('transparent')
                .onClick(() => { if (this.onClose) this.onClose(); })
              Blank()
              Text('旅程详情')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.inkBlack)
              Blank()
              Button('⋮')
                .fontSize(20)
                .fontColor(Colors.travelBlue)
                .backgroundColor('transparent')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12 })

            // Hero
            HeroCard({ travel: this.travel })

            // Highlights
            HighlightsSection({ travel: this.travel })

            // Postcards
            PostcardsSection({ travel: this.travel })

            // Actions
            if (this.travel.status !== TravelStatus.COMPLETED) {
              Button('继续记录')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .width('100%')
                .height(50)
                .backgroundColor(Colors.travelBlue)
                .borderRadius(10)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/RecordPage' });
                })
            }

            if (this.travel.status !== TravelStatus.COMPLETED) {
              Button('结束旅程')
                .fontSize(14)
                .fontColor(Colors.stampRed)
                .backgroundColor('transparent')
                .onClick(() => { if (this.onEndTravel) this.onEndTravel(this.travel); })
            }

            Button('删除旅程')
              .fontSize(14)
              .fontColor(Colors.stampRed)
              .backgroundColor('transparent')
              .onClick(() => { if (this.onDeleteTravel) this.onDeleteTravel(this.travel); })

            Blank().height(40)
          }
          .padding(16)
          .width('100%')
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.pageBackground)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}

@Component
struct HeroCard {
  @Prop travel: Travel;

  private get dateStampText(): string {
    const d = new Date(this.travel.startDate);
    return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
  }

  private get shortDateRange(): string {
    const fmt = (ts: number) => {
      const d = new Date(ts);
      return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
    };
    const end = this.travel.endDate ?? Date.now();
    return `${fmt(this.travel.startDate)} - ${fmt(end)}`;
  }

  private get travelDays(): number {
    const end = this.travel.endDate ?? Date.now();
    return Math.max(Math.floor((end - this.travel.startDate) / (1000 * 60 * 60 * 24)), 1);
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 0 }) {
        Stack({ alignContent: Alignment.TopStart }) {
          LinearGradient({ angle: 180, colors: [Colors.travelBlue, '#0A3A30'] })
            .width(92)
            .height('100%')

          Column({ space: 18 }) {
            Column({ space: 1 }) {
              Text('中国邮政')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontFamily('serif')
              Text('CHINA POST')
                .fontSize(7)
            }
            .width(74)
            .height(74)
            .rotate({ angle: -9 })
            .border({ width: 1.5, color: Colors.stampRed, radius: 37 })
            .fontColor(Colors.stampRed)
            .backgroundColor('rgba(255,255,255,0.94)')

            Blank()
            Text('TRAVEL\nPOST\nOFFICE')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontFamily('serif')
              .fontColor(Colors.dawnYellow)
            Blank()
            Text('航空明信片\n档案')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.dawnYellow)
              .padding(8)
              .border({ width: 1, color: Colors.dawnYellow, radius: 3 })
          }
          .padding(14)
          .width(92)
          .alignItems(HorizontalAlign.Start)
        }

        Stack({ alignContent: Alignment.TopEnd }) {
          LinearGradient({ angle: 180, colors: ['rgba(255,255,255,0.42)', 'transparent'] })
            .width('100%')
            .height('100%')

          Column({ space: 8 }) {
            Text(this.travel.title)
              .fontSize(40)
              .fontWeight(FontWeight.Heavy)
              .fontFamily('serif')
              .fontColor(Colors.travelBlue)
            Text(this.shortDateRange)
              .fontSize(18)
              .fontWeight(FontWeight.SemiBold)
              .fontFamily('serif')
              .fontColor(Colors.inkBlack)
            Text('山水桂林 · 南宁风情 · 龙脊梯田')
              .fontSize(12)
              .fontWeight(FontWeight.SemiBold)
              .fontColor(Colors.travelBlue)
          }
          .padding(28)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .height('100%')

          PostalStampSeal({ title: '航空明信片', date: this.dateStampText, color: Colors.travelBlue })
            .padding(18)
        }
        .layoutWeight(1)
      }
      .height(200)
      .clip(true)
      .borderRadius({ topLeft: 8, topRight: 8 })

      Row({ space: 0 }) {
        this.DetailStat('📅', `${this.travelDays}`, '旅程天数')
        this.DividerV()
        this.DetailStat('📮', `${DataManager.getTravelPostcards(this.travel.id).length}`, '明信片')
        this.DividerV()
        this.DetailStat('📍', `${new Set(DataManager.getTravelPostcards(this.travel.id).map(p => p.city).filter(c => c)).size}`, '到访城市')
        this.DividerV()
        this.DetailStat('🏷', `${DataManager.getTravelPostcards(this.travel.id).filter(p => p.isFavorite).length}`, '收集邮戳')
      }
      .padding({ top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor('rgba(255,252,245,0.95)')
    }
    .backgroundColor(Colors.overlayBackground)
    .borderRadius(8)
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.12)', offsetY: 5 })
    .overlay(StampPerforation({ cornerRadius: 8, color: Colors.pageBackground }))
  }

  @Builder
  DetailStat(icon: string, value: string, title: string) {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        Text(icon)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
        Text(value)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
      }
      .fontColor(Colors.travelBlue)
      .alignItems(VerticalAlign.Bottom)
      Text(title)
        .fontSize(11)
        .fontColor(Colors.pencilGray)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DividerV() {
    Divider()
      .vertical(true)
      .height(34)
      .color(Colors.lineSepia)
  }
}

@Component
struct HighlightsSection {
  @Prop travel: Travel;

  private get visitedLocations(): string[] {
    const seen = new Set<string>();
    return DataManager.getTravelPostcards(this.travel.id)
      .map(p => (p.city ?? p.locationName).trim())
      .filter(name => name.length > 0 && !seen.has(name) && seen.add(name));
  }

  build() {
    Column({ space: 14 }) {
      PostalSectionHeader({ title: '旅程摘要' })

      Column() {
        Row() {
          Column({ space: 8 }) {
            Text('从桂林山水到龙脊梯田，从南宁老街到阳朔西街，用镜头和明信片记录一段关于自然与人文的美好旅程。')
              .fontSize(14)
              .fontColor(Colors.inkBlack)
              .lineHeight(22)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          PostalStampSeal({ title: this.travel.destination, date: this.dateStampText, color: Colors.travelBlue })
            .scale({ x: 0.86, y: 0.86 })
        }
        .padding(16)
      }
      .backgroundColor(Colors.cardBackground)
      .borderRadius(8)
      .border({ width: 1, color: Colors.lineSepia })
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
      .overlay(StampPerforation({ cornerRadius: 8, color: Colors.pageBackground }))

      PostalSectionHeader({ title: '旅程轨迹' })

      Column({ space: 14 }) {
        this.RouteStrip(this.visitedLocations.length > 0 ? this.visitedLocations : ['南宁', '桂林', '阳朔', '龙脊', '北海'])
      }
      .padding(16)
      .backgroundColor(Colors.cardBackground)
      .borderRadius(8)
      .border({ width: 1, color: Colors.lineSepia })
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
      .overlay(StampPerforation({ cornerRadius: 8, color: Colors.pageBackground }))
    }
  }

  @Builder
  RouteStrip(locations: string[]) {
    Row({ space: 0 }) {
      ForEach(locations, (location: string, index: number) => {
        Column({ space: 8 }) {
          Circle()
            .width(24)
            .height(24)
            .fill(index === 0 || index === locations.length - 1 ? Colors.travelBlue : Colors.postalMint)
            .overlay(
              Text(index === 0 ? '起' : (index === locations.length - 1 ? '终' : ''))
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            )
          Text(location)
            .fontSize(16)
            .fontWeight(FontWeight.Heavy)
            .fontFamily('serif')
            .fontColor(Colors.travelBlue)
          Text(index === 0 ? '05.14' : `05.${14 + index * 2}`)
            .fontSize(11)
            .fontColor(Colors.pencilGray)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        if (index < locations.length - 1) {
          Divider()
            .strokeWidth(1.5)
            .color(Colors.travelBlue)
            .opacity(0.65)
            .strokeDashArray([5, 5])
            .layoutWeight(1)
            .margin({ bottom: 42 })
        }
      })
    }
    .width('100%')
  }

  private get dateStampText(): string {
    const d = new Date(this.travel.startDate);
    return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
  }
}

@Component
struct PostcardsSection {
  @Prop travel: Travel;

  build() {
    Column({ space: 14 }) {
      Text('旅程明信片')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.inkBlack)

      if (DataManager.getTravelPostcards(this.travel.id).length === 0) {
        PostalEmptyState({
          title: '还没有旅程记录',
          message: '继续记录后，这次旅行的明信片会出现在这里，并自动装订成旅程档案。',
          icon: '🖼'
        })
      } else {
        Column({ space: 12 }) {
          ForEach(DataManager.getTravelPostcards(this.travel.id), (postcard: Postcard) => {
            PostcardCard({ postcard: postcard, compact: true })
          })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
