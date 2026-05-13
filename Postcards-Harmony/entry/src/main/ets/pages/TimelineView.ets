import { DataManager } from '../model/DataManager';
import { Travel } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import {
  PostalPageHeader,
  PostalEmptyState,
  PostalStampSeal,
  WaveLine
} from '../components/PostalComponents';
import { PostcardCard } from '../components/PostcardCard';
import { TravelFilterChips } from '../components/TravelFilterChips';

interface PostcardGroup {
  date: number;
  items: Postcard[];
}

@Component
export struct TimelineView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];
  @State searchText: string = '';
  @State selectedTravelID: string | null = null;

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

  private getFilteredPostcards(): Postcard[] {
    const query = this.searchText.trim().toLowerCase();
    let list = this.postcards;
    if (this.selectedTravelID) {
      list = list.filter(p => p.travelID === this.selectedTravelID);
    }
    if (query.length === 0) return list;
    return list.filter(p =>
      p.locationName.toLowerCase().includes(query) ||
      (p.note && p.note.toLowerCase().includes(query) || false) ||
      p.tags.some(t => t.toLowerCase().includes(query))
    );
  }

  private getGroupedPostcards(): PostcardGroup[] {
    const map = new Map<number, Postcard[]>();
    for (const p of this.getFilteredPostcards()) {
      const d = new Date(p.recordedAt);
      d.setHours(0, 0, 0, 0);
      const ts = d.getTime();
      if (!map.has(ts)) map.set(ts, []);
      map.get(ts)!.push(p);
    }
    return Array.from(map.entries())
      .sort((a, b) => b[0] - a[0])
      .map((entry: [number, Postcard[]]): PostcardGroup => {
      const date = entry[0];
      const items = entry[1];
      return { date: date, items: items } as PostcardGroup;
    });
  }

  build() {
    Column() {
      PostalPageHeader({
        title: '时间轴',
        subtitle: '邮件分拣中心 / 旅行邮件档案',
        leadingSymbol: '📦',
        trailingLabel: '筛选'
      })
      .padding({ left: 16, right: 16 })

      // Search
      TextInput({ placeholder: '搜索地点、标签...', text: this.searchText })
        .placeholderColor(Colors.stampGray)
        .height(44)
        .border({ width: 1, color: Colors.lineSepia, radius: 10 })
        .padding({ left: 12, right: 12 })
        .margin({ left: 16, right: 16, top: 8 })
        .onChange((value: string) => {
          this.searchText = value;
        })

      TravelFilterChips({
        travels: this.travels,
        selectedTravelID: $selectedTravelID,
        allTitle: '全部'
      })
      .padding({ left: 16, right: 16, top: 8 })

      if (this.getGroupedPostcards().length === 0) {
        Scroll() {
          Column({ space: 24 }) {
            PostalEmptyState({
              title: this.searchText.length === 0 ? '还没有投递记录' : '没有搜索结果',
              message: this.searchText.length === 0
                ? '保存第一张明信片后，时间轴会按日期分拣成一枚枚旅行邮票。'
                : '试试搜索别的地点、文字或标签。',
              icon: this.searchText.length === 0 ? '📥' : '🔍'
            })
            .padding({ left: 16, right: 16 })

            this.SampleTimelinePreview()
          }
          .padding({ top: 16, bottom: 16 })
        }
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.getGroupedPostcards(), (group: PostcardGroup) => {
            ListItem() {
              Column({ space: 12 }) {
                DateHeader({ date: group.date, location: (group.items[0] && group.items[0].locationName) || '' })
                  .backgroundColor('rgba(250,247,239,0.96)')

                GridRow({ columns: 2, gutter: { x: 12, y: 12 } }) {
                  ForEach(group.items, (postcard: Postcard) => {
                    GridCol({ span: 1 }) {
                      PostcardCard({ postcard: postcard, compact: true })
                    }
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .padding({ top: 8, bottom: 16 })
            }
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }

  @Builder
  SampleTimelinePreview() {
    Column({ space: 14 }) {
      DateHeader({ date: Date.now(), location: '南宁' })
      GridRow({ columns: 2, gutter: { x: 12, y: 12 } }) {
        GridCol({ span: 1 }) {
          this.SampleStamp('南宁', '抵达绿城，开启旅程', '#B8DAEA')
        }
        GridCol({ span: 1 }) {
          this.SampleStamp('青秀山', '城市绿肺，登高望远', '#DDE9DE')
        }
      }
      .opacity(0.72)
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  SampleStamp(title: string, caption: string, color: string) {
    Column({ space: 8 }) {
      Stack() {
        Stack()
          .width('100%')
          .height(104)
          .borderRadius(5)
        Text('✈')
          .fontSize(24)
          .opacity(0.5)
      }
      Text(title)
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontFamily('serif')
      Text(caption)
        .fontSize(12)
    }
    .padding(10)
    .backgroundColor(Colors.overlayBackground)
    .borderRadius(8)
    .border({ width: 1, color: Colors.lineSepia })
  }
}

@Component
struct DateHeader {
  @Prop date: number = 0;
  @Prop location: string = '';

  build() {
    Row({ space: 16 }) {
      Column({ space: 0 }) {
        Text(this.getStampMonth())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
        Divider()
          .color(Colors.stampRed)
          .width('100%')
        Text(this.getStampDay())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
      }
      .width(58)
      .height(58)
      .border({ width: 1.5, color: 'rgba(184,74,56,0.8)', radius: 29 })

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(this.getFormatDate())
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontFamily('serif')
          Text(this.location)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontFamily('serif')
          WaveLine()
            .width(58)
            .height(18)
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: 6 }) {
          Text('📍')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
          Text(this.location.length > 0 ? this.location : '旅行邮件档案')
            .fontSize(12)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('⌄')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .width('100%')
  }

  private getStampMonth(): string {
    const d = new Date(this.date);
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[d.getMonth()];
  }

  private getStampDay(): string {
    return new Date(this.date).getDate().toString();
  }

  private getFormatDate(): string {
    const d = new Date(this.date);
    return `${(d.getMonth() + 1).toString().padStart(2, '0')}.${d.getDate().toString().padStart(2, '0')}`;
  }
}
