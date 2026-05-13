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

interface CityInfo {
  name: string;
  lat: number;
  lng: number;
  count: number;
  country?: string;
}

interface MapBounds {
  minLat: number;
  maxLat: number;
  minLng: number;
  maxLng: number;
}

interface MapPoint {
  x: number;
  y: number;
}

@Component
export struct MapView {
  @State travels: Travel[] = [];
  @State postcards: Postcard[] = [];
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
    if (this.selectedTravelID) {
      return this.postcards.filter(p => p.travelID === this.selectedTravelID);
    }
    return this.postcards;
  }

  private getCities(): CityInfo[] {
    const map = new Map<string, CityInfo>();
    for (const p of this.getScopedPostcards()) {
      if (p.locationLat == null || p.locationLng == null) continue;
      const key: string = (p.city || p.locationName) as string;
      const existing = map.get(key);
      if (existing) {
        existing.count++;
      } else {
        map.set(key, { name: key, lat: p.locationLat, lng: p.locationLng, count: 1, country: p.country || undefined });
      }
    }
    const cities: CityInfo[] = Array.from(map.values());
    return cities.sort((a: CityInfo, b: CityInfo): number => a.name.localeCompare(b.name));
  }

  private getCountryCount(): number {
    const countries: (string | undefined)[] = this.getCities().map((c: CityInfo): string | undefined => c.country);
    return new Set(countries.filter(c => !!c)).size;
  }

  private mapBounds(cities: CityInfo[]): MapBounds {
    const lats = cities.map(c => c.lat);
    const lngs = cities.map(c => c.lng);
    return {
      minLat: lats.reduce((a, b) => a < b ? a : b, lats[0] ?? 0),
      maxLat: lats.reduce((a, b) => a > b ? a : b, lats[0] ?? 0),
      minLng: lngs.reduce((a, b) => a < b ? a : b, lngs[0] ?? 0),
      maxLng: lngs.reduce((a, b) => a > b ? a : b, lngs[0] ?? 0)
    };
  }

  private cityX(city: CityInfo, cities: CityInfo[]): string {
    const b = this.mapBounds(cities);
    const range = b.maxLng - b.minLng || 1;
    const pct = 10 + ((city.lng - b.minLng) / range) * 80;
    return `${pct}%`;
  }

  private cityY(city: CityInfo, cities: CityInfo[]): string {
    const b = this.mapBounds(cities);
    const range = b.maxLat - b.minLat || 1;
    const pct = 90 - ((city.lat - b.minLat) / range) * 80;
    return `${pct}%`;
  }

  private projectPoint(lat: number, lng: number, b: MapBounds): MapPoint {
    const latRange = b.maxLat - b.minLat || 1;
    const lngRange = b.maxLng - b.minLng || 1;
    return {
      x: 10 + ((lng - b.minLng) / lngRange) * 80,
      y: 90 - ((lat - b.minLat) / latRange) * 80
    };
  }

  private routePath(cities: CityInfo[]): string {
    if (cities.length === 0) return '';
    const b = this.mapBounds(cities);
    const first = this.projectPoint(cities[0].lat, cities[0].lng, b);
    let d = `M ${first.x.toFixed(1)} ${first.y.toFixed(1)}`;
    for (let i = 1; i < cities.length; i++) {
      const p = this.projectPoint(cities[i].lat, cities[i].lng, b);
      d += ` L ${p.x.toFixed(1)} ${p.y.toFixed(1)}`;
    }
    return d;
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

      if (this.getCities().length === 0) {
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
          }
          .padding({ top: 16, bottom: 16 })
        }
        .layoutWeight(1)
      } else {
        Column({ space: 12 }) {
          // Route Map
          Stack({ alignContent: Alignment.Center }) {
            // Map background
            Stack()
              .width('100%')
              .height('100%')
              .borderRadius(12)
              .backgroundColor('#E8F0E8')

            // Grid lines
            Column({ space: 0 }) {
              ForEach([1, 2, 3], () => {
                Divider()
                  .width('100%')
                  .height(1)
                  .color('rgba(15,93,73,0.08)')
              })
            }
            .height('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .width('100%')

            Row({ space: 0 }) {
              ForEach([1, 2, 3], () => {
                Divider()
                  .vertical(true)
                  .width(1)
                  .height('100%')
                  .color('rgba(15,93,73,0.08)')
              })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.SpaceEvenly)

            // Route line
            if (this.getCities().length > 1) {
              Shape() {
                Path()
                  .commands(this.routePath(this.getCities()))
                  .stroke(Colors.travelBlue)
                  .strokeWidth(2)
                  .fill('none')
              }
              .width('100%')
              .height('100%')
              .position({ x: 0, y: 0 })
            }

            // City dots
            ForEach(this.getCities(), (city: CityInfo, index: number) => {
              Stack({ alignContent: Alignment.Center }) {
                Stack()
                  .width(index === 0 || index === this.getCities().length - 1 ? 10 : 6)
                  .height(index === 0 || index === this.getCities().length - 1 ? 10 : 6)
                  .backgroundColor(index === 0 ? Colors.stampRed : (index === this.getCities().length - 1 ? Colors.forestGreen : Colors.travelBlue))
                  .borderRadius(index === 0 || index === this.getCities().length - 1 ? 5 : 3)
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.2)', offsetY: 2 })

                Text(city.name)
                  .fontSize(10)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.inkBlack)
                  .backgroundColor('rgba(255,255,255,0.9)')
                  .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .position({ y: '100%' })
                  .translate({ y: 4 })
              }
              .position({ x: this.cityX(city, this.getCities()), y: this.cityY(city, this.getCities()) })
              .translate({ x: -10, y: -10 })
            })

            // Compass
            Column({ space: 2 }) {
              Text('N')
                .fontSize(10)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.travelBlue)
              Stack()
                .width(2)
                .height(14)
                .backgroundColor(Colors.stampRed)
            }
            .padding(6)
            .backgroundColor('rgba(255,255,255,0.9)')
            .borderRadius(8)
            .position({ x: '100%', y: 0 })
            .translate({ x: -32, y: 12 })
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })

          PostalStatsTicket({
            items: [
              new PostalStatItem('🏛', '点亮城市', `${this.getCities().length}`, '座'),
              new PostalStatItem('🌏', '跨越国家', `${this.getCountryCount()}`, '个'),
              new PostalStatItem('🚩', '旅程里程', `${Math.max(this.getCities().length, 1) * 680}`, 'km')
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
        Stack()
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
                .fontWeight(FontWeight.Bold)
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
