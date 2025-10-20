import { router } from '@kit.ArkUI';
import { AppTheme } from '../theme/AppTheme';
import { DiaryListPage } from './DiaryListPage';
import { PhotoGridPage } from './PhotoGridPage';

@Entry
@Component
struct MainPage {
  @State currentTabIndex: number = 0;

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('我的秘密空间')
          .fontSize(AppTheme.FONT_SIZE_LARGE)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Blank()

        Button() {
          Image($r('sys.symbol.settings'))
            .width(24)
            .height(24)
            .fillColor(AppTheme.TEXT_PRIMARY)
        }
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SettingsPage'
          }).catch((err: Error) => {
            console.error('Router failed:', err.message);
          });
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: AppTheme.SPACING_NORMAL, right: AppTheme.SPACING_NORMAL })
      .backgroundColor(AppTheme.CARD_BACKGROUND)

      // Tab内容区
      Tabs({ index: this.currentTabIndex }) {
        TabContent() {
          DiaryListPage()
        }
        .tabBar(this.TabBuilder(0, '日记', $r('sys.symbol.book')))

        TabContent() {
          PhotoGridPage()
        }
        .tabBar(this.TabBuilder(1, '相册', $r('sys.symbol.photo')))
      }
      .barPosition(BarPosition.End)
      .barMode(BarMode.Fixed)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }

  @Builder
  TabBuilder(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
        .margin({ bottom: 4 })
        .animation({
          duration: 200,
          curve: Curve.EaseInOut
        })

      Text(title)
        .fontSize(AppTheme.FONT_SIZE_SMALL)
        .fontColor(this.currentTabIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
        .animation({
          duration: 200,
          curve: Curve.EaseInOut
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 8 })
  }
}

