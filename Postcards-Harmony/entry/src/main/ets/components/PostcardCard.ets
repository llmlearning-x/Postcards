import { Colors } from './Colors';
import { Postcard } from '../model/Postcard';
import { DataManager } from '../model/DataManager';
import { PostalStampSeal, StampPerforation } from './PostalComponents';

@Component
export struct PostcardCard {
  @Prop postcard: Postcard;
  compact: boolean = false;

  build() {
    Column({ space: this.compact ? 8 : 12 }) {
      // Photo Area
      Stack({ alignContent: Alignment.TopEnd }) {
        // Placeholder gradient image
        Stack({ alignContent: Alignment.Center }) {
          LinearGradient({
            angle: 45,
            colors: this.sampleColors
          })
            .width('100%')
            .aspectRatio(4 / 3)
            .borderRadius(this.compact ? 4 : 8)

          Text('✈')
            .fontSize(this.compact ? 24 : 36)
            .fontColor(Color.White)
            .opacity(0.6)
        }

        // CHINA POST badge
        Row() {
          Text('CHINA POST')
            .fontSize(8)
            .fontWeight(FontWeight.Bold)
            .fontFamily('sans-serif')
            .fontColor(Color.White)
            .padding({ left: 7, right: 7, top: 4, bottom: 4 })
            .backgroundColor('rgba(15,93,73,0.86)')
            .borderRadius(3)
          Blank()
        }
        .width('100%')
        .padding(8)
        .alignItems(VerticalAlign.Top)

        // Stamp seal
        PostalStampSeal({ title: '旅行邮局', date: this.dateStampText })
          .scale({ x: this.compact ? 0.72 : 0.86, y: this.compact ? 0.72 : 0.86 })
          .translate({ x: this.compact ? 16 : 10, y: this.compact ? -10 : -8 })

        // Favorite button
        Button() {
          Text(this.postcard.isFavorite ? '♥' : '♡')
            .fontSize(this.compact ? 16 : 18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.postcard.isFavorite ? Colors.stampRed : Colors.travelBlue)
        }
        .type(ButtonType.Circle)
        .backgroundColor('rgba(255,252,245,0.95)')
        .width(36)
        .height(36)
        .position({ x: '100%', y: '100%' })
        .translate({ x: -42, y: -42 })
        .onClick(() => {
          DataManager.toggleFavorite(this.postcard);
        })
      }
      .width('100%')

      // Location
      Text(this.postcard.locationName)
        .fontSize(this.compact ? 13 : 15)
        .fontWeight(FontWeight.SemiBold)
        .fontFamily('serif')
        .fontColor(Colors.inkBlack)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // Date & Weather
      Row({ space: 8 }) {
        Text(this.formatDate(this.postcard.recordedAt))
          .fontSize(12)
          .fontColor(Colors.pencilGray)
        if (this.postcard.weatherCondition) {
          Text('·')
            .fontColor(Colors.stampGray)
          Text(this.postcard.weatherCondition)
            .fontSize(12)
            .fontColor(Colors.pencilGray)
        }
      }

      if (!this.compact) {
        // Note
        if (this.postcard.note && this.postcard.note.length > 0) {
          Text(`"${this.postcard.note}"`)
            .fontSize(16)
            .fontColor(Colors.inkBlack)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        // Tags
        if (this.postcard.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 6, unit: LengthUnit.VP } } }) {
            ForEach(this.postcard.tags, (tag: string) => {
              Text(`#${tag}`)
                .fontSize(12)
                .fontColor(Colors.travelBlue)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('rgba(15,93,73,0.08)')
                .borderRadius(6)
            })
          }
          .width('100%')
        }
      }
    }
    .padding(this.compact ? 10 : 14)
    .backgroundColor(Colors.overlayBackground)
    .borderRadius(8)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 3 })
    .overlay(StampPerforation({ cornerRadius: 8, color: Colors.pageBackground }))
  }

  private get dateStampText(): string {
    const d = new Date(this.postcard.recordedAt);
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${m}.${day}`;
  }

  private formatDate(ts: number): string {
    const d = new Date(ts);
    return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`;
  }

  private get sampleColors: [ResourceColor, ResourceColor] {
    const themes: [ResourceColor, ResourceColor][] = [
      ['#B8DAEA', '#2E7D58'],
      ['#243C63', '#C78D5A'],
      ['#89C5D5', '#2E8B75'],
      ['#E6B06A', '#557E48'],
      ['#DDE9DE', '#87A18A'],
      ['#27394B', '#A65E3D']
    ];
    const idx = Math.abs(this.hashCode(this.postcard.locationName)) % themes.length;
    return themes[idx];
  }

  private hashCode(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash |= 0;
    }
    return hash;
  }
}
