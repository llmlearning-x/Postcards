import { Colors } from '../components/Colors';
import { HomeView } from './HomeView';
import { TimelineView } from './TimelineView';
import { MapView } from './MapView';
import { CollectionView } from './CollectionView';
import { ProfileView } from './ProfileView';
import { ToastManager, ConfirmDialogManager, LoadingManager, ToastType } from '../utils/GlobalStateManager';

enum Tab {
  HOME = 0,
  TIMELINE = 1,
  MAP = 2,
  COLLECTION = 3,
  PROFILE = 4
}

interface TabItem {
  tab: Tab;
  title: string;
  icon: string;
  activeIcon: string;
}

@Entry
@Component
struct Index {
  @State selectedTab: Tab = Tab.HOME;

  private tabItems: TabItem[] = [
    { tab: Tab.HOME, title: '首页', icon: '🏠', activeIcon: '🏡' },
    { tab: Tab.TIMELINE, title: '时间轴', icon: '📦', activeIcon: '📬' },
    { tab: Tab.MAP, title: '地图', icon: '🗺', activeIcon: '📍' },
    { tab: Tab.COLLECTION, title: '收藏', icon: '♡', activeIcon: '❤️' },
    { tab: Tab.PROFILE, title: '我的', icon: '👤', activeIcon: '👥' }
  ];

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
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

      this.PostalTabBar()

      // Global Toast
      if (ToastManager.showToast) {
        Column() {
          Row({ space: 8 }) {
            Text(this.getToastIcon())
              .fontSize(16)
            Text(ToastManager.toastMessage)
              .fontSize(14)
              .fontColor(Color.White)
          }
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        }
        .backgroundColor(this.getToastColor())
        .borderRadius(24)
        .shadow({ radius: 12, offsetY: 4 })
        .position({ x: '50%', y: '75%' })
        .translate({ x: '-50%', y: '-50%' })
        .zIndex(9999)
      }

      // Global Confirm Dialog
      if (ConfirmDialogManager.isVisible) {
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => { ConfirmDialogManager.hide(); })

          Column({ space: 16 }) {
            Text(ConfirmDialogManager.isDangerous ? '⚠️' : '💡')
              .fontSize(32)
              .margin({ top: 8 })

            Text(ConfirmDialogManager.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.inkBlack)

            Text(ConfirmDialogManager.message)
              .fontSize(14)
              .fontColor(Colors.pencilGray)
              .textAlign(TextAlign.Center)
              .lineHeight(20)

            Row({ space: 12 }) {
              Button(ConfirmDialogManager.cancelText)
                .fontSize(15)
                .fontColor(Colors.pencilGray)
                .backgroundColor('rgba(0,0,0,0.05)')
                .borderRadius(10)
                .height(44)
                .layoutWeight(1)
                .onClick(() => { ConfirmDialogManager.cancel(); })

              Button(ConfirmDialogManager.confirmText)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .backgroundColor(ConfirmDialogManager.isDangerous ? Colors.stampRed : Colors.travelBlue)
                .borderRadius(10)
                .height(44)
                .layoutWeight(1)
                .onClick(() => { ConfirmDialogManager.confirm(); })
            }
            .margin({ top: 8 })
          }
          .padding(24)
          .backgroundColor(Colors.cardBackground)
          .borderRadius(20)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.25)', offsetY: 8 })
          .margin({ left: 40, right: 40 })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9998)
      }

      // Global Loading
      if (LoadingManager.isLoading) {
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.4)')

          Column({ space: 16 }) {
            LoadingProgress()
              .width(40)
              .height(40)

            Text(LoadingManager.message)
              .fontSize(14)
              .fontColor(Color.White)
          }
          .padding(24)
          .backgroundColor('rgba(0,0,0,0.8)')
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9997)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)
  }

  private getToastIcon(): string {
    switch (ToastManager.toastType) {
      case ToastType.SUCCESS: return '✓';
      case ToastType.ERROR: return '✕';
      case ToastType.WARNING: return '!';
      default: return 'i';
    }
  }

  private getToastColor(): string {
    switch (ToastManager.toastType) {
      case ToastType.SUCCESS: return 'rgba(46, 125, 88, 0.95)';
      case ToastType.ERROR: return 'rgba(184, 74, 56, 0.95)';
      case ToastType.WARNING: return 'rgba(216, 191, 125, 0.95)';
      default: return 'rgba(0, 0, 0, 0.85)';
    }
  }

  @Builder
  PostalTabBar() {
    Row({ space: 0 }) {
      ForEach(this.tabItems, (item: TabItem) => {
        Button() {
          Column({ space: 4 }) {
            Text(this.selectedTab === item.tab ? item.activeIcon : item.icon)
              .fontSize(22)
              .fontWeight(this.selectedTab === item.tab ? FontWeight.Bold : FontWeight.Normal)

            Text(item.title)
              .fontSize(this.selectedTab === item.tab ? 13 : 12)
              .fontWeight(this.selectedTab === item.tab ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.selectedTab === item.tab ? Colors.travelBlue : Colors.pencilGray)

            if (this.selectedTab === item.tab) {
              Stack()
                .width(24)
                .height(3)
                .backgroundColor(Colors.stampRed)
                .borderRadius(1.5)
            }
          }
          .width('100%')
          .padding({ top: 8, bottom: 6 })
        }
        .type(ButtonType.Normal)
        .backgroundColor(this.selectedTab === item.tab ? 'rgba(15,93,73,0.06)' : 'transparent')
        .borderRadius(12)
        .layoutWeight(1)
        .onClick(() => {
          this.selectedTab = item.tab;
        })
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 6, bottom: 8 })
    .backgroundColor('rgba(255,252,245,0.98)')
    .borderRadius(20)
    .border({ width: 1, color: Colors.lineSepia })
    .shadow({ radius: 16, color: 'rgba(0,0,0,0.08)', offsetY: -2 })
    .margin({ left: 14, right: 14, bottom: 10 })
  }
}
