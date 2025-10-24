import { router } from '@kit.ArkUI';
import { DiaryService } from '../services/DiaryService';
import { DiaryModel, MOOD_CONFIG } from '../models/DiaryModel';
import { AppTheme } from '../theme/AppTheme';
import { UIUtils } from '../utils/UIUtils';
import { Logger } from '@ohos/common';

const logger: Logger = new Logger();

@Component
export struct DiaryListPage {
  @State diaries: DiaryModel[] = [];
  @State isLoading: boolean = true;
  private diaryService: DiaryService = new DiaryService(getContext(this));
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await this.loadDiaries();
  }

  /**
   * 加载日记列表
   */
  async loadDiaries() {
    try {
      this.isLoading = true;
      this.diaries = await this.diaryService.getAllDiaries();
      logger.info('DiaryListPage', `Loaded ${this.diaries.length} diaries`);
    } catch (err) {
      logger.error('DiaryListPage', `Load diaries failed: ${JSON.stringify(err)}`);
      UIUtils.showError('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除日记
   */
  async deleteDiary(diary: DiaryModel) {
    try {
      const result = await UIUtils.showConfirmDialog({
        title: '删除日记',
        message: '确定要删除这条日记吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '删除', color: AppTheme.ERROR_COLOR }
        ]
      });
      
      if (result.index === 1 && diary.diaryId) {
        await this.diaryService.deleteDiary(diary.diaryId);
        await this.loadDiaries();
        UIUtils.showSuccess('已删除');
      }
    } catch (err) {
      logger.error('DiaryListPage', `Delete diary failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 获取心情信息
   */
  getMoodInfo(mood: string): string {
    const moodInfo = MOOD_CONFIG.find(m => m.type === mood);
    return moodInfo ? moodInfo.emoji : '😊';
  }

  /**
   * 格式化日期
   */
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${month}月${day}日`;
  }

  /**
   * 格式化时间
   */
  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  build() {
    Stack() {
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(AppTheme.PRIMARY_COLOR)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.diaries.length === 0) {
        // 空状态
        Column() {
          Image($r('sys.symbol.book'))
            .width(80)
            .height(80)
            .fillColor(AppTheme.TEXT_PLACEHOLDER)
            .margin({ bottom: AppTheme.SPACING_NORMAL })

          Text('还没有日记')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.TEXT_SECONDARY)

          Text('点击右下角+号开始记录')
            .fontSize(AppTheme.FONT_SIZE_SMALL)
            .fontColor(AppTheme.TEXT_PLACEHOLDER)
            .margin({ top: AppTheme.SPACING_SMALL })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .opacity(0.6)
      } else {
        // 日记列表
        List({ scroller: this.scroller }) {
          ForEach(this.diaries, (diary: DiaryModel, index: number) => {
            ListItem() {
              this.DiaryCard(diary)
            }
            .margin({
              left: AppTheme.SPACING_NORMAL,
              right: AppTheme.SPACING_NORMAL,
              top: index === 0 ? AppTheme.SPACING_NORMAL : AppTheme.SPACING_SMALL,
              bottom: index === this.diaries.length - 1 ? 80 : AppTheme.SPACING_SMALL
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/DiaryEditPage',
                params: { diaryId: diary.diaryId }
              }).catch((err: Error) => {
                logger.error('DiaryListPage', `Router failed: ${err.message}`);
              });
            })
            .gesture(
              LongPressGesture()
                .onAction(() => {
                  this.deleteDiary(diary);
                })
            )
          }, (diary: DiaryModel) => diary.diaryId ?? '')
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
      }

      // 添加按钮
      Button() {
        Text('+')
          .fontSize(32)
          .fontColor(AppTheme.TEXT_WHITE)
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .backgroundColor(AppTheme.PRIMARY_COLOR)
      .borderRadius(AppTheme.RADIUS_ROUND)
      .position({ x: '100%', y: '100%' })
      .translate({ x: -76, y: -76 })
      .shadow({
        radius: 12,
        color: AppTheme.PRIMARY_COLOR + '40',
        offsetY: 4
      })
      .onClick(() => {
        router.pushUrl({
          url: 'pages/DiaryEditPage'
        }).catch((err: Error) => {
          logger.error('DiaryListPage', `Router failed: ${err.message}`);
        });
      })
      .zIndex(100)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DiaryCard(diary: DiaryModel) {
    Row() {
      // 左侧装饰条和心情
      Column() {
        // 心情 emoji
        Text(this.getMoodInfo(diary.mood))
          .fontSize(28)
          .margin({ bottom: 6 })
        
        // 日期显示
        Column() {
          Text(new Date(diary.createdAt).getDate().toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.PRIMARY_COLOR)
          
          Text(this.formatDate(diary.createdAt).substring(0, 2))
            .fontSize(11)
            .fontColor(AppTheme.TEXT_PLACEHOLDER)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(65)
      .justifyContent(FlexAlign.Start)
      .padding({ top: 12, bottom: 12 })
      .borderRadius({
        topLeft: AppTheme.RADIUS_LARGE,
        bottomLeft: AppTheme.RADIUS_LARGE
      })
      .linearGradient({
        angle: 135,
        colors: [[AppTheme.PRIMARY_COLOR + '15', 0.0], [AppTheme.PRIMARY_COLOR + '05', 1.0]]
      })

      // 右侧内容区
      Column() {
        // 标题行
        Row() {
          Text(diary.title || '无标题')
            .fontSize(16)
            .fontColor(AppTheme.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          // 时间标签
          Text(this.formatTime(diary.createdAt))
            .fontSize(11)
            .fontColor(AppTheme.TEXT_PLACEHOLDER)
            .backgroundColor(AppTheme.TEXT_PLACEHOLDER + '15')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)
        }
        .width('100%')
        .margin({ bottom: 6 })

        // 内容预览
        Text(diary.content)
          .width('100%')
          .fontSize(13)
          .fontColor(AppTheme.TEXT_SECONDARY)
          .lineHeight(19)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: diary.tags && diary.tags.length > 0 ? 8 : 0 })

        // 标签
        if (diary.tags && diary.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(diary.tags.slice(0, 3), (tag: string, idx: number) => {
              Row() {
                Text('#')
                  .fontSize(10)
                  .fontColor(AppTheme.PRIMARY_COLOR)
                  .fontWeight(FontWeight.Bold)
                  .margin({ right: 2 })
                
                Text(tag)
                  .fontSize(10)
                  .fontColor(AppTheme.PRIMARY_COLOR)
              }
              .padding({ left: 7, right: 7, top: 3, bottom: 3 })
              .backgroundColor(AppTheme.PRIMARY_COLOR + '12')
              .borderRadius(10)
              .border({
                width: 0.5,
                color: AppTheme.PRIMARY_COLOR + '30'
              })
              .margin({ right: 5, bottom: 5 })
            })
          }
          .width('100%')
        }
      }
      .layoutWeight(1)
      .padding({
        left: 12,
        right: 12,
        top: 12,
        bottom: 12
      })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .backgroundColor(AppTheme.CARD_BACKGROUND)
    .borderRadius(AppTheme.RADIUS_LARGE)
    .border({
      width: 1,
      color: AppTheme.TEXT_PLACEHOLDER + '10'
    })
    .shadow({
      radius: 12,
      color: '#00000008',
      offsetX: 0,
      offsetY: 4
    })
    .transition({
      type: TransitionType.Insert,
      opacity: 0,
      translate: { y: 50 }
    })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }
}

