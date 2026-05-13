import { DataManager } from '../model/DataManager';
import { Travel } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import {
  PostalPageHeader,
  PostalSectionHeader,
  PostalStatsTicket,
  PostalStatItem,
  PostalStampSeal,
  StampPerforation
} from '../components/PostalComponents';
import { PostcardCard } from '../components/PostcardCard';
import { TravelFilterChips } from '../components/TravelFilterChips';

interface YearAlbum {
  year: number;
  count: number;
  countryCount: number;
}

interface SampleCard {
  title: string;
  date: string;
  color: string;
}

@Component
export struct CollectionView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];
  @State selectedYear: number | null = null;
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

  private getScopedPostcards(): Postcard[] {
    let list = this.postcards;
    if (this.selectedTravelID) {
      list = list.filter(p => p.travelID === this.selectedTravelID);
    }
    if (this.selectedYear != null) {
      list = list.filter(p => new Date(p.recordedAt).getFullYear() === this.selectedYear);
    }
    return list;
  }

  private getAlbums(): YearAlbum[] {
    const map = new Map<number, Postcard[]>();
    let source = this.postcards;
    if (this.selectedTravelID) {
      source = source.filter(p => p.travelID === this.selectedTravelID);
    }
    for (const p of source) {
      const year = new Date(p.recordedAt).getFullYear();
      if (!map.has(year)) map.set(year, []);
      map.get(year)!.push(p);
    }
    return Array.from(map.entries())
      .sort((a, b) => b[0] - a[0])
      .map((entry: [number, Postcard[]]) => {
        const year = entry[0];
        const items = entry[1];
        return {
          year: year,
          count: items.length,
          countryCount: new Set(items.map((p: Postcard) => p.country).filter(c => c)).size
        } as YearAlbum;
      });
  }

  private getFavoritePostcards(): Postcard[] {
    return this.getScopedPostcards().filter(p => p.isFavorite);
  }

  build() {
    Scroll() {
      Column({ space: 24 }) {
        PostalPageHeader({
          title: '旅行邮局',
          subtitle: '集邮册，收藏每一段旅程印记',
          leadingSymbol: '📚',
          trailingLabel: '签到'
        })
        .padding({ left: 16, right: 16 })

        Row({ space: 0 }) {
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('📖')
                .fontSize(30)
              Text('收藏')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontFamily('serif')
            }
            Text('集邮册 · 收藏每一段旅程的印记')
              .fontSize(14)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column({ space: 2 }) {
            Text('已陪伴您')
              .fontSize(12)
            Text(`${Math.max(this.getAlbums().length, 1) * 118}`)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontFamily('serif')
            Text('天')
              .fontSize(12)
          }
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Colors.cardBackground)
          .borderRadius(5)
          .border({ width: 1, color: Colors.lineSepia })
          .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
          
          .width(112)
        }
        .padding({ left: 16, right: 16 })

        if (this.travels.length > 0) {
          TravelFilterChips({
            travels: this.travels,
            selectedTravelID: $selectedTravelID,
            allTitle: '全部旅行'
          })
          .padding({ left: 16, right: 16 })
        }

        // Year Albums
        Column({ space: 16 }) {
          PostalSectionHeader({ title: '年邮册' })
            .padding({ left: 16, right: 16 })

          if (this.getAlbums().length === 0) {
            Row({ space: 16 }) {
              YearAlbumCard({ year: 2024, count: 128, countryCount: 1, isSelected: false, onSelect: () => {} })
              YearAlbumCard({ year: 2023, count: 86, countryCount: 1, isSelected: false, onSelect: () => {} })
            }
            .padding({ left: 16, right: 16 })
          } else {
            Row({ space: 16 }) {
              ForEach(this.getAlbums().slice(0, 2), (album: YearAlbum) => {
                YearAlbumCard({
                  year: album.year,
                  count: album.count,
                  countryCount: album.countryCount,
                  isSelected: this.selectedYear === album.year,
                  onSelect: () => {
                    this.selectedYear = this.selectedYear === album.year ? null : album.year;
                  }
                })
              })
            }
            .padding({ left: 16, right: 16 })
          }
        }

        // Favorites
        Column({ space: 16 }) {
          Row() {
            PostalSectionHeader({ title: '精选明信片', trailing: this.selectedYear != null ? '查看全部' : '查看全部 >' })
            Blank()
            if (this.selectedYear != null) {
              Button('查看全部')
                .fontSize(14)
                .backgroundColor('transparent')
                .onClick(() => { this.selectedYear = null; })
            }
          }
          .padding({ left: 16, right: 16 })

          if (this.getFavoritePostcards().length === 0) {
            this.SamplePostcardStrip()
          } else {
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.getFavoritePostcards(), (postcard: Postcard) => {
                  PostcardCard({ postcard: postcard })
                    .width(220)
                })
              }
              .padding({ left: 16, right: 16 })
            }
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
          }
        }

        // Topics
        this.TopicsSection()

        PostalStatsTicket({
          items: [
            new PostalStatItem('📮', '明信片收藏', `${this.postcards.length}`, '张'),
            new PostalStatItem('🏷', '邮票收藏', `${this.getFavoritePostcards().length}`, '枚'),
            new PostalStatItem('📍', '足迹城市', `${new Set(this.postcards.map(p => p.city).filter(c => c)).size}`, '座')
          ],
          compact: true
        })
        .padding({ left: 16, right: 16 })
      }
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }

  @Builder
  SamplePostcardStrip() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach([
          { title: '遇龙河', date: '2024.05.18', color: '#B8DAEA' },
          { title: '陆家嘴夜景', date: '2024.02.11', color: '#243C63' },
          { title: '日月湾海岸', date: '2024.01.27', color: '#89C5D5' },
          { title: '云雾梯田', date: '2023.10.09', color: '#E6B06A' }
        ] as SampleCard[], (card: SampleCard) => {
          Column({ space: 8 }) {
            Stack({ alignContent: Alignment.TopEnd }) {
              Stack()
                .width(174)
                .height(124)
                .borderRadius(6)
              PostalStampSeal({ title: '旅行邮局', date: card.date })
                .scale({ x: 0.72, y: 0.72 })
                .translate({ x: 12, y: -12 })
            }
            Row() {
              Text(card.title)
                .fontSize(14)
                .fontWeight(FontWeight.Normal)
              Blank()
              Text('♡')
            }
            .width('100%')
          }
          .padding(10)
          .backgroundColor(Colors.overlayBackground)
          .borderRadius(8)
          .border({ width: 1, color: Colors.lineSepia })
          
          .width(200)
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
  }

  @Builder
  TopicsSection() {
    Column({ space: 14 }) {
      PostalSectionHeader({ title: '我的专题', trailing: '管理专题' })

      GridRow({ columns: 2, gutter: { x: 12, y: 12 } }) {
        GridCol({ span: 1 }) { this.TopicCard('山川', '壮阔山河 自然之美', 36, '#DDE9DE') }
        GridCol({ span: 1 }) { this.TopicCard('古城', '千年古韵 城市记忆', 28, '#27394B') }
        GridCol({ span: 1 }) { this.TopicCard('海岸', '碧海蓝天 海岸风光', 24, '#89C5D5') }
        GridCol({ span: 1 }) { this.TopicCard('夜色', '灯火阑珊 夜色之美', 20, '#243C63') }
      }
    }
  }

  @Builder
  TopicCard(title: string, subtitle: string, count: number, color: string) {
    Row({ space: 10 }) {
      Stack() {
        Stack()
          .width(76)
          .height(58)
          .borderRadius(4)
        Text('✈')
          .fontSize(16)
          .opacity(0.5)
      }

      Column({ space: 2 }) {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
        Text(subtitle)
          .fontSize(11)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`${count} 张`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .padding(10)
    .backgroundColor(Colors.cardBackground)
    .borderRadius(7)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
    
  }
}

@Component
struct YearAlbumCard {
  @Prop year: number = 0;
  @Prop count: number = 0;
  @Prop countryCount: number = 0;
  @Prop isSelected: boolean = false;
  onSelect?: () => void;

  private getCurrentColor(): ResourceColor {
    return this.year % 2 === 0 ? '#A47A36' : Colors.dawnYellow;
  }

  build() {
    Button() {
      Stack({ alignContent: Alignment.TopEnd }) {
        // Background
        Stack()
        .width('100%')
        .height('100%')
        .borderRadius(12)

        // Left spine
        Row()
          .width(18)
          .height('100%')
          .backgroundColor(this.year % 2 === 0 ? '#D8C089' : '#0A4A3C')
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.12)', offsetX: 3 })
          .position({ x: 0 })

        // Bottom image overlay
        Stack() {
          Stack()
            .width('100%')
            .height(88)
            .opacity(this.year % 2 === 0 ? 0.34 : 0.42)
        }
        .padding({ left: 18, right: 18, bottom: 18 })
        .position({ x: 0, y: '100%' })
        .translate({ y: -88 })

        // Content
        Column({ space: 8 }) {
          Text(`${this.year}`)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontFamily('serif')
          Text('年邮册')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontFamily('serif')
          Text('旅行 · 邮记 · 世界')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(1)
          Blank()
          Row() {
            Blank()
            Text(`共 ${this.count} 张`)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .border({ width: 1, color: this.getCurrentColor(), radius: 4 })
          }
          .width('100%')
        }
        .padding(22)
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Start)

        Text('⭐')
          .fontSize(20)
          .padding(14)
      }
      .width('100%')
      .height(260)
      .border({
        width: this.isSelected ? 2 : 1,
        color: this.isSelected ? Colors.stampRed : Colors.lineSepia,
        radius: 12
      })
      .shadow({ radius: 12, color: 'rgba(0,0,0,0.13)', offsetY: 6 })
    }
    .type(ButtonType.Normal)
    .backgroundColor('transparent')
    .layoutWeight(1)
    .onClick(() => { if (this.onSelect) this.onSelect(); })
  }
}
