import { DataManager } from '../model/DataManager';
import { Travel } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import {
  PostalPageHeader,
  PostalEmptyState,
  PostalStatsTicket,
  PostalStatItem,
  PostalStampSeal
} from '../components/PostalComponents';
import { TravelFilterChips } from '../components/TravelFilterChips';

@Component
export struct MapView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];
  @State selectedTravelID: string | null = null;

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

  private get scopedPostcards(): Postcard[] {
    if (this.selectedTravelID) {
      return this.postcards.filter(p => p.travelID === this.selectedTravelID);
    }
    return this.postcards;
  }

  private get cities(): { name: string; lat: number; lng: number; count: number; country?: string }[] {
    const map = new Map<string, { name: string; lat: number; lng: number; count: number; country?: string }>();
    for (const p of this.scopedPostcards) {
      if (p.locationLat == null || p.locationLng == null) continue;
      const key = p.city ?? p.locationName;
      const existing = map.get(key);
      if (existing) {
        existing.count++;
      } else {
        map.set(key, { name: key, lat: p.locationLat, lng: p.locationLng, count: 1, country: p.country ?? undefined });
      }
    }
    return Array.from(map.values()).sort((a, b) => a.name.localeCompare(b.name));
  }

  private get countryCount(): number {
    return new Set(this.cities.map(c => c.country).filter(c => c)).size;
  }

  build() {
    Column() {
      PostalPageHeader({
        title: '旅行邮局',
        subtitle: '邮路网络 / 本次旅程投递图',
        leadingSymbol: '🧭',
        trailingLabel: '图层'
      })
      .padding({ left: 16, right: 16 })

      TravelFilterChips({
        travels: this.travels,
        selectedTravelID: $selectedTravelID,
        allTitle: '全部足迹'
      })
      .padding({ left: 16, right: 16, top: 8 })

      if (this.cities.length === 0) {
        Scroll() {
          Column({ space: 18 }) {
            PostalEmptyState({
              title: this.selectedTravelID == null ? '还没有地图足迹' : '这个旅程还没有地图足迹',
              message: this.selectedTravelID == null
                ? '保存带地点信息的明信片后，邮路会在地图上自动连成投递路线。'
                : '换一个旅程，或者继续为这次旅行记录带地点信息的明信片。',
              icon: '🗺'
            })
            .padding({ left: 16, right: 16 })

            this.EmptyRoutePreview()
              .padding({ left: 16, right: 16 })
          }
          .padding({ top: 16, bottom: 16 })
        }
        .layoutWeight(1)
      } else {
        Column({ space: 12 }) {
          // Map placeholder
          Stack({ alignContent: Alignment.Center }) {
            LinearGradient({ angle: 45, colors: ['#DDE9DE', '#87A18A'] })
              .width('100%')
              .layoutWeight(1)
              .borderRadius(12)

            Text('🗺')
              .fontSize(64)
              .fontColor(Color.White)
              .opacity(0.4)

            Column({ space: 8 }) {
              ForEach(this.cities.slice(0, 5), (city) => {
                Row({ space: 8 }) {
                  Text('📍')
                    .fontSize(16)
                  Text(city.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                  Text(`${city.count}张`)
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.8)')
                }
              })
            }
            .padding(16)
            .backgroundColor('rgba(0,0,0,0.3)')
            .borderRadius(12)
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })

          PostalStatsTicket({
            items: [
              new PostalStatItem('🏛', '点亮城市', `${this.cities.length}`, '座'),
              new PostalStatItem('🌏', '跨越国家', `${this.countryCount}`, '个'),
              new PostalStatItem('🚩', '旅程里程', `${Math.max(this.cities.length, 1) * 680}`, 'km')
            ],
            compact: true
          })
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }

  @Builder
  EmptyRoutePreview() {
    Column({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        LinearGradient({ angle: 45, colors: ['#89C5D5', '#ECE2C8'] })
          .width('100%')
          .height(240)
          .borderRadius(6)
          .opacity(0.78)

        Row({ space: 0 }) {
          ForEach(['南宁', '阳朔', '龙脊', '北海'], (name: string, index: number) => {
            Column({ space: 4 }) {
              Text('📍')
                .fontSize(16)
              Text(name)
                .fontSize(18)
                .fontWeight(FontWeight.Heavy)
                .fontFamily('serif')
                .fontColor(Colors.travelBlue)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            if (index < 3) {
              Divider()
                .strokeWidth(1.5)
                .color(Colors.travelBlue)
                .opacity(0.65)
                .strokeDashArray([5, 5])
                .layoutWeight(1)
                .margin({ bottom: 20 })
            }
          })
        }
        .padding(28)

        PostalStampSeal({ title: '投递中', date: 'ON THE WAY' })
          .scale({ x: 0.82, y: 0.82 })
          .position({ x: '100%', y: '100%' })
          .translate({ x: -80, y: -80 })
      }

      PostalStatsTicket({
        items: [
          new PostalStatItem('🏛', '点亮城市', '42', '座'),
          new PostalStatItem('🌏', '跨越国家', '3', '个'),
          new PostalStatItem('🚩', '旅程里程', '8,460', 'km')
        ],
        compact: true
      })
    }
    .padding(12)
    .backgroundColor(Colors.cardBackground)
    .borderRadius(8)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
  }
}
