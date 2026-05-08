import { Colors } from '../components/Colors';
import { HomeView } from './HomeView';
import { TimelineView } from './TimelineView';
import { MapView } from './MapView';
import { CollectionView } from './CollectionView';
import { ProfileView } from './ProfileView';

enum Tab {
  HOME = 0,
  TIMELINE = 1,
  MAP = 2,
  COLLECTION = 3,
  PROFILE = 4
}

@Entry
@Component
struct Index {
  @State selectedTab: Tab = Tab.HOME;

  private tabItems: { tab: Tab, title: string, icon: string, selectedIcon: string }[] = [
    { tab: Tab.HOME, title: '首页', icon: '☰', selectedIcon: '☰' },
    { tab: Tab.TIMELINE, title: '时间轴', icon: '☰', selectedIcon: '☰' },
    { tab: Tab.MAP, title: '地图', icon: '◎', selectedIcon: '◎' },
    { tab: Tab.COLLECTION, title: '收藏', icon: '▦', selectedIcon: '▦' },
    { tab: Tab.PROFILE, title: '我的', icon: '✉', selectedIcon: '✉' }
  ];

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // Content
      Column() {
        if (this.selectedTab === Tab.HOME) {
          HomeView()
        } else if (this.selectedTab === Tab.TIMELINE) {
          TimelineView()
        } else if (this.selectedTab === Tab.MAP) {
          MapView()
        } else if (this.selectedTab === Tab.COLLECTION) {
          CollectionView()
        } else if (this.selectedTab === Tab.PROFILE) {
          ProfileView()
        }
      }
      .padding({ bottom: 90 })
      .width('100%')
      .height('100%')

      // TabBar
      this.PostalTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }

  @Builder
  PostalTabBar() {
    Row({ space: 0 }) {
      ForEach(this.tabItems, (item) => {
        Button() {
          Column({ space: 6 }) {
            Text(this.selectedTab === item.tab ? item.selectedIcon : item.icon)
              .fontSize(25)
              .fontWeight(FontWeight.SemiBold)
              .width(34)
              .height(30)
              .textAlign(TextAlign.Center)
              .fontColor(this.selectedTab === item.tab ? Color.White : '#555A56')
              .backgroundColor(this.selectedTab === item.tab ? Colors.travelBlue : 'transparent')
              .borderRadius(5)

            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.SemiBold)
              .fontColor(this.selectedTab === item.tab ? Colors.travelBlue : '#4D4D4D')
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
        }
        .type(ButtonType.Normal)
        .backgroundColor('transparent')
        .layoutWeight(1)
        .onClick(() => {
          this.selectedTab = item.tab;
        })
      })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 10 })
    .backgroundColor('rgba(255,252,245,0.92)')
    .borderRadius(22)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 16, color: 'rgba(0,0,0,0.12)', offsetY: 8 })
    .margin({ left: 14, right: 14, bottom: 8 })
  }
}
