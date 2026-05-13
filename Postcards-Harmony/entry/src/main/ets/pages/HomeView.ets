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
import { ToastManager, ConfirmDialogManager } from '../utils/GlobalStateManager';

@Component
export struct HomeView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];
  @State showCreateDialog: boolean = false;
  @State showDetailTravel: Travel | null = null;

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

  private getCurrentTravel(): Travel | undefined {
    return this.travels.find(t => t.isCurrent) ?? this.travels.find(t => t.status === TravelStatus.ONGOING);
  }

  private getOtherTravels(): Travel[] {
    const current = this.getCurrentTravel();
    return this.travels.filter(t => t.id !== current?.id);
  }

  private getUniqueCityCount(): number {
    return DataManager.uniqueCityCount;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 20 }) {
          PostalPageHeader({
            title: '旅行邮局',
            subtitle: '用明信片，记录世界',
            leadingSymbol: '',
            trailingLabel: '签到'
          })

          if (this.getCurrentTravel()) {
            CurrentTravelCard({
              travel: this.getCurrentTravel()!,
              onContinue: (): void => { this.gotoRecord(); },
              onOpenDetails: (t: Travel): void => { this.showDetailTravel = t; },
              onEndTravel: (t: Travel) => {
                DataManager.endTravel(t);
                this.refreshData();
              }
            })
          } else {
            EmptyTravelCard({
              onCreateTravel: () => { this.showCreateDialog = true; }
            })
          }

          if (this.getOtherTravels().length > 0) {
            TravelSwitcherCard({
              travels: this.getOtherTravels(),
              onSelectTravel: (t: Travel) => {
                DataManager.setCurrentTravel(t);
                ToastManager.success('已切换到「' + t.title + '」');
                this.refreshData();
              },
              onOpenDetails: (t: Travel): void => { this.showDetailTravel = t; },
              onDeleteTravel: (t: Travel) => {
                const postcardCount = DataManager.getTravelPostcards(t.id).length;
                ConfirmDialogManager.show({
                  title: '删除旅程',
                  message: `确定要删除「${t.title}」吗？${postcardCount > 0 ? '该旅程下有 ' + postcardCount + ' 张明信片也将被删除。' : ''}`,
                  confirm: '删除',
                  cancel: '取消',
                  dangerous: true,
                  onConfirm: () => {
                    DataManager.deleteTravel(t);
                    ToastManager.success('旅程已删除');
                    this.refreshData();
                  }
                });
              }
            })
          }

          MapPreviewCard({
            cityCount: this.getUniqueCityCount(),
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

      Button() {
        Column({ space: 3 }) {
          Text('寄')
            .fontSize(20)
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

      if (this.showCreateDialog) {
        CreateTravelDialog({
          isShow: $showCreateDialog,
          onSave: (title: string, destination: string) => {
            DataManager.markAllTravelsAsNotCurrent();
            const travel = new Travel(title, destination, Date.now(), true);
            DataManager.addTravel(travel);
            this.refreshData();
          }
        })
      }

      if (this.showDetailTravel) {
        TravelDetailOverlay({
          travel: this.showDetailTravel,
          onClose: () => { this.showDetailTravel = null; },
          onSetCurrent: (t: Travel) => {
            DataManager.setCurrentTravel(t);
            this.refreshData();
          },
          onEndTravel: (t: Travel) => {
            DataManager.endTravel(t);
            this.refreshData();
          },
          onDeleteTravel: (t: Travel) => {
            DataManager.deleteTravel(t);
            this.showDetailTravel = null;
            this.refreshData();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  private gotoRecord() {
    router.pushUrl({ url: 'pages/RecordPage' });
  }
}

// ========================
// CurrentTravelCard
// ========================
@Component
struct CurrentTravelCard {
  @Prop travel: Travel;
  onContinue: () => void = () => {};
  onOpenDetails: (t: Travel) => void = (t: Travel): void => {};
  onEndTravel: (t: Travel) => void = (t: Travel): void => {};

  private getTravelDays(): number {
    const days = Math.floor((Date.now() - this.travel.startDate) / (1000 * 60 * 60 * 24));
    return Math.max(days, 1);
  }

  private getTotalDays(): number {
    if (this.travel.endDate) {
      return Math.max(Math.floor((this.travel.endDate - this.travel.startDate) / (1000 * 60 * 60 * 24)), this.getTravelDays());
    }
    return this.getTravelDays();
  }

  private getDateRangeText(): string {
    const fmt = (ts: number) => {
      const d = new Date(ts);
      return `${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
    };
    const end = this.travel.endDate ?? (this.travel.startDate + Math.max(this.getTotalDays() - 1, 0) * 24 * 60 * 60 * 1000);
    return `${fmt(this.travel.startDate)} - ${fmt(end)}`;
  }

  private getRouteText(): string {
    const cities = DataManager.getTravelPostcards(this.travel.id)
      .map(p => (p.city ?? p.locationName).trim())
      .filter((name, idx, arr) => name.length > 0 && arr.indexOf(name) === idx);
    if (cities.length >= 2) {
      return cities.slice(0, 3).join(' → ');
    }
    switch (this.travel.destination) {
      case '云南': return '昆明 → 大理 → 丽江';
      case '上海': return '外滩 → 南京路 → 迪士尼';
      case '川西': return '成都 → 四姑娘山 → 稻城';
      default: return `${this.travel.destination} → 邮局 → 旅途`;
    }
  }

  build() {
    Column({ space: 0 }) {
      // Main content
      Stack({ alignContent: Alignment.TopEnd }) {
        Row({ space: 0 }) {
          // Left vertical stripe
          Column({ space: 2 }) {
            Text('远方')
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.stampRed)
              .rotate({ angle: 90 })
            Text('邮政')
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.stampRed)
              .rotate({ angle: 90 })
            Text('FAR POST')
              .fontSize(5)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.stampRed)
              .rotate({ angle: 90 })
          }
          .width(44)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .border({ width: { right: 1 }, color: Colors.lineSepia })

          // Center content
          Column({ space: 8 }) {
            // Title row
            Row({ space: 0 }) {
              Column({ space: 2 }) {
                Text(this.travel.title)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontFamily('serif')
                  .fontColor(Colors.travelBlue)
                Text(this.getDateRangeText())
                  .fontSize(12)
                  .fontColor(Colors.pencilGray)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // Days badge
              Column({ space: 0 }) {
                Text(`${this.getTravelDays()}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontFamily('serif')
                  .fontColor(Colors.stampRed)
                Text('天')
                  .fontSize(10)
                  .fontColor(Colors.stampRed)
              }
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .border({ width: 1.5, color: Colors.stampRed, radius: 6 })
              .backgroundColor('rgba(184,74,56,0.06)')
            }
            .width('100%')

            // Route
            Row({ space: 6 }) {
              Stack()
                .width(6)
                .height(6)
                .backgroundColor(Colors.stampRed)
                .borderRadius(3)
              Text(this.getRouteText())
                .fontSize(13)
                .fontColor(Colors.pencilGray)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')

            // Progress bar
            Stack({ alignContent: Alignment.Start }) {
              Stack()
                .width('100%')
                .height(4)
                .borderRadius(2)
                .backgroundColor('rgba(15,93,73,0.08)')
              Stack()
                .width(`${Math.min((this.getTravelDays() / Math.max(this.getTotalDays(), 1)) * 100, 100)}%`)
                .height(4)
                .borderRadius(2)
                .backgroundColor(Colors.travelBlue)
            }
            .width('100%')
            .height(4)

            // Bottom info row
            Row({ space: 0 }) {
              Text(`共 ${this.getTotalDays()} 天 · ${DataManager.getTravelPostcards(this.travel.id).length} 张明信片`)
                .fontSize(11)
                .fontColor(Colors.stampGray)
              Blank()
              Text('进行中')
                .fontSize(11)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.travelBlue)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .border({ width: 1, color: Colors.travelBlue, radius: 4 })
            }
            .width('100%')
          }
          .padding(14)
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(136)

        // Stamp seal
        PostalStampSeal({ title: '远方邮政', date: `${this.getTravelDays()}天` })
          .scale({ x: 0.58, y: 0.58 })
          .translate({ x: 4, y: -4 })
      }

      // Actions bar
      Row({ space: 0 }) {
        Button('查看详情')
          .fontSize(13)
          .fontColor(Colors.pencilGray)
          .backgroundColor('transparent')
          .onClick(() => {
            if (this.onOpenDetails) this.onOpenDetails(this.travel);
          })

        Blank()

        Button('结束旅程')
          .fontSize(13)
          .fontColor(Colors.stampRed)
          .backgroundColor('transparent')
          .onClick(() => {
            if (this.onEndTravel) this.onEndTravel(this.travel);
          })

        Button() {
          Row({ space: 4 }) {
            Text('写')
              .fontSize(13)
              .fontColor(Color.White)
            Text('继续记录')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        }
        .type(ButtonType.Normal)
        .borderRadius(8)
        .backgroundColor(Colors.travelBlue)
        .onClick(() => {
          if (this.onContinue) this.onContinue();
        })
      }
      .padding({ left: 16, right: 16, top: 10, bottom: 12 })
      .width('100%')
      .border({ width: { top: 1 }, color: 'rgba(215,203,183,0.5)' })
    }
    .backgroundColor(Colors.cardBackground)
    .borderRadius(12)
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: 4 })
  }
}

@Component
struct EmptyTravelCard {
  onCreateTravel?: () => void;

  build() {
    PostalEmptyState({
      title: '还没有旅行邮票',
      message: '创建第一段旅程后，这里会生成专属旅行邮局封面和明信片记录。',
      icon: '邮',
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
    Column({ space: 12 }) {
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

  private getStatusLabel(): string {
    switch (this.travel.status) {
      case TravelStatus.ONGOING: return '进行中';
      case TravelStatus.COMPLETED: return '已结束';
      case TravelStatus.PLANNED: return '待出发';
      default: return '';
    }
  }

  private getStatusColor(): ResourceColor {
    switch (this.travel.status) {
      case TravelStatus.ONGOING: return Colors.travelBlue;
      case TravelStatus.COMPLETED: return Colors.stampRed;
      case TravelStatus.PLANNED: return Colors.dawnYellow;
      default: return Colors.pencilGray;
    }
  }

  private getSummaryText(): string {
    const fmt = (ts: number) => {
      const d = new Date(ts);
      return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
    };
    return `${fmt(this.travel.startDate)} - ${fmt(this.travel.endDate ?? this.travel.startDate)}`;
  }

  private getRouteText(): string {
    const cities = DataManager.getTravelPostcards(this.travel.id)
      .map(p => (p.city ?? p.locationName).trim())
      .filter((name, idx, arr) => name.length > 0 && arr.indexOf(name) === idx);
    if (cities.length >= 2) {
      return cities.slice(0, 3).join(' → ');
    }
    switch (this.travel.destination) {
      case '云南': return '昆明 → 大理 → 丽江';
      case '上海': return '外滩 → 南京路 → 迪士尼';
      case '川西': return '成都 → 四姑娘山 → 稻城';
      default: return `${this.travel.destination} → 邮局 → 旅途`;
    }
  }

  private getSerialNo(): string {
    const d = new Date(this.travel.startDate);
    const yy = d.getFullYear().toString().slice(-2);
    const mm = (d.getMonth() + 1).toString().padStart(2, '0');
    const dd = d.getDate().toString().padStart(2, '0');
    return `NO. ${yy}${mm}${dd}${(Math.abs(this.hash(this.travel.title)) % 90 + 10)}`;
  }

  private hash(str: string): number {
    let h = 0;
    for (let i = 0; i < str.length; i++) {
      h = ((h << 5) - h) + str.charCodeAt(i);
      h |= 0;
    }
    return h;
  }

  build() {
    Row({ space: 0 }) {
      Stack()
        .width(4)
        .height('100%')
        .backgroundColor(this.getStatusColor())
        .borderRadius({ topLeft: 10, bottomLeft: 10 })

      Row({ space: 12 }) {
        Button() {
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(this.travel.title)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontFamily('serif')
                .fontColor(Colors.inkBlack)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(this.getStatusLabel())
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getStatusColor())
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getStatusColor(), radius: 4 })
            }
            .width('100%')

            Text(this.getSummaryText())
              .fontSize(11)
              .fontColor(Colors.pencilGray)

            Text(this.getRouteText())
              .fontSize(11)
              .fontColor(Colors.stampGray)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 10, bottom: 10 })
        }
        .type(ButtonType.Normal)
        .backgroundColor('transparent')
        .layoutWeight(1)
        .align(Alignment.Start)
        .onClick(() => { if (this.onSelect) this.onSelect(); })

        Column({ space: 6 }) {
          PostalStampSeal({
            title: this.travel.title.replace('之旅', '局'),
            date: this.getSummaryText().split(' - ')[0] ?? ''
          })
            .scale({ x: 0.5, y: 0.5 })
            .width(44)
            .height(44)

          Text(this.getSerialNo())
            .fontSize(9)
            .fontColor(Colors.stampGray)
            .fontFamily('monospace')

          Row({ space: 8 }) {
            Button() {
              Text('删')
                .fontSize(11)
                .fontColor(Colors.stampRed)
            }
            .type(ButtonType.Circle)
            .backgroundColor('rgba(184,74,56,0.08)')
            .width(26)
            .height(26)
            .onClick(() => { if (this.onDelete) this.onDelete(); })

            Button() {
              Text('详')
                .fontSize(11)
                .fontColor(Colors.travelBlue)
            }
            .type(ButtonType.Circle)
            .backgroundColor('rgba(15,93,73,0.08)')
            .width(26)
            .height(26)
            .onClick(() => { if (this.onOpenDetails) this.onOpenDetails(); })
          }
        }
        .justifyContent(FlexAlign.Center)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(Colors.cardBackground)
    .borderRadius(10)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetY: 3 })
  }
}

@Component
struct MapPreviewCard {
  cityCount: number = 0;
  postcardCount: number = 0;
  stampCount: number = 0;

  build() {
    Column({ space: 14 }) {
      Text('邮局小结')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontFamily('serif')
        .fontColor(Colors.travelBlue)

      Row({ space: 0 }) {
        this.StatCell(this.postcardCount, '寄出明信片', Colors.travelBlue)
        this.DividerV()
        this.StatCell(this.stampCount, '收集邮票', Colors.stampRed)
        this.DividerV()
        this.StatCell(this.cityCount, '到访城市', Colors.forestGreen)
      }
      .width('100%')
      .padding({ top: 18, bottom: 18 })
      .backgroundColor(Colors.cardBackground)
      .borderRadius(12)
      .border({ width: 1, color: Colors.lineSepia })
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.06)', offsetY: 3 })
    }
  }

  @Builder
  StatCell(value: number, label: string, accentColor: ResourceColor) {
    Column({ space: 10 }) {
      Stack()
        .width(28)
        .height(3)
        .backgroundColor(accentColor)
        .borderRadius(1.5)

      Text(`${value}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontFamily('serif')
        .fontColor(Colors.travelBlue)

      Text(label)
        .fontSize(12)
        .fontColor(Colors.pencilGray)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DividerV() {
    Divider()
      .vertical(true)
      .width(1)
      .height(48)
      .color(Colors.lineSepia)
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

          TextInput({ placeholder: '旅行标题', text: this.title })
            .placeholderColor(Colors.stampGray)
            .border({ width: 1, color: Colors.lineSepia, radius: 8 })
            .padding(12)
            .width('100%')
            .onChange((value: string) => {
              this.title = value;
            })

          TextInput({ placeholder: '目的地', text: this.destination })
            .placeholderColor(Colors.stampGray)
            .border({ width: 1, color: Colors.lineSepia, radius: 8 })
            .padding(12)
            .width('100%')
            .onChange((value: string) => {
              this.destination = value;
            })

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

            HeroCard({ travel: this.travel })

            HighlightsSection({ travel: this.travel })

            PostcardsSection({ travel: this.travel })

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

  private getDateStampText(): string {
    const d = new Date(this.travel.startDate);
    return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
  }

  private getShortDateRange(): string {
    const fmt = (ts: number) => {
      const d = new Date(ts);
      return `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
    };
    const end = this.travel.endDate ?? Date.now();
    return `${fmt(this.travel.startDate)} - ${fmt(end)}`;
  }

  private getTravelDays(): number {
    const end = this.travel.endDate ?? Date.now();
    return Math.max(Math.floor((end - this.travel.startDate) / (1000 * 60 * 60 * 24)), 1);
  }

  build() {
    Column({ space: 0 }) {
      Row({ space: 0 }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Stack()
            .width(92)
            .height('100%')

          Column({ space: 18 }) {
            Column({ space: 1 }) {
              Text('远方邮政')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontFamily('serif')
              Text('FAR POST')
                .fontSize(7)
            }
            .width(74)
            .height(74)
            .rotate({ angle: -9 })
            .border({ width: 1.5, color: Colors.stampRed, radius: 37 })
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
          Stack()
            .width('100%')
            .height('100%')

          Column({ space: 8 }) {
            Text(this.travel.title)
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontFamily('serif')
              .fontColor(Colors.travelBlue)
            Text(this.getShortDateRange())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontFamily('serif')
              .fontColor(Colors.inkBlack)
            Text(this.getJourneyDescription())
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.travelBlue)
          }
          .padding(28)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .height('100%')

          PostalStampSeal({ title: '航空明信片', date: this.getDateStampText(), color: Colors.travelBlue })
            .padding(18)
        }
        .layoutWeight(1)
      }
      .height(200)
      .clip(true)
      .borderRadius({ topLeft: 8, topRight: 8 })

      Row({ space: 0 }) {
        this.DetailStat('日', `${this.getTravelDays()}`, '旅程天数')
        this.DividerV()
        this.DetailStat('片', `${DataManager.getTravelPostcards(this.travel.id).length}`, '明信片')
        this.DividerV()
        this.DetailStat('城', `${DataManager.getTravelPostcards(this.travel.id).map(p => p.city).filter((c: string | null): boolean => !!c).length}`, '城市')
      }
      .width('100%')
      .height(56)
      .backgroundColor('rgba(15,93,73,0.05)')
    }
    .backgroundColor(Colors.cardBackground)
    .borderRadius(12)
    .shadow({ radius: 14, color: 'rgba(0,0,0,0.1)', offsetY: 5 })
  }

  private getJourneyDescription(): string {
    const postcards = DataManager.getTravelPostcards(this.travel.id);
    const cities = postcards.map(p => (p.city ?? p.locationName).trim()).filter((name, idx, arr) => name.length > 0 && arr.indexOf(name) === idx);
    if (cities.length === 0) {
      return `在${this.travel.destination}的旅程即将开始`;
    }
    const cityStr = cities.slice(0, 3).join(' · ');
    return `${cityStr}`;
  }

  @Builder
  DetailStat(icon: string, value: string, label: string) {
    Column({ space: 2 }) {
      Text(icon)
        .fontSize(14)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.travelBlue)
      Text(label)
        .fontSize(10)
        .fontColor(Colors.pencilGray)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DividerV() {
    Divider()
      .vertical(true)
      .width(1)
      .height(32)
      .color('rgba(215,203,183,0.5)')
  }
}

@Component
struct HighlightsSection {
  @Prop travel: Travel;

  private getVisitedCities(): string[] {
    const seen = new Set<string>();
    return DataManager.getTravelPostcards(this.travel.id)
      .map(p => {
        const name = (p.city ?? p.locationName).trim();
        if (name.length > 0 && !seen.has(name)) {
          seen.add(name);
          return name;
        }
        return '';
      })
      .filter(name => name.length > 0);
  }

  private getJourneyDescription(): string {
    const postcards = DataManager.getTravelPostcards(this.travel.id);
    const cities = postcards.map(p => (p.city ?? p.locationName).trim()).filter((name, idx, arr) => name.length > 0 && arr.indexOf(name) === idx);
    if (cities.length === 0) {
      return `在${this.travel.destination}的旅程即将开始，准备好寄出第一张明信片了吗？`;
    }
    const cityStr = cities.slice(0, 3).join('、');
    return `从${cityStr}出发，用镜头和明信片记录一段关于${this.travel.destination}的美好旅程。`;
  }

  build() {
    Column({ space: 14 }) {
      PostalSectionHeader({ title: '旅程摘要' })

      Column() {
        Text(this.getJourneyDescription())
          .fontSize(14)
          .fontColor(Colors.pencilGray)
          .lineHeight(22)
      }
      .padding(16)
      .width('100%')
      .backgroundColor(Colors.cardBackground)
      .borderRadius(10)
      .border({ width: 1, color: Colors.lineSepia })

      if (this.getVisitedCities().length > 0) {
        this.RouteStrip(this.getVisitedCities())
      }

      Row({ space: 10 }) {
        this.HighlightCard('城', '到访城市', `${this.getVisitedCities().length}`)
        this.HighlightCard('片', '明信片', `${DataManager.getTravelPostcards(this.travel.id).length}`)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  HighlightCard(icon: string, label: string, value: string) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(22)
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.travelBlue)
      Text(label)
        .fontSize(11)
        .fontColor(Colors.pencilGray)
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(Colors.cardBackground)
    .borderRadius(10)
    .border({ width: 1, color: Colors.lineSepia })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  RouteStrip(cities: string[]) {
    Column({ space: 8 }) {
      Text('途经路线')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.pencilGray)
        .width('100%')

      Row({ space: 0 }) {
        ForEach(cities.slice(0, 5), (city: string, index: number) => {
          Stack({ alignContent: Alignment.Center }) {
            if (index < cities.length - 1) {
              Stack()
                .width(30)
                .height(2)
                .backgroundColor(Colors.lineSepia)
                .position({ x: 20, y: 11 })
            }
            Stack()
              .width(index === 0 || index === cities.length - 1 ? 14 : 10)
              .height(index === 0 || index === cities.length - 1 ? 14 : 10)
              .backgroundColor(index === 0 ? Colors.stampRed : (index === cities.length - 1 ? Colors.forestGreen : Colors.travelBlue))
              .borderRadius(index === 0 || index === cities.length - 1 ? 7 : 5)
            Text(`${index + 1}`)
              .fontSize(index === 0 || index === cities.length - 1 ? 8 : 7)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .width(44)
          .height(44)

          Text(city)
            .fontSize(11)
            .fontColor(Colors.inkBlack)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(44)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor(Colors.cardBackground)
      .borderRadius(10)
      .border({ width: 1, color: Colors.lineSepia })
    }
    .width('100%')
  }
}

@Component
struct PostcardsSection {
  @Prop travel: Travel;

  private getPostcards(): Postcard[] {
    return DataManager.getTravelPostcards(this.travel.id);
  }

  build() {
    Column({ space: 14 }) {
      PostalSectionHeader({ title: '旅行明信片' })

      if (this.getPostcards().length === 0) {
        PostalEmptyState({
          title: '还没有明信片',
          message: '点击「继续记录」寄出你的第一张明信片。',
          icon: '空'
        })
      } else {
        ForEach(this.getPostcards(), (postcard: Postcard) => {
          PostcardCard({ postcard: postcard })
        })
      }
    }
    .width('100%')
  }
}
