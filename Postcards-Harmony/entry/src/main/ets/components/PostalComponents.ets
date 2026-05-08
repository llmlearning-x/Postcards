import { Colors } from './Colors';
import { CanvasRenderingContext2D, RenderingContextSettings } from '@kit.ArkUI';

// 波浪线装饰
@Component
export struct WaveLine {
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .onReady(() => {
        const width = this.context.width;
        const height = this.context.height;
        this.context.strokeStyle = Colors.travelBlue;
        this.context.globalAlpha = 0.55;
        this.context.lineWidth = 1.1;
        for (let row = 0; row < 3; row++) {
          const y = height * (0.24 + row * 0.25);
          this.context.beginPath();
          this.context.moveTo(0, y);
          let x = 0;
          while (x <= width) {
            this.context.bezierCurveTo(x + 4, y - 5, x + 12, y + 5, x + 16, y);
            x += 16;
          }
          this.context.stroke();
        }
      })
  }
}

// 齿孔装饰
@Component
export struct StampPerforation {
  cornerRadius: number = 16;
  color: ResourceColor = Colors.pageBackground;

  build() {
    Stack() {
      // 顶部齿孔
      Row() {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], (item: number) => {
          Circle()
            .width(5)
            .height(5)
            .fill(this.color)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 10, right: 10 })
      .position({ y: -2 })

      // 底部齿孔
      Row() {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], (item: number) => {
          Circle()
            .width(5)
            .height(5)
            .fill(this.color)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 10, right: 10 })
      .position({ y: '100%' })
      .translate({ y: -3 })

      // 左侧齿孔
      Column() {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7], (item: number) => {
          Circle()
            .width(5)
            .height(5)
            .fill(this.color)
        })
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, bottom: 10 })
      .position({ x: -2 })

      // 右侧齿孔
      Column() {
        ForEach([0, 1, 2, 3, 4, 5, 6, 7], (item: number) => {
          Circle()
            .width(5)
            .height(5)
            .fill(this.color)
        })
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, bottom: 10 })
      .position({ x: '100%' })
      .translate({ x: -3 })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.None)
  }
}

// 邮戳印章
@Component
export struct PostalStampSeal {
  title: string = '';
  date: string = '';
  color: ResourceColor = Colors.stampRed;

  build() {
    Column({ space: 1 }) {
      Text(this.title)
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
        .fontFamily('serif')
        .letterSpacing(1)
      if (this.date.length > 0) {
        Text(this.date)
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
      }
    }
    .width(74)
    .height(74)
    .rotate({ angle: -10 })
    .border({ width: 1.5, color: this.color, radius: 37 })
    .fontColor(this.color)
  }
}

// 航空邮件条纹
@Component
export struct AirmailStripe {
  build() {
    Row({ space: 8 }) {
      ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19], (item: number) => {
        Row()
          .width(10)
          .height(3)
          .rotate({ angle: -24 })
          .backgroundColor(item % 2 === 0 ? Colors.stampRed : Colors.travelBlue)
          .opacity(0.7)
      })
    }
    .width('100%')
    .clip(true)
  }
}

// 统计票据
@Component
export struct PostalStatsTicket {
  items: PostalStatItem[] = [];
  compact: boolean = false;

  build() {
    Column({ space: 8 }) {
      Row({ space: 0 }) {
        ForEach(this.items, (item: PostalStatItem, index: number) => {
          this.StatCell(item)
          if (index < this.items.length - 1) {
            Divider()
              .vertical(true)
              .height(this.compact ? 42 : 58)
              .color(Colors.lineSepia)
          }
        })
      }
      .width('100%')

      AirmailStripe()
        .height(8)
        .clip(true)
    }
    .padding({ top: this.compact ? 12 : 16, left: 10, right: 10, bottom: 6 })
    .backgroundColor(Colors.cardBackground)
    .borderRadius(12)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
  }

  @Builder
  StatCell(item: PostalStatItem) {
    Column({ space: this.compact ? 4 : 7 }) {
      Text(item.icon)
        .fontSize(this.compact ? 18 : 22)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.travelBlue)
      Text(item.title)
        .fontSize(this.compact ? 11 : 13)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.pencilGray)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 2 }) {
        Text(item.value)
          .fontSize(this.compact ? 22 : 30)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
          .fontColor(Colors.travelBlue)
        Text(item.suffix)
          .fontSize(12)
          .fontColor(Colors.pencilGray)
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}

export class PostalStatItem {
  icon: string = '';
  title: string = '';
  value: string = '';
  suffix: string = '';

  constructor(icon: string, title: string, value: string, suffix: string) {
    this.icon = icon;
    this.title = title;
    this.value = value;
    this.suffix = suffix;
  }
}

// 空状态
@Component
export struct PostalEmptyState {
  title: string = '';
  message: string = '';
  icon: string = '📮';
  actionTitle: string = '';
  action?: () => void;

  build() {
    Column({ space: 16 }) {
      Stack() {
        Text('POST')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontFamily('serif')
          .fontColor(Colors.stampGray)
          .opacity(0.5)
          .rotate({ angle: -18 })
        Text(this.icon)
          .fontSize(44)
      }
      .width(118)
      .height(118)

      Column({ space: 7 }) {
        Text(this.title)
          .fontSize(24)
          .fontWeight(FontWeight.Heavy)
          .fontFamily('serif')
          .fontColor(Colors.travelBlue)
        Text(this.message)
          .fontSize(14)
          .fontColor(Colors.pencilGray)
          .textAlign(TextAlign.Center)
          .lineHeight(22)
      }

      if (this.action && this.actionTitle.length > 0) {
        Button(this.actionTitle)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor(Colors.travelBlue)
          .borderRadius(8)
          .padding({ left: 22, right: 22, top: 11, bottom: 11 })
          .onClick(() => {
            if (this.action) this.action();
          })
      }

      AirmailStripe()
        .height(8)
        .clip(true)
        .padding({ left: 20, right: 20 })
    }
    .padding(24)
    .width('100%')
    .backgroundColor(Colors.cardBackground)
    .borderRadius(10)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.09)', offsetY: 4 })
  }
}

// 页面头部
@Component
export struct PostalPageHeader {
  title: string = '';
  subtitle: string = '';
  leadingSymbol: string = '📮';
  trailingLabel: string = '签到';

  build() {
    Row({ space: 12 }) {
      Row({ space: 10 }) {
        Stack() {
          Circle()
            .width(48)
            .height(48)
            .stroke(Colors.travelBlue)
            .strokeWidth(2)
          Text(this.leadingSymbol)
            .fontSize(20)
            .fontWeight(FontWeight.SemiBold)
          WaveLine()
            .width(46)
            .height(16)
            .position({ x: 25, y: 13 })
        }
        .width(48)
        .height(48)
        .fontColor(Colors.travelBlue)

        Column({ space: 3 }) {
          Text(this.title)
            .fontSize(29)
            .fontWeight(FontWeight.Heavy)
            .fontFamily('serif')
            .fontColor(Colors.travelBlue)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .minFontSize(20)
          Text(this.subtitle)
            .fontSize(12)
            .fontWeight(FontWeight.SemiBold)
            .fontColor(Colors.travelBlue)
            .opacity(0.78)
            .letterSpacing(2)
        }
        .alignItems(HorizontalAlign.Start)
      }

      Blank()

      if (this.trailingLabel.length > 0) {
        Row({ space: 6 }) {
          Text(this.trailingLabel === '筛选' ? '☰' : '✓')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
          Text(this.trailingLabel)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
        }
        .fontColor(Colors.travelBlue)
        .padding({ left: 12, right: 12, top: 9, bottom: 9 })
        .backgroundColor('rgba(255,252,245,0.92)')
        .borderRadius(12)
        .border({ width: 1, color: Colors.lineSepia })
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
  }
}

// 章节标题
@Component
export struct PostalSectionHeader {
  title: string = '';
  trailing: string = '';

  build() {
    Row({ space: 8 }) {
      Text(this.title)
        .fontSize(22)
        .fontWeight(FontWeight.Heavy)
        .fontFamily('serif')
        .fontColor(Colors.travelBlue)
      WaveLine()
        .width(62)
        .height(18)
        .fontColor(Colors.stampGray)
        .opacity(0.75)
      Blank()
      if (this.trailing.length > 0) {
        Text(this.trailing)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.pencilGray)
        Text('›')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.pencilGray)
      }
    }
    .width('100%')
  }
}

// CTA 按钮
@Component
export struct PostalCTAButton {
  title: string = '';
  subtitle: string = '';
  icon: string = '';
  color: ResourceColor = Colors.travelBlue;
  action?: () => void;

  build() {
    Button() {
      Row({ space: 14 }) {
        Text(this.icon)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        Column({ space: 2 }) {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Heavy)
            .fontFamily('serif')
          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(12)
              .fontWeight(FontWeight.SemiBold)
          }
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 14, bottom: 14 })
      .fontColor(Color.White)
    }
    .type(ButtonType.Normal)
    .borderRadius(10)
    .backgroundColor(this.color)
    .border({ width: 1, color: Colors.dawnYellow, radius: 10 })
    .padding(4)
    .onClick(() => {
      if (this.action) this.action();
    })
  }
}
